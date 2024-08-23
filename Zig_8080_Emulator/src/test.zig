const std = @import("std");
const expect = std.testing.expect;
const cpu = @import("cpu.zig");

//***********************************************************************//
//
// Run all tests with        : zig test src/test.zig
// Run individual tests with : zig test src/test.zig --test-filter "AddHL"
//
//***********************************************************************//

pub fn main() void {
    std.log.info("m_byte: ", .{});
}

test "New" {}

test "Run" {}

test "ExecuteInstruction" {}

test "CallInterrupt" {}

test "NOP" {}

test "Instruction_JMP" {
    cpu.CPU.Instruction_JMP(1);
    const result = cpu.CPU.GetPC();
    try expect(result == 1);
}

// test "Instruction_LXI" {}
//
// test "Instruction_MVI" {}
//
// test "Instruction_CALL" {}
//
// test "Instruction_LDA" {}
//
// test "Instruction_MOVHL" {}
//
// test "Instruction_INX" {}
//
// test "Instruction_DCX" {}
//
// test "Instruction_DEC" {}
//
// test "Instruction_INC" {}
//
// test "Instruction_RET" {}
//
// test "Instruction_MOV" {}
//
// test "Instruction_CMP" {}
//
// test "Instruction_PUSH" {}
//
// test "Instruction_POP" {}
//
// test "Instruction_DAD" {}
//
// test "Instruction_XCHG" {}
//
// test "Instruction_XTHL" {}
//
// test "Instruction_OUTP" {}
//
// test "Instruction_INP" {}
//
// test "Instruction_PCHL" {}
//
// test "Instruction_RST" {}
//
// test "Instruction_RLC" {}
//
// test "Instruction_RAL" {}
//
// test "Instruction_RRC" {}
//
// test "Instruction_RAR" {}
//
// test "Instruction_AND" {}
//
// test "Instruction_ADD" {}
//
// test "Instruction_STA" {}
//
// test "Instruction_XOR" {}
//
// test "Instruction_DI" {}
//
// test "Instruction_EI" {}
//
// test "Instruction_STC" {}
//
// test "Instruction_CMC" {}
//
// test "Instruction_OR" {}
//
// test "Instruction_SUB" {}
//
// test "Instruction_LHLD" {}
//
// test "Instruction_SHLD" {}
//
// test "Instruction_SBBI" {}
//
// test "Instruction_DAA" {}
//
// test "Instruction_CMA" {}
//
// test "Instruction_ADC" {}
//
// test "SetA" {}
//
// test "SetB" {}
//
// test "SetC" {}
//
// test "SetD" {}
//
// test "SetE" {}
//
// test "SetH" {}
//
// test "SetL" {}
//
// test "SetBC" {}
//
// test "SetDE" {}
//
// test "SetHL" {}
//
// test "SetSP" {}
//
// test "FetchRomByte" {}
//
// test "FetchRomShort" {}
//
// test "ReadByte" {}
//
// test "ReadShort" {}
//
// test "WriteShort" {
//     cpu.CPU.WriteShort(1, 2);
//     try expect(cpu.CPU.HL == 1);
// }
//
// test "WriteByte" {}
//
// test "StackPush" {}
//
// test "StackPop" {}
//
// test "PerformDec" {
//     const result = cpu.CPU.PerformDec(0);
//     try expect(result == 255);
// }
//
// test "PerformInc" {}
//
// test "setFlagZeroSign" {}
//
// test "PerformAnd" {}
//
// test "PerformXor" {}
//
// test "PerformOr" {}
//
// test "PerformByteAdd" {}
//
// test "PerformByteSub" {}
//
// test "PerformCompSub" {}
//
// test "AddHL" {
//     cpu.CPU.AddHL(1);
//     try expect(cpu.CPU.HL == 1);
// }

// test "Reset" {}
