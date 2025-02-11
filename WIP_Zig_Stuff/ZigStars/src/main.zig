const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");
const star = @import("stars.zig").Star;

pub fn main() !void {
    const numberOfStars: u16 = 1000;
    var starCollection: [numberOfStars]star = undefined;
    var count: usize = 0;
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    while (count < numberOfStars) {
        starCollection[count] = star.new(400, 300, rand);
        count += 1;
    }

    count = 0;
    while (count < numberOfStars) {
        var s = starCollection[count];
        s.update();
        starCollection[count] = s;
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
        "Zig_Stars_with_sdl2",
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
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0,0, 0);
        _ = c.SDL_RenderClear(renderer);

        count = 0;
        while (count < numberOfStars) {
            var s = starCollection[count];
            s.update();
            starCollection[count].x = s.x;
            starCollection[count].y = s.y;
            starCollection[count].angle = s.angle;
            starCollection[count].speed = s.speed;

            _ = c.SDL_SetRenderDrawColor(renderer, 255, 255,255, 0);
            _ = c.SDL_RenderDrawPoint(renderer, s.x, s.y);

            count += 1;
        }
        _ = c.SDL_RenderPresent(renderer);
        _ = c.SDL_Delay(10);

    }
    c.SDL_DestroyWindow(window);
    c.SDL_Quit();
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
