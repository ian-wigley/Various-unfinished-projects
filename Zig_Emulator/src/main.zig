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
    std.log.info("in_stream: {any}", .{in_stream.context.fifo.count});

    var count: usize = 0;
    var array: [in_stream.context.fifo.buf.len]u8 = undefined;

    while (count < in_stream.context.fifo.buf.len) {
        var b = try in_stream.readByte();
        array[count] = b;
        count += 1;
    }
    return &array;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}


