const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");
const star = @import("stars.zig").Star;

pub fn main() !void {
    var star_collection: [10]star = undefined;
    var count: usize = 0;

    while (count < 10) {
        star_collection[count] = star.new(12, 255);
        count += 1;
    }

    count = 0;
    while (count < 10) {
        var s = star_collection[count];
        s.update();
        star_collection[count] = s;
        count += 1;
    }

    // for (no) |f| {
    //     f.update();
    // }

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Failed to initialise SDL: %s", c.SDL_GetError());
        return error.SDLInitialisationFailure;
    }

    const window = c.SDL_CreateWindow(
        "hello_sdl2",
        c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED,
        800, 600,
        c.SDL_WINDOW_SHOWN
    );

    const renderer = c.SDL_CreateRenderer(window, -1, 0);// orelse {};


    var running = true;
    while (running) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0){
            switch (event.type) {
                c.SDL_QUIT => {
                    running = false;
                },
                else => {}
            }



            // for (star_collection) |s| {
            //     s.update();
            // }
        }


        count = 0;
        while (count < 10) {
            var s = star_collection[count];
            s.update();
            star_collection[count].x = s.x;
            star_collection[count].y = s.y;
            // star_collection[count] = s;
            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255,255, 0);
            _ = c.SDL_RenderDrawPoint(renderer, s.x, s.y);
            _ = c.SDL_RenderPresent(renderer);
            // c.SDL_Delay(20);
            count += 1;
        }



    }

    // // // const screenSurface = c.SDL_GetWindowSurface(window);
    // // // _ = c.SDL_FillRect(screenSurface, null, c.SDL_MapRGB(screenSurface.*.format, 0x00, 0xFF, 0xFF));
    // // // _ = c.SDL_UpdateWindowSurface(window);
    // // // c.SDL_Delay(2000);
    // // // c.SDL_DestroyWindow(window);
    // // // c.SDL_Quit();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
