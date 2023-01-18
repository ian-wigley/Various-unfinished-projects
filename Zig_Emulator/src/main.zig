const std = @import("std");
const mem = std.mem;
const allocator = std.mem.Allocator;
const cpu = @import("CPU.zig");

pub fn main() anyerror!void {
    var array = try loadRom();
    std.log.info("Size of the array is: {any}", .{array.len});
    std.log.info("Array index: {any}", .{array[1]});
    cpu.CPU.New(array);

    while (true) {
        cpu.CPU.Run();
    }
}

fn loadRom() anyerror![]u8 {
    var file = try std.fs.cwd().openFile("i.rom", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    std.log.info("in_stream: {any}", .{in_stream.context.buf.len});

    var count: usize = 0;
    var array: [in_stream.context.buf.len * 4]u8 = undefined;

    while (count < in_stream.context.buf.len * 2) {
        var b = try in_stream.readByte();
        // std.log.info("rom bytes: {any}", .{b});
        array[count] = b;
        count += 1;
    }
    std.log.info("array length: {any}", .{array.len});
    return &array;
}

// test "basic test" {
//     try std.testing.expectEqual(10, 3 + 7);
// }


