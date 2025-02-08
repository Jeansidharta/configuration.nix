const std = @import("std");
const HyprlandEvents = @import("hyprland-zsock").HyprlandEventSocket;
const EventParseDiagnostics = @import("hyprland-zsock").EventParseDiagnostics;
const HyprlandIpc = @import("hyprland-zsock").HyprlandIPC;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const stdout = std.io.getStdOut().writer();

    var ipc = try HyprlandIpc.init(alloc);

    {
        const activeWindow = try ipc.requestActiveWindow();
        defer activeWindow.deinit();
        try stdout.print("{s}\n", .{activeWindow.parsed.title});
    }

    var eventListener = try HyprlandEvents.init();
    var diags: EventParseDiagnostics = undefined;
    const stderr = std.io.getStdErr().writer();
    while (true) {
        const event = eventListener.consumeEvent(&diags) catch {
            try stderr.print("Error consuming event: {any}\n", .{diags});
            continue;
        };
        switch (event) {
            .activewindow => |activeWindow| {
                try stdout.print("{s}\n", .{activeWindow.windowTitle});
            },
            else => {},
        }
    }
}
