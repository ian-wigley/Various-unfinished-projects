const std = @import("std");
const expect = std.testing.expect;
const cpu = @import("CPU.zig");

pub fn main() void {
   std.log.info("m_byte: ", .{});
}

test "AddHL" {
    cpu.CPU.AddHL(1);
    try expect(cpu.CPU.HL == 1);
}
