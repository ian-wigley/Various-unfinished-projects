const std = @import("std");
const mem = std.mem;
const allocator = std.mem.Allocator;
const cpu = @import("cpu.zig").CPU;
const print = std.log.info;


var content = @embedFile("assets/i.rom");

pub fn main() anyerror!void {
    // const romData = try loadRom();
    // print("Size of the array is: {any}", .{romData.len});
    // print("Size of the array is: {any}", .{wrom.len});

    var rommy: [20480]u8 = undefined;
    var index:usize = 0;
    while (index < 8192){
        rommy[index] = content[index];
        index+=1;
    }

    cpu.New(&rommy);

    var crashed = false;
    while (!crashed) {
        crashed = cpu.Run();
    }
    try save_memory(&rommy);
    print("CPU has crashed. {any}", .{crashed});
    print("Iteration {any}", .{cpu.GetIteration()});
}

fn loadRom() anyerror![]u8 {
    var file = try std.fs.cwd().openFile("i.rom", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    print("in_stream buffer length: {any}", .{in_stream.context.buf.len});

    var count: usize = 0;
    const fileLength: usize = in_stream.context.buf.len * 4 + 1001;
    var array: [fileLength]u8 = undefined;

    // Clear down the array
    while (count < array.len) {
        array[count] = 0;
        count += 1;
    }

    print("array data: {any}", .{array[9206]});

    count = 0;
    while (count < 8192) { //in_stream.context.buf.len) { //} * 2) {
        const b = try in_stream.readByte();
        array[count] = b;
        // print("rom bytes: {any} count: {any}", .{array[count], count});
        count += 1;
    }
    print("array length: {any}", .{array.len});
    print("array data: {any}", .{array[9206]});

    var buf: [8192]u8 = undefined;
    const readed = std.fs.File.read(file, &buf);
    print("line: {any}", .{readed});

    return &array;
}

fn save_memory(rom: [] const u8) anyerror!void {
    const file = try std.fs.cwd().createFile(
            "crash_dump.bin",
            .{ .read = true },
        );
    defer file.close();

    const bytes_written = try file.writeAll(rom);
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
