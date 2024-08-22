const std = @import("std");
const io = @import("io.zig");
const fmt = std.fmt;
const print = std.log.info;

pub const CPU = struct {

    var count: usize = 0;
    var m_rom: [] u8 = undefined;

    var m_PC: u16 = 0; // Program Counter: This is the current instruction pointer. 16-bit register.
    var SP: u16 = 0; // Stack Pointer. 16-bit register
    var A: u8 = 0; // Accumulator. 8-bit register
    var B: u8 = 0; // Register B. 8-bit register
    var C: u8 = 0; // Register C. 8-bit register
    var D: u8 = 0; // Register D. 8-bit register
    var E: u8 = 0; // Register E. 8-bit register
    var H: u8 = 0; // Register H. 8-bit register
    var L: u8 = 0; // Register L. 8-bit register
    var BC: u16 = 0; // Virtual register BC (16-bit) combinaison of registers B and C
    var DE: u16 = 0; // Virtual register DE (16-bit) combinaison of registers D and E
    pub var HL: u16 = 0; // Virtual register HL (16-bit) combinaison of registers H and L

    var SIGN: u8 = 0; // Sign flag
    var ZERO: u8 = 0; // Zero flag
    var HALFCARRY: u16 = 0; // Half-carry (or Auxiliary Carry) flag
    var CARRY: u16 = 0; // Carry flag
    var PARITY: bool = false; // Parity flag

    var INTERRUPT: bool = false; // Interrupt Enabled flag
    var CRASHED: bool = false; // Special flag that tells if the CPU is currently crashed (stopped)

    var instruction_per_frame: u16 = 4000; // Approximate real machine speed

    // Interrupt handling
    var interrupt_alternate: u16 = 0;
    var half_instruction_per_frame: u16 = 0;

    // Addionnal debug fields, not used by CPU
    var BIT0: u8 = 1;
    var BIT4: u8 = 16;
    var BIT5: u8 = 32;
    var BIT6: u8 = 64;
    var BIT7: u8 = 128;

    var source: u16 = 0;
    var value: u16 = 0;
    var m_byte: u8 = 0;

    var instructionCounter: u16 = 0;
    var iteration: usize = 0;

    pub fn GetIteration() usize {
        return iteration;
    }

    pub fn New(rom: [] u8) void {
        m_rom = rom;
        print("m_rom data: {any}", .{m_rom[9206]});

        // count = 0;
        // // Clear down the array
        // while (count < rom.len) {
        //     m_rom[count] = 0;
        //     count += 1;
        // }

        // var counter: usize = 0;
        // while (counter < rom.len) {
        //     print("rom bytes: {any} count: {any}", .{m_rom[counter], counter});
        //     counter += 1;
        // }

        io.IO.New();
        half_instruction_per_frame = @as(u16, instruction_per_frame / 2);
        // print("half_instruction_per_frame: {any}", .{half_instruction_per_frame});
        Reset();
    }

    pub fn Run() bool {

        count = 0;
        // clear the slice once per 4000 items
        while (count < instruction_per_frame) {
            ExecuteInstruction();
            count += 1;

            if (CRASHED) {
                print("CRASHED: {any}", .{CRASHED});
                break;
            }
        }
        if (!CRASHED) {
            iteration += 1;
            print("Iteration: {any}", .{iteration});
        }

        return CRASHED;
    }

    // Method assists debugging.
    fn OutputInfo(opcode: [*:0]const u8) void {
        if (iteration > 635) {
            print("Count: {any}, Opcode: {s}, PC: {any}, SP: {any}, A: {any}, B: {any}, C: {any}, D: {any}, E: {any}, H: {any}, L: {any}, BC: {any}, DE: {any}, HL: {any}, SIGN: {any}, ZERO: {any}, HALFCARRY: {any}, PARITY: {any}, CARRY: {any}, INTERRUPT: {any}, 9206: {any}, 9207: {any}, 9210: {any}, 9211: {any}, 9212: {any}, 9213: {any}, 9214: {any}, 9215: {any}", .{ count, opcode, m_PC, SP, A, B, C, D, E, H, L, BC, DE, HL, SIGN, ZERO, HALFCARRY, PARITY, CARRY, INTERRUPT, m_rom[9206], m_rom[9207], m_rom[9210], m_rom[9211], m_rom[9212], m_rom[9213], m_rom[9214], m_rom[9215] });
        }
    }

    // All opcodes are 1 byte wide
    pub fn ExecuteInstruction() void {
        if (!CRASHED) {
            m_byte = FetchRomByte();
            switch (m_byte) {
                0x00 => {
                    NOP();
                    OutputInfo("NOP");
                },
                0xc2, 0xc3, 0xca, 0xd2, 0xda, 0xf2, 0xfa => {
                    Instruction_JMP(m_byte);
                    OutputInfo("JMP");
                },
                0x01, 0x11, 0x21, 0x31 => {
                    Instruction_LXI(m_byte);
                    OutputInfo("LXI");
                },

                0x3e, 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x36 => {
                    Instruction_MVI(m_byte);
                    OutputInfo("MVI");
                },

                0xcd, 0xc4, 0xcc, 0xd4, 0xdc => {
                    Instruction_CALL(m_byte);
                    OutputInfo("CALL");
                },

                0x0a, 0x1a, 0x3a => {
                    Instruction_LDA(m_byte);
                    OutputInfo("LDA");
                },

                0x77, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75 => {
                    Instruction_MOVHL(m_byte);
                    OutputInfo("MOVHL");
                },

                0x03, 0x13, 0x23, 0x33 => {
                    Instruction_INX(m_byte);
                    OutputInfo("INX");
                },

                0x0b, 0x1b, 0x2b, 0x3b => {
                    Instruction_DCX(m_byte);
                    OutputInfo("DCX");
                },

                0x3d, 0x05, 0x0d, 0x15, 0x1d, 0x25, 0x2d, 0x35 => {
                    Instruction_DEC(m_byte);
                    OutputInfo("DEC");
                },

                0x3c, 0x04, 0x0c, 0x14, 0x1c, 0x24, 0x2c, 0x34 => {
                    Instruction_INC(m_byte);
                    OutputInfo("INC");
                },

                0xc9, 0xc0, 0xc8, 0xd0, 0xd8 => {
                    Instruction_RET(m_byte);
                    OutputInfo("RET");
                },

                0x7F, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x47, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x4f, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x57, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56 => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x5f, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x67, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66 => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0x6f, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e => {
                    Instruction_MOV(m_byte);
                    OutputInfo("MOV");
                },

                0xbf, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xfe => {
                    Instruction_CMP(m_byte);
                    OutputInfo("CMP");
                },

                0xc5, 0xd5, 0xe5, 0xf5 => {
                    Instruction_PUSH(m_byte);
                    OutputInfo("PUSH");
                },

                0xc1, 0xd1, 0xe1, 0xf1 => {
                    Instruction_POP(m_byte);
                    OutputInfo("POP");
                },

                0x09, 0x19, 0x29, 0x39 => {
                    Instruction_DAD(m_byte);
                    OutputInfo("DAD");
                },

                0xeb => {
                    Instruction_XCHG();
                    OutputInfo("XCHG");
                },

                0xe3 => {
                    Instruction_XTHL();
                    OutputInfo("XTHL");
                },

                0xd3 => {
                    Instruction_OUTP();
                    OutputInfo("OUTP");
                },

                0xdb => {
                    Instruction_INP();
                    OutputInfo("INP");
                },

                0xe9 => {
                    Instruction_PCHL();
                    OutputInfo("PCHL");
                },

                0xc7, 0xcf, 0xd7, 0xdf, 0xe7, 0xef, 0xf7, 0xff => {
                    Instruction_RST(m_byte);
                    OutputInfo("RST");
                },

                0x07 => {
                    Instruction_RLC();
                    OutputInfo("RLC");
                },

                0x17 => {
                    Instruction_RAL();
                    OutputInfo("RAL");
                },

                0x0f => {
                    Instruction_RRC();
                    OutputInfo("RRC");
                },

                0x1f => {
                    Instruction_RAR();
                    OutputInfo("RAR");
                },

                0xa7, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xe6 => {
                    Instruction_AND(m_byte);
                    OutputInfo("AND");
                },

                0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0xc6 => {
                    Instruction_ADD(m_byte);
                    OutputInfo("ADD");
                },

                0x02, 0x12, 0x32 => {
                    Instruction_STA(m_byte);
                    OutputInfo("STA");
                },

                0xaf, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xee => {
                    Instruction_XOR(m_byte);
                    OutputInfo("XOR");
                },
                0xf3 => {
                    Instruction_DI();
                    OutputInfo("DI");
                },
                0xfb => {
                    Instruction_EI();
                    OutputInfo("EI");
                },
                0x37 => {
                    Instruction_STC();
                    OutputInfo("STC");
                },
                0x3f => {
                    Instruction_CMC();
                    OutputInfo("CMC");
                },
                0xb7, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xf6 => {
                    Instruction_OR(m_byte);
                    OutputInfo("OR");
                },
                0x97, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0xd6 => {
                    Instruction_SUB(m_byte);
                    OutputInfo("SUB");
                },
                0x2a => {
                    Instruction_LHLD();
                    OutputInfo("LHLD");
                },
                0x22 => {
                    Instruction_SHLD();
                    OutputInfo("SHLD");
                },
                0xde => {
                    Instruction_SBBI();
                    OutputInfo("SBBI");
                },
                0x27 => {
                    Instruction_DAA();
                    OutputInfo("DAA");
                },
                0x2f => {
                    Instruction_CMA();
                    OutputInfo("CMA");
                },
                0x8f, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0xce => {
                    Instruction_ADC(m_byte);
                    OutputInfo("ADC");
                },
                else => {
                    CRASHED = true;
                    // print("Emulator Crashed @ instruction : {any}", .{m_instructionCounter});
                    return;
                },
            }

            instructionCounter += 1;

            // // print("m_instructionCounter : {any}", .{m_instructionCounter});
            // // print("half_instruction_per_frame : {any}", .{half_instruction_per_frame});

            if (instructionCounter >= half_instruction_per_frame) {
                if (INTERRUPT) {
                    // There are two interrupts that occur every frame (address $08 and $10)
                    if (interrupt_alternate == 0) {
                        CallInterrupt(0x08);
                    } else {
                        CallInterrupt(0x10);
                    }
                }
                interrupt_alternate = 1 - interrupt_alternate;
                instructionCounter = 0;
            }
        }
    }

    pub fn CallInterrupt(inAddress: u16) void {
        // Call the interrupt by pushing current PC on the stack and then jump to interrupt address
        INTERRUPT = false;
        StackPush(m_PC);
        m_PC = inAddress;
    }

    pub fn NOP() void {
        // No Operation - Do nothing !
    }

    pub fn Instruction_JMP(byte: u8) void {
        const data16: u16 = FetchRomShort();
        var condition = true;

        switch (byte) {
            0xc3 => {
                // Do nothing apart from incrementing the Programme Counter
            },
            0xc2 => {
                condition = !ToBooleanU8(ZERO);
            },
            0xca => {
                condition = ToBooleanU8(ZERO);
            },
            0xd2 => {
                condition = !ToBooleanU16(CARRY);
            },
            0xda => {
                condition = ToBooleanU16(CARRY);
            },
            0xf2 => {
                condition = !ToBooleanU8(SIGN);
            },
            0xfa => {
                condition = ToBooleanU8(SIGN);
            },
            else => {},
        }
        if (condition) {
            m_PC = data16;
        }
    }

    pub fn Instruction_LXI(byte: u8) void {
        switch (byte) {
            0x01 => {
                SetBC(FetchRomShort());
            },
            0x11 => {
                SetDE(FetchRomShort());
            },
            0x21 => {
                SetHL(FetchRomShort());
            },
            0x31 => {
                SetSP(FetchRomShort());
            },
            else => {},
        }
    }

    pub fn Instruction_MVI(byte: u8) void {
        switch (byte) {
            0x3e => {
                SetA(FetchRomByte());
            },
            0x06 => {
                SetB(FetchRomByte());
            },
            0x0e => {
                SetC(FetchRomByte());
            },
            0x16 => {
                SetD(FetchRomByte());
            },
            0x1e => {
                SetE(FetchRomByte());
            },
            0x26 => {
                SetH(FetchRomByte());
            },
            0x2e => {
                SetL(FetchRomByte());
            },
            0x36 => {
                WriteByte(HL, FetchRomByte());
            },
            else => {},
        }
    }

    pub fn Instruction_CALL(byte: u8) void {
        const data16: u16 = FetchRomShort();
        var condition = true;
        switch (byte) {
            0xcd => {},
            0xc4 => {
                condition = !ToBooleanU8(ZERO);
            },
            0xcc => {
                condition = ToBooleanU8(ZERO);
            },
            0xd4 => {
                condition = !ToBooleanU16(CARRY);
            },
            0xdc => {
                condition = ToBooleanU16(CARRY);
            },
            else => {},
        }
        if (condition) {
            StackPush(m_PC);
            m_PC = data16;
        }
    }

    pub fn Instruction_LDA(byte: u8) void {
        switch (byte) {
            0x0a => {
                source = BC;
            },
            0x1a => {
                source = DE;
            },
            0x3a => {
                source = FetchRomShort();
            },
            else => {},
        }
        SetA(ReadByte(source));
    }

    pub fn Instruction_MOVHL(byte: u8) void {
        switch (byte) {
            0x77 => {
                WriteByte(HL, A);
            },
            0x70 => {
                WriteByte(HL, B);
            },
            0x71 => {
                WriteByte(HL, C);
            },
            0x72 => {
                WriteByte(HL, D);
            },
            0x73 => {
                WriteByte(HL, E);
            },
            0x74 => {
                WriteByte(HL, H);
            },
            0x75 => {
                WriteByte(HL, L);
            },
            else => {},
        }
    }

    pub fn Instruction_INX(byte: u8) void {
        switch (byte) {
            0x03 => {
                SetBC(BC + 1);
            },
            0x13 => {
                SetDE(DE + 1);
            },
            0x23 => {
                SetHL(HL + 1);
            },
            0x33 => {
                SetSP(SP + 1);
            },
            else => {},
        }
    }

    pub fn Instruction_DCX(byte: u8) void {
        switch (byte) {
            0x0b => {
                SetBC(BC - 1);
            },
            0x1b => {
                SetDE(DE - 1);
            },
            0x2b => {
                SetHL(HL - 1);
            },
            0x3b => {
                SetSP(SP - 1);
            },
            else => {},
        }
    }

    pub fn Instruction_DEC(byte: u8) void {
        switch (byte) {
            0x3d => {
                SetA(PerformDec(A));
            },
            0x05 => {
                SetB(PerformDec(B));
            },
            0x0d => {
                SetC(PerformDec(C));
            },
            0x15 => {
                SetD(PerformDec(D));
            },
            0x1d => {
                SetE(PerformDec(E));
            },
            0x25 => {
                SetH(PerformDec(H));
            },
            0x2d => {
                SetL(PerformDec(L));
            },
            0x35 => {
                WriteByte(HL, PerformDec(ReadByte(HL)));
            },
            else => {},
        }
    }

    pub fn Instruction_INC(byte: u8) void {
        switch (byte) {
            0x3c => {
                SetA(PerformInc(A));
            },
            0x04 => {
                SetB(PerformInc(B));
            },
            0x0c => {
                SetC(PerformInc(C));
            },
            0x14 => {
                SetD(PerformInc(D));
            },
            0x1c => {
                SetE(PerformInc(E));
            },
            0x24 => {
                SetH(PerformInc(H));
            },
            0x2c => {
                SetL(PerformInc(L));
            },
            0x34 => {
                WriteByte(HL, PerformInc(ReadByte(HL)));
            },
            else => {},
        }
    }

    pub fn Instruction_RET(byte: u8) void {
        var condition = true;
        switch (byte) {
            0xc9 => {},
            0xc0 => {
                condition = !ToBooleanU8(ZERO);
            },
            0xc8 => {
                condition = ToBooleanU8(ZERO);
            },
            0xd0 => {
                condition = !ToBooleanU16(CARRY);
            },
            0xd8 => {
                condition = ToBooleanU16(CARRY);
            },
            else => {},
        }
        if (condition) {
            m_PC = StackPop();
        }
    }

    pub fn Instruction_MOV(byte: u8) void {
        switch (byte) {
            0x7F => {
                SetA(A);
            },
            0x78 => {
                SetA(B);
            },
            0x79 => {
                SetA(C);
            },
            0x7A => {
                SetA(D);
            },
            0x7B => {
                SetA(E);
            },
            0x7C => {
                SetA(H);
            },
            0x7D => {
                SetA(L);
            },
            0x7E => {
                SetA(ReadByte(HL));
            },
            0x47 => {
                SetB(A);
            },
            0x40 => {
                SetB(B);
            },
            0x41 => {
                SetB(C);
            },
            0x42 => {
                SetB(D);
            },
            0x43 => {
                SetB(E);
            },
            0x44 => {
                SetB(H);
            },
            0x45 => {
                SetB(L);
            },
            0x46 => {
                SetB(ReadByte(HL));
            },
            0x4f => {
                SetC(A);
            },
            0x48 => {
                SetC(B);
            },
            0x49 => {
                SetC(C);
            },
            0x4a => {
                SetC(D);
            },
            0x4b => {
                SetC(E);
            },
            0x4c => {
                SetC(H);
            },
            0x4d => {
                SetC(L);
            },
            0x4e => {
                SetC(ReadByte(HL));
            },
            0x57 => {
                SetD(A);
            },
            0x50 => {
                SetD(B);
            },
            0x51 => {
                SetD(C);
            },
            0x52 => {
                SetD(D);
            },
            0x53 => {
                SetD(E);
            },
            0x54 => {
                SetD(H);
            },
            0x55 => {
                SetD(L);
            },
            0x56 => {
                SetD(ReadByte(HL));
            },
            0x5f => {
                SetE(A);
            },
            0x58 => {
                SetE(B);
            },
            0x59 => {
                SetE(C);
            },
            0x5a => {
                SetE(D);
            },
            0x5b => {
                SetE(E);
            },
            0x5c => {
                SetE(H);
            },
            0x5d => {
                SetE(L);
            },
            0x5e => {
                SetE(ReadByte(HL));
            },
            0x67 => {
                SetH(A);
            },
            0x60 => {
                SetH(B);
            },
            0x61 => {
                SetH(C);
            },
            0x62 => {
                SetH(D);
            },
            0x63 => {
                SetH(E);
            },
            0x64 => {
                SetH(H);
            },
            0x65 => {
                SetH(L);
            },
            0x66 => {
                SetH(ReadByte(HL));
            },
            0x6f => {
                SetL(A);
            },
            0x68 => {
                SetL(B);
            },
            0x69 => {
                SetL(C);
            },
            0x6a => {
                SetL(D);
            },
            0x6b => {
                SetL(E);
            },
            0x6c => {
                SetL(H);
            },
            0x6d => {
                SetL(L);
            },
            0x6e => {
                SetL(ReadByte(HL));
            },
            else => {},
        }
    }

    pub fn Instruction_CMP(byte: u8) void {
        switch (byte) {
            0xbf => {
                value = A;
            },
            0xb8 => {
                value = B;
            },
            0xb9 => {
                value = C;
            },
            0xba => {
                value = D;
            },
            0xbb => {
                value = E;
            },
            0xbc => {
                value = H;
            },
            0xbd => {
                value = L;
            },
            0xbe => {
                value = ReadByte(HL);
            },
            0xfe => {
                value = FetchRomByte();
            },
            else => {},
        }
        PerformCompSub(value);
    }

    pub fn Instruction_PUSH(byte: u8) void {
        switch (byte) {
            0xc5 => {
                value = BC;
            },
            0xd5 => {
                value = DE;
            },
            0xe5 => {
                value = HL;
            },
            0xf5 => {
                value = std.math.shl(u16, A, 8);
                SetValueU8(SIGN, BIT7);
                SetValueU8(ZERO, BIT6);
                SetValueInterrupt(INTERRUPT, BIT5);
                SetValueU16(HALFCARRY, BIT4);
                SetValueU16(CARRY, BIT0);
            },
            else => {},
        }
        StackPush(value);
    }

    pub fn Instruction_POP(byte: u8) void {
        value = StackPop();
        switch (byte) {
            0xc1 => {
                SetBC(value);
            },
            0xd1 => {
                SetDE(value);
            },
            0xe1 => {
                SetHL(value);
            },
            0xf1 => {
                A = @intCast(std.math.shr(u16, value, 8));
                SIGN = @truncate(value & 0x80);
                ZERO = @truncate(value & 0x40);
                INTERRUPT = ToBooleanU16(value & 0x20);
                HALFCARRY = value & BIT4;
                CARRY = (value & BIT0);
            },
            else => {},
        }
    }

    pub fn Instruction_DAD(byte: u8) void {
        switch (byte) {
            0x09 => {
                AddHL(BC);
            },
            0x19 => {
                AddHL(DE);
            },
            0x29 => {
                AddHL(HL);
            },
            0x39 => {
                AddHL(SP);
            },
            else => {},
        }
    }

    pub fn Instruction_XCHG() void {
        SetDE(HL);
        SetHL(DE);
    }

    pub fn Instruction_XTHL() void {
        var temp = H;
        SetH(ReadByte(SP + 1));
        WriteByte((SP + 1), temp);
        temp = L;
        SetL(ReadByte(SP));
        WriteByte(SP, temp);
    }

    pub fn Instruction_OUTP() void {
        const port = FetchRomByte();
        io.IO.OutputPort(port, A);
    }

    pub fn Instruction_INP() void {
        const port = FetchRomByte();
        SetA(io.IO.InputPort(port));
    }

    pub fn Instruction_PCHL() void {
        m_PC = HL;
    }

    pub fn Instruction_RST(byte: u8) void {
        var address: u16 = 0;
        switch (byte) {
            0xc7 => {
                address = 0x00;
            },
            0xcf => {
                address = 0x08;
            },
            0xd7 => {
                address = 0x10;
            },
            0xdf => {
                address = 0x18;
            },
            0xe7 => {
                address = 0x20;
            },
            0xef => {
                address = 0x28;
            },
            0xf7 => {
                address = 0x30;
            },
            0xff => {
                address = 0x38;
            },
            else => {},
        }
        StackPush(m_PC);
        m_PC = address;
    }

    pub fn Instruction_RLC() void {
        SetA(((A << 1) | (A >> 7)));
        CARRY = (A & BIT0);
    }

    pub fn Instruction_RAL() void {
        SetA(A << 1);
        if (ToBooleanU16(CARRY)) {
            SetA(A | BIT0);
        }
        CARRY = A & 0x80;
    }

    pub fn Instruction_RRC() void {
        SetA(((A >> 1) | (A << 7)));
        CARRY = (A & BIT7);
    }

    pub fn Instruction_RAR() void {
        SetA((A >> 1));
        if (ToBooleanU16(CARRY)) {
            SetA(A | BIT7);
        }
        CARRY = (A & 1);
    }

    pub fn Instruction_AND(byte: u8) void {
        switch (byte) {
            0xa7 => {
                PerformAnd(A);
            },
            0xa0 => {
                PerformAnd(B);
            },
            0xa1 => {
                PerformAnd(C);
            },
            0xa2 => {
                PerformAnd(D);
            },
            0xa3 => {
                PerformAnd(E);
            },
            0xa4 => {
                PerformAnd(H);
            },
            0xa5 => {
                PerformAnd(L);
            },
            0xa6 => {
                PerformAnd(ReadByte(HL));
            },
            0xe6 => {
                const immediate = FetchRomByte();
                PerformAnd(immediate);
            },
            else => {},
        }
    }

    pub fn Instruction_ADD(byte: u8) void {
        switch (byte) {
            0x87 => {
                PerformByteAdd(A, 0);
            },
            0x80 => {
                PerformByteAdd(B, 0);
            },
            0x81 => {
                PerformByteAdd(C, 0);
            },
            0x82 => {
                PerformByteAdd(D, 0);
            },
            0x83 => {
                PerformByteAdd(E, 0);
            },
            0x84 => {
                PerformByteAdd(H, 0);
            },
            0x85 => {
                PerformByteAdd(L, 0);
            },
            0x86 => {
                PerformByteAdd(ReadByte(HL), 0);
            },
            0xc6 => {
                const immediate = FetchRomByte();
                PerformByteAdd(immediate, 0);
            },
            else => {},
        }
    }

    pub fn Instruction_STA(byte: u8) void {
        switch (byte) {
            0x02 => {
                WriteByte(BC, A);
            },
            0x12 => {
                WriteByte(DE, A);
            },
            0x32 => {
                const immediate = FetchRomShort();
                WriteByte(immediate, A);
            },
            else => {},
        }
    }

    pub fn Instruction_XOR(byte: u8) void {
        switch (byte) {
            0xaf => {
                PerformXor(A);
            },
            0xa8 => {
                PerformXor(B);
            },
            0xa9 => {
                PerformXor(C);
            },
            0xaa => {
                PerformXor(D);
            },
            0xab => {
                PerformXor(E);
            },
            0xac => {
                PerformXor(H);
            },
            0xad => {
                PerformXor(L);
            },
            0xae => {
                PerformXor(ReadByte(HL));
            },
            0xee => {
                const immediate = FetchRomByte();
                PerformXor(immediate);
            },
            else => {},
        }
    }

    pub fn Instruction_DI() void {
        INTERRUPT = false;
    }

    pub fn Instruction_EI() void {
        INTERRUPT = true;
    }

    pub fn Instruction_STC() void {
        CARRY = 1;
    }

    pub fn Instruction_CMC() void {
        CARRY = 0;
    }

    pub fn Instruction_OR(byte: u8) void {
        switch (byte) {
            0xb7 => {
                PerformOr(A);
            },
            0xb0 => {
                PerformOr(B);
            },
            0xb1 => {
                PerformOr(C);
            },
            0xb2 => {
                PerformOr(D);
            },
            0xb3 => {
                PerformOr(E);
            },
            0xb4 => {
                PerformOr(H);
            },
            0xb5 => {
                PerformOr(L);
            },
            0xb6 => {
                PerformOr(ReadByte(HL));
            },
            0xf6 => {
                const immediate = FetchRomByte();
                PerformOr(immediate);
            },
            else => {},
        }
    }

    pub fn Instruction_SUB(byte: u8) void {
        switch (byte) {
            0x97 => {
                PerformByteSub(A, 0);
            },
            0x90 => {
                PerformByteSub(B, 0);
            },
            0x91 => {
                PerformByteSub(C, 0);
            },
            0x92 => {
                PerformByteSub(D, 0);
            },
            0x93 => {
                PerformByteSub(E, 0);
            },
            0x94 => {
                PerformByteSub(H, 0);
            },
            0x95 => {
                PerformByteSub(L, 0);
            },
            0x96 => {
                PerformByteSub(ReadByte(HL), 0);
            },
            0xd6 => {
                const immediate = FetchRomByte();
                PerformByteSub(immediate, 0);
            },
            else => {},
        }
    }

    pub fn Instruction_LHLD() void {
        const immediate = FetchRomShort();
        SetHL(ReadShort(immediate));
    }

    pub fn Instruction_SHLD() void {
        const immediate = FetchRomShort();
        WriteShort(immediate, HL);
    }

    pub fn Instruction_SBBI() void {
        const immediate = FetchRomByte();
        var carryvalue: u8 = 0;
        // TO-DO check
        if (ToBooleanU16(CARRY)) {
            carryvalue = 1;
        }
        PerformByteSub(immediate, carryvalue);
    }

    pub fn Instruction_DAA() void {
        // TO-DO check
        if (((A & 0x0F) > 9) or ToBooleanU16(HALFCARRY)) {
            A += 0x06;
            HALFCARRY = 1;
        } else {
            HALFCARRY = 0;
        }
        // TO-DO check
        if ((A > 0x9F) or ToBooleanU16(CARRY)) {
            A += 0x60;
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        SetFlagZeroSign();
    }

    pub fn Instruction_CMA() void {
        SetA(A ^ 0xff);
    }

    pub fn Instruction_ADC(byte: u8) void {
        var carryvalue: u8 = 0;
        if (ToBooleanU16(CARRY)) {
            carryvalue = 1;
        }
        switch (byte) {
            0x8f => {
                PerformByteAdd(A, carryvalue);
            },
            0x88 => {
                PerformByteAdd(B, carryvalue);
            },
            0x89 => {
                PerformByteAdd(C, carryvalue);
            },
            0x8a => {
                PerformByteAdd(D, carryvalue);
            },
            0x8b => {
                PerformByteAdd(E, carryvalue);
            },
            0x8c => {
                PerformByteAdd(H, carryvalue);
            },
            0x8d => {
                PerformByteAdd(L, carryvalue);
            },
            0x8e => {
                PerformByteAdd(ReadByte(HL), carryvalue);
            },
            0xce => {
                const immediate = FetchRomByte();
                PerformByteAdd(immediate, carryvalue);
            },
            else => {},
        }
    }

    pub fn SetA(inByte: u8) void {
        A = inByte & 0xFF;
    }

    pub fn SetB(inByte: u8) void {
        B = inByte & 0xFF;
        BC = std.math.shl(u16, B, 8) | C;
    }

    pub fn SetC(inByte: u8) void {
        C = inByte & 0xFF;
        BC = std.math.shl(u16, B, 8) | C;
    }

    pub fn SetD(inByte: u8) void {
        D = inByte;
        DE = std.math.shl(u16, D, 8) + E;
    }

    pub fn SetE(inByte: u8) void {
        E = inByte;
        DE = std.math.shl(u16, D, 8) + E;
    }

    pub fn SetH(inByte: u8) void {
        H = inByte;
        HL = std.math.shl(u16, H, 8) + L;
    }

    pub fn SetL(inByte: u8) void {
        L = inByte;
        HL = std.math.shl(u16, H, 8) + L;
    }

    pub fn SetBC(inShort: u16) void {
        BC = inShort;
        B = @truncate(BC >> 8);
        C = @truncate(BC & 0xFF);
    }

    pub fn SetDE(inShort: u16) void {
        DE = inShort;
        D = @truncate(DE >> 8);
        E = @truncate(DE & 0xFF);
    }

    pub fn SetHL(inShort: u16) void {
        HL = inShort;
        H = @truncate(HL >> 8);
        L = @truncate(HL & 0xFF);
    }

    pub fn SetSP(inShort: u16) void {
        SP = inShort;
    }

    pub fn FetchRomByte() u8 {
        const rom_value = m_rom[m_PC];
        // print("Value: {any}", .{value});
        m_PC += 1;
        return rom_value;
    }

    pub fn FetchRomShort() u16 {
        var bytes: [2]u8 = [_]u8{ 0, 0 };
        bytes[0] = m_rom[m_PC + 0];
        bytes[1] = m_rom[m_PC + 1];
        m_PC += 2;
        const result = std.math.shl(u16, (bytes[1] & 0xFF), 8) | (bytes[0] & 0xFF);
        return result;
        // return std.math.shl(u16, (bytes[1] & 0xFF), 8) | (bytes[0] & 0xFF);
    }

    pub fn ReadByte(counter: usize) u8 {
        return m_rom[counter];
    }

    pub fn ReadShort(inAddress: u16) u16 {
        return std.math.shl(u16, m_rom[inAddress + 1], 8) + (m_rom[inAddress + 0]);
    }

    pub fn WriteShort(inAddress: u16, inWord: u16) void {
        m_rom[inAddress + 1] = @intCast(std.math.shr(u16, inWord, 8));
        // print("m_rom[inAddress + 1]: {any}", .{m_rom[inAddress + 1]});
        m_rom[inAddress + 0] = @truncate(inWord);
        // print("m_rom[inAddress + 0]: {any}", .{m_rom[inAddress + 0]});
    }

    pub fn WriteByte(inAddress: u16, inByte: u8) void {
        if (inAddress < m_rom.len) {
            m_rom[inAddress] = inByte;
        } else {
            print("Overflow occurred: {any}", .{m_rom.len});
            print("Overflow occurred: {any}", .{inAddress});
        }
    }

    pub fn StackPush(inValue: u16) void {
        if (SP > 1) {
            SP -= 2;
            WriteShort(SP, inValue);
        }
    }

    pub fn StackPop() u16 {
        const temp = ReadShort(SP);
        SP += 2;
        return temp;
    }

    pub fn PerformDec(inSource: u16) u8 {
        // const value: u16 = @intCast((inSource - 1) & 0xFF);
        const cast: i16 = @intCast(inSource);
        const localValue: u16 = @intCast((cast - 1) & 0xFF);
        HALFCARRY = @intFromBool((localValue & 0x0F) == 0);
        ZERO = @intFromBool((localValue & 255) == 0);
        SIGN = @truncate(localValue & 128);
        const return_value:u8 = @intCast(localValue);
        return return_value;
    }

    pub fn PerformInc(inSource: u8) u8 {
        const localValue = inSource + 1;
        HALFCARRY = @intFromBool(((localValue & 0xF) < 0) or ((localValue & 0xF) > 0));
        ZERO = @intFromBool((localValue & 255) == 0);
        SIGN = @truncate(localValue & 128);
        return value;
    }

    pub fn SetFlagZeroSign() void {
        ZERO = @intFromBool(A == 0);
        SIGN = @truncate(A & 128);
    }

    pub fn PerformAnd(inValue: u8) void {
        SetA(A & inValue);
        CARRY = 0;
        HALFCARRY = 0;
        SetFlagZeroSign();
    }

    pub fn PerformXor(inValue: u8) void {
        SetA(A ^ inValue);
        CARRY = 0;
        HALFCARRY = 0;
        SetFlagZeroSign();
    }

    fn PerformOr(inValue: u8) void {
        SetA(A | inValue);
        CARRY = 0;
        HALFCARRY = 0;
        SetFlagZeroSign();
    }

    pub fn PerformByteAdd(inValue: u8, inCarryValue: u8) void {
        const localValue = A + inValue + inCarryValue;
        // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
        HALFCARRY = (A ^ inValue ^ localValue) & 0x10;
        SetA(localValue);
        if (localValue > 255) {
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        SetFlagZeroSign();
    }

    pub fn PerformByteSub(inValue: u8, inCarryValue: u8) void {
        const localValue: u8 = (A - inValue - inCarryValue);
        if ((localValue >= A) and (inValue | inCarryValue) > 0) {
            CARRY = 1;
        } else {
            CARRY = 0;
        }
        // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
        HALFCARRY = (A ^ inValue ^ localValue) & 0x10;
        SetA(localValue);
        SetFlagZeroSign();
    }

    pub fn PerformCompSub(inValue: u16) void {
        const cast: i16 = @intCast(inValue);
        // const value: i16 = @intCast((A - inValue) & 0xFF);
        const localValue: i16 = @intCast((A - cast) & 0xFF);
        if ((value >= A) and ToBooleanU16(inValue)) {
            CARRY = inValue;
        } else {
            CARRY = 0;
        }
        // print("PerformCompSub CARRY: {any}", .{CARRY});
        // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
        const tempA: u16 = A;
        const tempValue: u16 = @intCast(localValue);
        HALFCARRY = (tempA ^ inValue ^ tempValue) & 0x10;

        // print("PerformCompSub HALFCARRY: {any}", .{HALFCARRY});
        ZERO = @intFromBool(localValue == 0);
        // print("PerformCompSub ZERO: {any}", .{ZERO});
        // SIGN = @truncate(value & 128);
        SIGN = @intCast(localValue & 128);
        // print("PerformCompSub SIGN: {any}", .{SIGN});
    }

    pub fn AddHL(inValue: u16) void {
        const localValue = HL + inValue;
        SetHL(localValue);
        CARRY = @intFromBool(localValue > 65535);
    }

    // TODO - Temp method
    pub fn SetValueU8(inValue: u8, bit: u8) void {
        const conv: u16 = @intCast(inValue);
        if (conv != 0) {
            inValue = (inValue | bit);
        } else {
            _ = conv == 0;
        }
    }

    // TODO - Temp method
    pub fn SetValueU16(inValue: u16, bit: u8) void {
        const conv: u16 = @intCast(inValue);
        if (conv != 0) {
            inValue = (inValue | bit);
        } else {
            _ = conv == 0;
        }
    }

    pub fn SetValueInterrupt(inValue: bool, bit: u8) void {
        const fudge: bool = inValue;
        if (fudge) {
            inValue = (inValue | bit);
        } else {
            _ = fudge == false;
        }
    }

    // https://github.com/microsoft/referencesource/blob/master/mscorlib/system/convert.cs
    pub fn ToBooleanU8(inValue: u8) bool {
        return inValue != 0;
    }

    pub fn ToBooleanU16(inValue: u16) bool {
        return inValue != 0;
    }

    pub fn Reset() void {
        m_PC = 0;
        A = 0;
        BC = 0;
        DE = 0;
        HL = 0;
        SIGN = 0;
        ZERO = 0;
        HALFCARRY = 0;
        PARITY = false;
        CARRY = 0;
        INTERRUPT = false;
        CRASHED = false;
    }
};
