const std = @import("std");
const HyprlandEventSocket = @import("hyprland-zsock").events.HyprlandEventSocket;
const HyprlandIpc = @import("hyprland-zsock").ipc;

const Allocator = std.mem.Allocator;

const Workspace = struct {
    name: []const u8,
    id: ?u32 = null,
    isFocused: bool = false,
    isUrgent: bool = false,
    windowsCount: u32 = 0,
};

const Monitor = struct {
    id: u32,
    name: []const u8,
    isFocused: bool = true,
    workspaces: std.ArrayList(Workspace),
    focusedWorkspace: ?*Workspace,

    pub fn init(alloc: std.mem.Allocator, id: u32, workspaces: []const Workspace) !@This() {
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
};

const WorkspaceLocation = struct {
    monitor: *Monitor,
    workspace: *Workspace,
};

const MonitorsState = struct {
    monitors: std.ArrayList(Monitor),
    focusedMonitor: ?*Monitor,
    alloc: Allocator,

    pub fn init(alloc: Allocator) @This() {
        return .{
            .focusedMonitor = null,
            .monitors = .init(alloc),
            .alloc = alloc,
        };
    }

    pub fn addWorkspace(self: *@This(), monitorId: u32, workspaceId: u32, workspaceName: []const u8, windows: u32) !void {
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
        id: u32,
        name: []const u8,
        activeWorkspace: struct { id: u32, name: []const u8 },
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
        for (newMonitor.workspaces.items) |*workspace| {
            if (std.mem.eql(u8, workspace.name, activeWorkspace.name)) {
                workspace.isFocused = true;
                workspace.id = activeWorkspace.id;
            }
        }
        try self.monitors.append(newMonitor);
        if (focused) {
            self.focusedMonitor = &self.monitors.items[self.monitors.items.len - 1];
            self.focusedMonitor.?.isFocused = true;
        }
    }

    /// Will try to locate a workspace with a matching ID on all monitors,
    /// regardless if they're focused or not.
    /// The returning pointer's lifetime should match that of the self.
    pub fn findWorkspaceWithId(self: *@This(), id: u32) ?WorkspaceLocation {
        for (self.monitors.items) |*monitor| {
            for (monitor.workspaces.items) |*workspace| {
                if (workspace.id == id) return .{ .workspace = workspace, .monitor = monitor };
            }
        }
        return null;
    }

    /// Will try to locate a workspace with a matching name. Will first try to
    /// locate the workspace in the focused monitor, but till try the others if
    /// not found. The returning pointer's lifetime should match that of the self.
    pub fn findWorkspaceWithName(self: *@This(), name: []const u8) ?WorkspaceLocation {
        if (self.monitors.items.len == 0) return null;
        const firstMonitorToCheck = self.focusedMonitor orelse &self.monitors.items[0];
        for (firstMonitorToCheck.workspaces.items) |*workspace| {
            if (std.mem.eql(u8, workspace.name, name)) return .{
                .workspace = workspace,
                .monitor = firstMonitorToCheck,
            };
        }
        for (self.monitors.items) |*monitor| {
            // We already checked the focused monitor. Skip it.
            if (monitor.id == firstMonitorToCheck.id) continue;
            for (monitor.workspaces.items) |*workspace| {
                if (std.mem.eql(u8, workspace.name, name)) return .{
                    .workspace = workspace,
                    .monitor = monitor,
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

    /// Will mark the found workspace as focused.
    pub fn focusWorkspace(self: *@This(), workspaceIdentifier: union(enum) {
        id: u32,
        name: []const u8,
        /// Will first try to use the Id, and then try to use the name.
        idOrName: struct { id: u32, name: []const u8 },
    }) void {
        const idOpt, const workspace =
            switch (workspaceIdentifier) {
            .id => |id| .{ id, self.findWorkspaceWithId(id) orelse return },
            .name => |name| .{ null, self.findWorkspaceWithName(name) orelse return },
            .idOrName => |idOrName| .{
                idOrName.id,
                self.findWorkspaceWithId(idOrName.id) orelse
                    self.findWorkspaceWithName(idOrName.name) orelse
                    return,
            },
        };
        workspace.workspace.isFocused = true;
        if (idOpt) |id| workspace.workspace.id = id;
        if (self.focusedMonitor) |focusedMonitor| {
            focusedMonitor.isFocused = false;
            if (focusedMonitor.focusedWorkspace) |focusedWorkspace| {
                focusedWorkspace.isFocused = false;
            }
        }
        self.focusedMonitor = workspace.monitor;
        workspace.monitor.isFocused = true;
        workspace.monitor.focusedWorkspace = workspace.workspace;
        workspace.workspace.isFocused = true;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const stdout = std.io.getStdOut().writer();

    var monitors: MonitorsState = .init(alloc);

    var ipc = try HyprlandIpc.init();
    {
        const currentMonitors = try ipc.sendCommand(alloc, .monitors, void{});
        defer currentMonitors.deinit();

        for (currentMonitors.variant) |monitor| {
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
        const allWorkspaces = try ipc.sendCommand(alloc, .workspaces, void{});
        defer allWorkspaces.deinit();

        for (allWorkspaces.variant) |*workspace| {
            try monitors.addWorkspace(workspace.monitorID, workspace.id, workspace.name, workspace.windows);
        }
    }
    {
        const currentWorkspace = try ipc.sendCommand(alloc, .activeworkspace, void{});
        defer currentWorkspace.deinit();

        if (monitors.findWorkspaceWithId(currentWorkspace.variant.id)) |activeWorkspace| {
            activeWorkspace.workspace.isFocused = true;
            monitors.focusedMonitor = activeWorkspace.monitor;
            monitors.focusedMonitor.?.focusedWorkspace = activeWorkspace.workspace;
        }
    }

    var hyprlandSocket = try HyprlandEventSocket.open();
    defer hyprlandSocket.deinit();

    try monitors.print(stdout.any());
    while (true) {
        const event = try hyprlandSocket.consumeEvent();

        switch (event) {
            .openwindow => |window| {
                const workspaceLocation = monitors.findWorkspaceWithName(
                    window.workspaceName,
                ) orelse continue;
                workspaceLocation.workspace.windowsCount += 1;
                try monitors.print(stdout.any());
            },
            .workspacev2 => |workspace| {
                const name = workspace.workspaceName;
                monitors.focusWorkspace(.{
                    .idOrName = .{ .id = workspace.workspaceId, .name = name },
                });
                try monitors.print(stdout.any());
            },
            .createworkspacev2 => |createWorkspace| {
                const workspaceLocation = monitors.findWorkspaceWithId(createWorkspace.workspaceId) orelse
                    monitors.findWorkspaceWithName(createWorkspace.workspaceName) orelse
                    continue;

                workspaceLocation.workspace.windowsCount = 0;
                try monitors.print(stdout.any());
            },

            .movewindowv2 => |movewindow| {
                const workspaceLocation = monitors.findWorkspaceWithId(movewindow.workspaceId) orelse
                    monitors.findWorkspaceWithName(movewindow.workspaceName) orelse
                    continue;

                workspaceLocation.workspace.windowsCount += 1;

                try monitors.print(stdout.any());
            },
            .focusedmonv2 => |focusMon| {
                const workspaceId = focusMon.workspaceId;
                monitors.focusWorkspace(.{ .id = workspaceId });
                try monitors.print(stdout.any());
            },
            .destroyworkspacev2 => |destroyWorkspace| {
                const monitorWorkspace = monitors.findWorkspaceWithId(destroyWorkspace.workspaceId) orelse continue;
                monitorWorkspace.workspace.windowsCount = 0;
                try monitors.print(stdout.any());
            },
            else => {},
        }
    }
}
