const std = @import("std");
const HyprlandEvents = @import("hyprland-zsock").HyprlandEventSocket;
const EventParseDiagnostics = @import("hyprland-zsock").EventParseDiagnostics;
const HyprlandIpc = @import("hyprland-zsock").HyprlandIPC;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    var stderr_buf: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stderr().writer(&stderr_buf);
    const stderr = &stderr_writer.interface;

    var ipc = try HyprlandIpc.init(alloc);

    {
        const activeWindow = try ipc.requestActiveWindow();
        defer activeWindow.deinit();
        try stdout.print("{s}\n", .{activeWindow.parsed.title});
        try stdout.flush();
    }

    var eventListener = try HyprlandEvents.init();
    var diags: EventParseDiagnostics = undefined;
    while (true) {
        const event = eventListener.consumeEvent(&diags) catch {
            try stderr.print("Error consuming event: {any}\n", .{diags});
            try stderr.flush();
            continue;
        };
        switch (event) {
            .activewindow => |activeWindow| {
                try stdout.print("{s}\n", .{activeWindow.windowTitle});
                try stdout.flush();
            },
            else => {},
        }
    }
}
