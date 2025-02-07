const std = @import("std");

pub const Star = struct {
    x: c_int,
    y: c_int,
    z: u16,
    angle: f64,
    speed: f64,
    width: c_int,
    height: c_int,
    random: std.Random,
    // colour: String,

    pub fn new(x: u16, y: u16, rand: std.Random) Star {
        return Star {
            .x = x,
            .y = y,
            .z = y,
            .speed= 0.1,
            .angle = 360,
            .width = 800,
            .height = 600,
            .random = rand,
            //.colour = colour,
        };
    }

    pub fn update(self: *Star) void {

        self.x += 1;
        self.y += 1;
        self.speed += 0.1;
        self.angle += 0.025;
        const temp: f64 = @sin(self.angle) * self.speed;
        const pain: i32 = @intFromFloat(temp);
        self.x = pain + self.x;
        self.y = pain + self.x;
        if (self.x < 0 or self.x > self.width or self.y < 0 or self.y > self.height) {
            self.angle = 360; // * rng.gen::<f64>();
            self.speed = 0.01;
            self.x = 400;
            self.y = 300;
        }
    }
};
