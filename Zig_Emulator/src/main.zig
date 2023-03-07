const std = @import("std");
const mem = std.mem;
const allocator = std.mem.Allocator;
const cpu = @import("CPU.zig");
const print = std.log.info;

pub fn main() anyerror!void {
    var romData = try loadRom();
    // print("Size of the array is: {any}", .{array.len});
    // print("Array index: {any}", .{array[1]});

    cpu.CPU.New(romData);

    var crashed = false;
    while (!crashed) {
        crashed = cpu.CPU.Run();
    }
    print("CPU has crashed. {any}", .{crashed});
}

fn loadRom() anyerror![]u8 {
    var file = try std.fs.cwd().openFile("i.rom", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    // print("in_stream: {any}", .{in_stream.context.buf.len});

    var count: usize = 0;
    var array: [in_stream.context.buf.len * 4  + 1001]u8 = undefined;

    // Clear down the array
    while (count < array.len) {
        array[count] = 0;
        count +=1;
    }
    count = 0;

    while (count < in_stream.context.buf.len * 2) {
        var b = try in_stream.readByte();
        // print("rom bytes: {any}", .{b});
        array[count] = b;
        count += 1;
    }
    // print("array length: {any}", .{array.len});
    return &array;
}
