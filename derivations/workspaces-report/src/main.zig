const std = @import("std");
const HyprlandEventSocket = @import("hyprland-zsock").HyprlandEventSocket;
const HyprlandIpc = @import("hyprland-zsock").HyprlandIPC;
const EventParseDiagnostics = @import("hyprland-zsock").EventParseDiagnostics;

const Allocator = std.mem.Allocator;

const Workspace = struct {
    name: []const u8,
    id: ?i32 = null,
    isFocused: bool = false,
    isUrgent: bool = false,
    windowsCount: u32 = 0,

    // Mainly for debugging
    pub fn format(
        self: @This(),
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{s} (id: {?}, F: {s}, U: {s}, W: {})", .{
            self.name,
            self.id,
            if (self.isFocused) "Y" else "N",
            if (self.isUrgent) "Y" else "N",
            self.windowsCount,
        });
    }
};

const Monitor = struct {
    id: i32,
    name: []const u8,
    isFocused: bool = false,
    workspaces: std.ArrayList(Workspace),
    focusedWorkspace: ?usize,

    pub fn init(alloc: std.mem.Allocator, id: i32, workspaces: []const Workspace) !@This() {
        const monitor: Monitor = .{ .id = id, .workspaces = .init(alloc) };
        try monitor.workspaces.appendSlice(workspaces);
        return monitor;
    }

    pub fn jsonStringify(self: @This(), jw: anytype) !void {
        try jw.beginObject();
        try jw.objectField("id");
        try jw.write(self.id);
        try jw.objectField("isFocused");
        try jw.write(self.isFocused);
        try jw.objectField("name");
        try jw.write(self.name);
        try jw.objectField("workspaces");
        try jw.write(self.workspaces.items);
        try jw.endObject();
    }

    // Mainly for debugging
    pub fn format(
        self: @This(),
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        try writer.print("{s} (id: {}, F: {s}, FW: {?})", .{
            self.name,
            self.id,
            if (self.isFocused) "Y" else "N",
            self.focusedWorkspace,
        });

        for (self.workspaces.items) |workspace| {
            try writer.print("\n\t{any}", .{workspace});
        }
        try writer.print("\n", .{});
    }
};

const WorkspaceLocation = struct {
    monitor: usize,
    workspace: usize,
};

const MonitorsState = struct {
    monitors: std.ArrayList(Monitor),
    focusedMonitor: ?usize,
    alloc: Allocator,

    pub fn init(alloc: Allocator) @This() {
        return .{
            .focusedMonitor = null,
            .monitors = .init(alloc),
            .alloc = alloc,
        };
    }

    pub fn addWorkspace(self: *@This(), monitorId: i32, workspaceId: i32, workspaceName: []const u8, windows: u32) !void {
        for (self.monitors.items) |*monitor| {
            if (monitor.id != monitorId) continue;
            for (monitor.workspaces.items) |*workspace| {
                if (!std.mem.eql(u8, workspaceName, workspace.name)) continue;
                workspace.windowsCount = windows;
                workspace.id = workspaceId;
                return;
            }
        }
    }

    /// Creates a new monitor with 9 pre-loaded workspaces.
    pub fn addMonitor(
        self: *@This(),
        id: i32,
        name: []const u8,
        activeWorkspace: struct { id: i32, name: []const u8 },
        focused: bool,
    ) !void {
        var newMonitor: Monitor = .{
            .id = id,
            .focusedWorkspace = null,
            .name = try self.alloc.dupe(u8, name),
            .workspaces = .init(self.alloc),
        };
        try newMonitor.workspaces.appendSlice(&.{
            .{ .name = "1" },
            .{ .name = "2" },
            .{ .name = "3" },
            .{ .name = "4" },
            .{ .name = "5" },
            .{ .name = "6" },
            .{ .name = "7" },
            .{ .name = "8" },
            .{ .name = "9" },
        });
        for (newMonitor.workspaces.items, 0..) |*workspace, workspaceIndex| {
            if (std.mem.eql(u8, workspace.name, activeWorkspace.name)) {
                workspace.isFocused = true;
                workspace.id = activeWorkspace.id;
                newMonitor.focusedWorkspace = workspaceIndex;
            }
        }
        try self.monitors.append(newMonitor);
        if (focused) {
            self.setFocusedMonitor(self.monitors.items.len - 1);
        }
    }

    /// Will try to locate a workspace with a matching ID on all monitors,
    /// regardless if they're focused or not.k
    /// The returning pointer's lifetime should match that of the self.
    pub fn findWorkspaceWithId(self: *@This(), id: i32) ?WorkspaceLocation {
        for (self.monitors.items, 0..) |monitor, monitorIndex| {
            for (monitor.workspaces.items, 0..) |workspace, workspaceIndex| {
                if (workspace.id == id) {
                    return .{
                        .workspace = workspaceIndex,
                        .monitor = monitorIndex,
                    };
                }
            }
        }
        return null;
    }

    /// Will try to locate a workspace with a matching name. Will first try to
    /// locate the workspace in the focused monitor, but till try the others if
    /// not found. The returning pointer's lifetime should match that of the self.
    pub fn findWorkspaceWithName(self: *@This(), name: []const u8) ?WorkspaceLocation {
        if (self.monitors.items.len == 0) return null;
        const firstMonitorToCheckIndex = self.focusedMonitor orelse 0;
        const firstMonitorToCheck = self.monitors.items[firstMonitorToCheckIndex];
        for (firstMonitorToCheck.workspaces.items, 0..) |workspace, workspaceIndex| {
            if (std.mem.eql(u8, workspace.name, name)) return .{
                .workspace = workspaceIndex,
                .monitor = firstMonitorToCheckIndex,
            };
        }
        for (self.monitors.items, 0..) |*monitor, monitorIndex| {
            // We already checked the focused monitor. Skip it.
            if (monitor.id == firstMonitorToCheck.id) continue;
            for (monitor.workspaces.items, 0..) |*workspace, workspaceIndex| {
                if (std.mem.eql(u8, workspace.name, name)) return .{
                    .workspace = workspaceIndex,
                    .monitor = monitorIndex,
                };
            }
        }
        return null;
    }

    /// Writes the json string of self to the given stdout stream.
    pub fn print(self: *const @This(), stdout: std.io.AnyWriter) !void {
        try std.json.stringify(
            self.monitors.items,
            .{ .whitespace = .minified },
            stdout,
        );
        try stdout.writeByte('\n');
    }

    pub fn findWorkspaceWithIdOrName(self: *@This(), id: i32, name: []const u8) ?WorkspaceLocation {
        return self.findWorkspaceWithId(id) orelse
            self.findWorkspaceWithName(name) orelse
            null;
    }

    pub fn setFocusedMonitor(self: *@This(), monitorIndex: usize) void {
        if (self.focusedMonitor) |focusedMonitorIndex| {
            self.monitors.items[focusedMonitorIndex]
                .isFocused = false;
        }
        self.focusedMonitor = monitorIndex;
        self.monitors.items[monitorIndex].isFocused = true;
    }

    pub fn setFocusedWorkspace(self: *@This(), monitorIndex: usize, workspaceIndex: usize) void {
        self.setFocusedMonitor(monitorIndex);
        const monitor = &self.monitors.items[monitorIndex];
        if (monitor.focusedWorkspace) |focusedWorkspaceIndex| {
            monitor.workspaces.items[focusedWorkspaceIndex]
                .isFocused = false;
        }
        monitor.focusedWorkspace = workspaceIndex;
        monitor.workspaces.items[workspaceIndex].isFocused = true;
    }

    /// Will mark the found workspace as focused.
    pub fn focusWorkspace(self: *@This(), workspaceIdentifier: union(enum) {
        id: i32,
        name: []const u8,
        /// Will first try to use the Id, and then try to use the name.
        idOrName: struct { id: i32, name: []const u8 },
    }) void {
        const idOpt, const workspaceLocation =
            switch (workspaceIdentifier) {
                .id => |id| .{ id, self.findWorkspaceWithId(id) orelse return },
                .name => |name| .{ null, self.findWorkspaceWithName(name) orelse return },
                .idOrName => |idOrName| .{
                    idOrName.id,
                    self.findWorkspaceWithIdOrName(idOrName.id, idOrName.name) orelse return,
                },
            };
        const monitor = &self.monitors.items[workspaceLocation.monitor];
        const workspace = &monitor.workspaces.items[workspaceLocation.workspace];

        if (idOpt) |id| {
            workspace.id = id;
        }
        self.setFocusedWorkspace(workspaceLocation.monitor, workspaceLocation.workspace);
    }

    pub fn focusMonitor(self: *@This(), monitorName: []const u8, workspaceName: []const u8) void {
        const monitorIndex = loop: {
            for (self.monitors.items, 0..) |monitor, monitorIndex| {
                if (std.mem.eql(u8, monitor.name, monitorName)) break :loop monitorIndex;
            }
            return;
        };
        const workspaceIndex = loop: {
            for (self.monitors.items[monitorIndex].workspaces.items, 0..) |workspace, workspaceIndex| {
                if (std.mem.eql(u8, workspace.name, workspaceName)) break :loop workspaceIndex;
            }
            return;
        };

        self.setFocusedWorkspace(monitorIndex, workspaceIndex);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const stdout = std.io.getStdOut().writer();

    var monitors: MonitorsState = .init(alloc);

    var ipc = try HyprlandIpc.init(alloc);
    {
        const currentMonitors = try ipc.requestMonitors();
        defer currentMonitors.deinit();

        for (currentMonitors.parsed) |monitor| {
            try monitors.addMonitor(
                monitor.id,
                monitor.name,
                .{
                    .name = monitor.activeWorkspace.name,
                    .id = monitor.activeWorkspace.id,
                },
                monitor.focused,
            );
        }
    }
    {
        const allWorkspaces = try ipc.requestWorkspaces();
        defer allWorkspaces.deinit();

        for (allWorkspaces.parsed) |*workspace| {
            try monitors.addWorkspace(workspace.monitorID, workspace.id, workspace.name, workspace.windows);
        }
    }
    {
        const currentWorkspace = try ipc.requestActiveWorkspace();
        defer currentWorkspace.deinit();

        if (monitors.findWorkspaceWithId(currentWorkspace.parsed.id)) |activeWorkspace| {
            const monitor = &monitors.monitors.items[activeWorkspace.monitor];
            const workspace = &monitor.workspaces.items[activeWorkspace.workspace];
            workspace.isFocused = true;
            monitor.isFocused = true;
            monitors.focusedMonitor = activeWorkspace.monitor;
            monitor.focusedWorkspace = activeWorkspace.workspace;
        }
    }

    var hyprlandSocket = try HyprlandEventSocket.init();
    defer hyprlandSocket.deinit();

    try monitors.print(stdout.any());
    var diags: EventParseDiagnostics = undefined;
    const stderr = std.io.getStdErr().writer();
    while (true) {
        const event = hyprlandSocket.consumeEvent(&diags) catch {
            try std.fmt.format(stderr, "{any}\n", .{diags});
            continue;
        };

        switch (event) {
            .openwindow => |window| {
                const workspaceLocation = monitors.findWorkspaceWithName(
                    window.workspaceName,
                ) orelse continue;
                monitors.monitors.items[workspaceLocation.monitor]
                    .workspaces.items[workspaceLocation.workspace]
                    .windowsCount += 1;
                try monitors.print(stdout.any());
            },
            .workspacev2 => |workspace| {
                monitors.focusWorkspace(.{
                    .idOrName = .{
                        .id = workspace.workspaceId,
                        .name = workspace.workspaceName,
                    },
                });
                try monitors.print(stdout.any());
            },
            .createworkspacev2 => |createWorkspace| {
                const workspaceLocation = monitors.findWorkspaceWithIdOrName(createWorkspace.workspaceId, createWorkspace.workspaceName) orelse
                    continue;

                const workspace = &monitors.monitors.items[workspaceLocation.monitor]
                    .workspaces.items[workspaceLocation.workspace];
                workspace.windowsCount = 0;
                workspace.id = createWorkspace.workspaceId;
                try monitors.print(stdout.any());
            },
            .movewindowv2 => |movewindow| {
                const workspaceLocation = monitors.findWorkspaceWithIdOrName(
                    movewindow.workspaceId,
                    movewindow.workspaceName,
                ) orelse continue;

                const wp = &monitors.monitors.items[workspaceLocation.monitor]
                    .workspaces.items[workspaceLocation.workspace];

                wp.windowsCount += 1;
                wp.id = movewindow.workspaceId;

                try monitors.print(stdout.any());
            },
            .focusedmon => |focusMon| {
                monitors.focusMonitor(focusMon.monitorName, focusMon.workspaceName);
                try monitors.print(stdout.any());
            },
            .destroyworkspacev2 => |destroyWorkspace| {
                const monitorWorkspace = monitors.findWorkspaceWithIdOrName(destroyWorkspace.workspaceId, destroyWorkspace.workspaceName) orelse continue;
                const wp = &monitors.monitors.items[monitorWorkspace.monitor]
                    .workspaces.items[monitorWorkspace.workspace];
                wp.windowsCount = 0;
                wp.id = destroyWorkspace.workspaceId;
                try monitors.print(stdout.any());
            },
            else => continue,
        }
    }
}
