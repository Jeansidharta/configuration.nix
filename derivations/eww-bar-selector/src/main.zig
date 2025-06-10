const std = @import("std");
const HyprlandIPC = @import("hyprland_zsock").HyprlandIPC;
const HyprlandEventSocket = @import("hyprland_zsock").HyprlandEventSocket;
const EventParseDiagnostics = @import("hyprland_zsock").EventParseDiagnostics;

fn selectTransparent(alloc: std.mem.Allocator) !void {
    _ = try std.process.Child.run(
        .{
            .argv = &.{ "eww", "update", "show_background=false" },
            .allocator = alloc,
        },
    );
}

fn selectWithBackground(alloc: std.mem.Allocator) !void {
    _ = try std.process.Child.run(
        .{
            .argv = &.{ "eww", "update", "show_background=true" },
            .allocator = alloc,
        },
    );
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const alloc = gpa.allocator();

    var ipc = try HyprlandIPC.init(alloc);
    var eventSocket = try HyprlandEventSocket.init();
    while (true) {
        var diags = EventParseDiagnostics{};
        const event = eventSocket.consumeEvent(&diags) catch {
            std.log.err("{any}", .{diags});
            continue;
        };
        switch (event) {
            .workspacev2, .openwindow, .closewindow, .focusedmonv2, .fullscreen => {
                const workspace = ipc.requestActiveWorkspace() catch |err| {
                    std.log.err("{any}", .{err});
                    continue;
                };
                defer workspace.deinit();

                if (workspace.parsed.hasfullscreen or workspace.parsed.windows == 1) {
                    selectWithBackground(alloc) catch |e|
                        {
                            std.log.err("Failed to run eww command: {any}", .{e});
                            continue;
                        };
                } else {
                    selectTransparent(alloc) catch |e| {
                        std.log.err("Failed to run eww command: {any}", .{e});
                        continue;
                    };
                }
            },
            else => {},
        }
    }
}
