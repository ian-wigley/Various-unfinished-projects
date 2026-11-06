const std = @import("std");
const Io = std.Io;
const mem = std.mem;
// const allocator = std.mem.Allocator;
const allocator = std.heap.page_allocator;
const CPU = @import("cpu.zig").CPU;
const print = std.log.info;
var content = @embedFile("./assets/i.rom");
pub var in :std.process.Init = undefined;

pub fn main(init: std.process.Init) anyerror!void {

    in = init;
    const rom = try configureRomData();
    defer allocator.free(rom);

    var cpu = CPU.New(rom, init.io);

    var crashed = false;
    while (!crashed) {
        crashed = try cpu.Run();
    }
    try save_memory(rom, init);
    print("CPU has crashed. {any}", .{crashed});
    print("Iteration {any}", .{cpu.GetIteration()});
}

pub fn configureRomData() ![]u8 {
    var input = try allocator.alloc(u8, 20480);
    @memset(input[0..], 0);
    var index: usize = 0;
    while (index < 8192) {
        input[index] = content[index];
        index += 1;
    }
    print("input[9212]. {any}", .{input[9212]});
    return input;
}

fn save_memory(rom: []const u8, init: std.process.Init) anyerror!void {
    const file = try std.Io.Dir.cwd().createFile(
        init.io,
        "crash_dump.bin",
        .{},
    );
    defer file.close(init.io);

    const bytes_written = try file.writeStreamingAll(init.io, rom);
    _ = bytes_written;
}

// // https://github.com/daneelsan/minimal-zig-wasm-canvas/blob/master/checkerboard.zig
// const checkerboard_size: usize = 8;

// // 8 x 8 pixels, where each pixel is 4 bytes (rgba)
// var checkerboard_buffer = std.mem.zeroes([checkerboard_size][checkerboard_size][4]u8);

// // The returned pointer will be used as an offset integer to the wasm memory
// export fn getCheckerboardBufferPointer() [*]u8 {
//     return @ptrCast([*]u8, &checkerboard_buffer);
// }

fn DrawVertical() void {
    // if (rom.Count() > 0)
    // {
    //     // Number of channels (ie. assuming 24 bit RGB in this case)
    //     int ch = 1;
    //     byte[] imageData = new byte[256 * 256 * ch];
    //     int pitch = 256;

    //     for (int j = 0; j < 224; j++)
    //     {
    //         int src = 0x2400 + (j << 5);
    //         int dst = 255 * pitch + j;

    //         for (int i = 0; i < 32; i++)
    //         {
    //             int vram = rom[src];
    //             src += 1;

    //             /*
    //              *  Screen data is located at hex: $2400 dec: 9216
    //              *
    //              *  Each line is made up of 256 pixels
    //              *  Each byte contains 8 pixels worth of data (8 bits in 1 byte)
    //              *  Each line consists of 32 bytes (32 * 8 = 256)
    //              */

    //             for (int bit = 0; bit < 8; bit++)
    //             {
    //                 byte color0 = 0x00;
    //                 byte color1 = 0x00;

    //                 if ((vram & 1) != 0)
    //                 {
    //                     color0 = 0xff;
    //                     color1 = 0xff;
    //                 }
    //                 imageData[dst + 0] = color0;
    //                 imageData[dst + 1] = color1;

    //                 dst -= pitch;
    //                 vram = vram >> 1;
    //             }
    //         }
    //     }
    // }
}
