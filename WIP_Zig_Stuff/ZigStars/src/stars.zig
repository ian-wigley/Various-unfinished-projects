pub const Star = struct {
    // speed: f64,
    a: u16,
    b: u64,
    c: u16,
    // angle: f64,
    // x: f64,
    // y: f64,
    // colour: String,
    // width: f64,
    // height: f64,

    pub fn new(x: u16, y: u16) Star {
        return Star{
            // .speed= 0.0,
            //  .angle = 360.0,
            .a = x,
            .b = 1,
            .c = y,
            //.colour = colour,
            // .width = x,
            // .height = y,
        };
    }

    pub fn update(self: *Star) void {
        self.a += 1;
        // self.speed += 0.1;
        // self.angle += 0.025;
        // self.x = f64::cos(self.angle) * self.speed + self.x;
        // self.y = f64::sin(self.angle) * self.speed + self.y;
        // if self.x < 0.0 || self.x > self.width || self.y < 0.0 || self.y > self.height {
        // self.angle = 360.0 * rng.gen::<f64>();
        // self.speed = 0.01;
        // self.x = self.width / 2.0;
        // self.y = self.height / 2.0;
        // }
        // }
    }
};
