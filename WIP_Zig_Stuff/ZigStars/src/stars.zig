const std = @import("std");
const print = std.log.info;

pub const Star = struct {
    x: c_int,
    y: c_int,
    z: i32,
    angle: f64,
    speed: f64,
    width: c_int,
    height: c_int,
    rand: std.Random,

    pub fn new(x: i32, y: i32, rand: std.Random) Star {
        return Star {
            .x = x,
            .y = y,
            .z = 0,
            .angle = @floatFromInt(rand.intRangeAtMost(u16, 0, 360)),
            .speed= 0.0,
            .width = 800,
            .height = 600,
            .rand = rand,
        };
    }

    pub fn update(self: *Star) void {
        self.speed = self.speed - 0.0175;
        self.angle = self.angle + 0.025;
        // print("Angle:  {any}", .{self.angle});
        const tempX: f64 = @sin(self.angle) * self.speed * 10;
        const tempY: f64 = @cos(self.angle) * self.speed * 10;
        const painX: i32 = @intFromFloat(tempX);
        const painY: i32 = @intFromFloat(tempY);
        self.x = painX + self.x;
        self.y = painY + self.y;
        if (self.x < 0 or self.x > self.width or self.y < 0 or self.y > self.height) {
            // print("Angle before update: {any}", .{self.angle});
            const t: f64 = @floatFromInt(self.rand.intRangeAtMost(u16, 0, 360));
            self.angle = t * 3.142/180;
            self.speed = 0.01;
            self.x = 400;
            self.y = 300;
            // print("Angle after update: {any}", .{self.angle});
            //
            }
    }
};
