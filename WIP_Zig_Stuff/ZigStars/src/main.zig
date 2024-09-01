// const c = @cImport({
//     @cInclude("SDL2/SDL.h");
// });

const std = @import("std");
const sta = @import("stars.zig");
// const star = sta.Star;

// https://www.youtube.com/watch?v=V02EYPEtjFw
// https://gist.github.com/bens/bd9ba0414fcf74bf05ecf7e6f75c4e97
// https://codeberg.org/dude_the_builder/zig_in_depth
// http://www.sunshine2k.de/coding/javascript/graphiceffects/03_textscrolling/03_textscrolling.html

// This Zig struct uses 16 bytes (with padding) in an array.
// In a `MultiArrayList` it would use 12 bytes (no padding needed).
const Foo = struct {
    a: u16,
    b: u64,
    c: u16,

    pub fn new(x: u16, y: u16) Foo {
        return Foo{ .a = x, .b = 1, .c = y };
    }

    pub fn update(self: *Foo) void {
        self.a += 1;
    }
};

pub fn main() !void {
    var no: [10]Foo = undefined;

    var count: usize = 0;

    while (count < 10) {
        no[count] = Foo.new(12, 255);
        count += 1;
    }

    count = 0;
    while (count < 10) {
        var f = no[count];
        f.update();
        no[count] = f;
        count += 1;
    }

    // for (no) |f| {
    //     f.update();
    // }

    // Set up our allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Init our multi-array list.
    var multi = std.MultiArrayList(sta.Star){};
    defer multi.deinit(allocator);

    // Add an item, allocating if necessary.
    try multi.append(allocator, .{ .x = 1.0, .y = 1.0 });

    // Pre-allocate to add more items.
    try multi.ensureUnusedCapacity(allocator, 2);
    // Now we can add without the allocator or the `try`.
    multi.appendAssumeCapacity(.{ .x = 2, .y = 2 });
    multi.appendAssumeCapacity(.{ .x = 3, .y = 3 });

    // You can get a slice of a specific field from all the
    // items in the list with `items`.
    std.debug.print(".a: {any}\n", .{multi.items(.x)});
    std.debug.print(".b: {any}\n", .{multi.items(.y)});
    // std.debug.print(".c: {any}\n\n", .{multi.items(.c)});

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    // const allocator = gpa.allocator();
    //
    // var StarList = std.MultiArrayList(sta){};
    //
    // // const s = star.new(100,200);
    // StarList.append(allocator, .{100,100});
    // // _ = s;
    //
    // // if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
    // //     c.SDL_Log("Failed to initialise SDL: %s", c.SDL_GetError());
    // //     return error.SDLInitialisationFailure;
    // // }
    // //
    // // const window = c.SDL_CreateWindow(
    // //     "hello_sdl2",
    // //     c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED,
    // //     800, 600,
    // //     c.SDL_WINDOW_SHOWN
    // // );
    // //
    // // const renderer = c.SDL_CreateRenderer(window, -1, 0);// orelse {};
    // //
    // //
    // // var running = true;
    // // while (running) {
    // //     var event: c.SDL_Event = undefined;
    // //     while (c.SDL_PollEvent(&event) != 0){
    // //         switch (event.type) {
    // //             c.SDL_QUIT => {
    // //                 running = false;
    // //             },
    // //             else => {}
    // //         }
    // //     }
    // //
    // //     _ = c.SDL_SetRenderDrawColor(renderer, 255, 255,255, 0);
    // //     _ = c.SDL_RenderDrawPoint(renderer, 20, 20);
    // //     _ = c.SDL_RenderPresent(renderer);
    // //     c.SDL_Delay(20);
    // // }
    //
    //
    //
    //
    // // // const screenSurface = c.SDL_GetWindowSurface(window);
    // // // _ = c.SDL_FillRect(screenSurface, null, c.SDL_MapRGB(screenSurface.*.format, 0x00, 0xFF, 0xFF));
    // // // _ = c.SDL_UpdateWindowSurface(window);
    // // // c.SDL_Delay(2000);
    // // // c.SDL_DestroyWindow(window);
    // // // c.SDL_Quit();

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
