const std = @import("std");
const HyprlandEvents = @import("hyprland-zsock").events.HyprlandEventSocket;
const HyprlandIpc = @import("hyprland-zsock").ipc;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const stdout = std.io.getStdOut().writer().any();

    var ipc = try HyprlandIpc.init();

    {
        const activeWindow = try ipc.sendCommand(
            alloc,
            .activewindow,
            void{},
        );
        defer activeWindow.deinit();
        try stdout.writeAll(activeWindow.variant.title);
        try stdout.writeByte('\n');
    }

    var eventListener = try HyprlandEvents.open();
    while (true) {
        const event = try eventListener.consumeEvent();
        switch (event) {
            .activewindow => |activeWindow| {
                try stdout.writeAll(activeWindow.windowTitle);
                try stdout.writeByte('\n');
            },
            else => {},
        }
    }
}
