// The CPU emulation code
const std = @import("std");
const iO = @import("io.zig").IO;
const fmt = std.fmt;
const print = std.log.info;
const traceEntry = @import("trace.zig").TraceEntry;
const allocator = std.heap.page_allocator;
const bufPrint = std.fmt.bufPrint;

pub const CPU = struct {

    rom: []u8,
    pc: u16 = 0,
    sp: u16 = 0,

    // 8-bit registers
    a: u8 = 0,
    b: u8 = 0,
    c: u8 = 0,
    d: u8 = 0,
    e: u8 = 0,
    h: u8 = 0,
    l: u8 = 0,

    // Virtual 16-bit pairs (kept in sync by the setters)
    bc: u16 = 0,
    de: u16 = 0,
    hl: u16 = 0,

    // Flags
    sign: bool = false,
    zero: bool = false,
    carry: bool = false,
    half_carry: bool = false,
    parity: bool = false,
    interrupt: bool = false,

    half_instruction_per_frame: u16 = 0,
    localInit: std.Io = undefined,

    iteration: usize = 0,
    source: u16 = 0,
    value: u16 = 0,

    m_byte: u8 = 0,
    CRASHED: bool = false,

    // Additional debug fields, not used by CPU
    BIT0: u8 = 1,
    BIT4: u8 = 16,
    BIT5: u8 = 32,
    BIT6: u8 = 64,
    BIT7: u8 = 128,

    instructionCounter: u16 = 0,
    count: usize = 0,

    interrupt_alternate: u16 = 0,



    const instruction_per_frame: u16 = 4000; // Approximate real machine speed
    pub var singleIterationTrace: [4000]traceEntry = undefined;
    pub var singleIterationTraceIndex: usize = 0;

    var iterationTraces: [1024]traceEntry = undefined;
    var iterationTracesIndex: usize = 0;

    pub fn GetIteration(self: *CPU) usize {
        return self.iteration;
    }

    pub fn GetPC(self: *CPU) u16 {
        return self.PC;
    }

    pub fn New(inRom: []u8, io: std.Io) CPU {
        //Reset();
        return CPU {
            .rom = inRom,
            .localInit = io,
            // // print("rom[9212]. {any}", .{rom[9212]});
            // .half_instruction_per_frame = @as(u16, .instruction_per_frame / 2)
            .half_instruction_per_frame = instruction_per_frame / 2
        };
        // print("half_instruction_per_frame: {any}", .{half_instruction_per_frame});
    }

    pub fn Run(self: *CPU) anyerror!bool {
        print("==================Starting-Iteration-{any}================",.{self.iteration});
        self.count = 0;
        while (self.count < instruction_per_frame) {
            try self.ExecuteInstruction();
            self.count += 1;

            if (self.CRASHED) {
                try self.WriteOutTraceInformation();
                print("CRASHED: {any}", .{self.CRASHED});
                break;
            }
        }
        if (!self.CRASHED) {
            try self.PopulateIterationsTraceInformation("na");
            self.iteration += 1;
            print("==================Iteration-{any}================",.{self.iteration});
            // if (self.iteration == 2) {
            //     const stop = true;
            //     _ = stop;
            //     self.CRASHED = true;
            // }
            // print("Iteration: {any}", .{iteration});
        }

        return self.CRASHED;
    }

    pub fn PopulateIterationsTraceInformation(self: *CPU, opcode: [*:0]const u8) !void {
        iterationTraces[iterationTracesIndex % iterationTraces.len] = try self.PopulateTrace(opcode);
        iterationTracesIndex += 1;
    }

    fn PopulateTrace(self: *CPU, opcode: [*:0]const u8) !traceEntry {
        var memory = std.AutoHashMap(u16, u8).init(allocator);
        try memory.put(9206, self.rom[9206]);
        try memory.put(9207, self.rom[9207]);
        try memory.put(9210, self.rom[9210]);
        try memory.put(9211, self.rom[9211]);
        try memory.put(9212, self.rom[9212]);
        try memory.put(9213, self.rom[9213]);
        try memory.put(9214, self.rom[9214]);
        try memory.put(9215, self.rom[9215]);

        return .{ .iteration = self.iteration,
            .opcode = opcode,
            .m_byte = self.m_byte,
            .pc = self.pc,
            .sp = self.sp,
            .a = self.a,
            .b = self.b,
            .c = self.c,
            .d = self.d,
            .e = self.e,
            .h = self.h,
            .l = self.l,
            .bc = self.bc,
            .de = self.de,
            .hl = self.hl,
            .sign = self.sign,
            .zero = self.zero,
            .halfcarry = self.half_carry,
            .parity = self.parity,
            .carry = self.carry,
            .interrupt = self.interrupt,
            .memory = memory };
    }

    // Method assists debugging.
    fn OutputInfo(self: *CPU, opcode: [*:0]const u8) anyerror!void {
        singleIterationTrace[singleIterationTraceIndex % singleIterationTrace.len] = try self.PopulateTrace(opcode);
        singleIterationTraceIndex += 1;
        print("Opcode: {s}, rom[9212]: {any}", .{opcode, self.rom[9212]});
        // print("rom[9212]: {any}",.{rom[9212]});
        // print("rom[9212]. {any}", .{rom[9212]});

    // if (iteration > 634) {
    //     print("Count: {any}, Opcode: {s}, PC: {any}, SP: {any}, A: {any}, B: {any}, C: {any}, D: {any}, E: {any}, H: {any}, L: {any}, BC: {any}, DE: {any}, HL: {any}, " ++
    //         "SIGN: {any}, ZERO: {any}, HALFCARRY: {any}, PARITY: {any}, CARRY: {any}, INTERRUPT: {any}, 9206: {any}, 9207: {any}, 9210: {any}, 9211: {any}, 9212: {any}, " ++
    //         "9213: {any}, 9214: {any}, 9215: {any}", .{ count, opcode, PC, SP, A, B, C, D, E, H, L, BC, DE, HL, SIGN, ZERO, HALFCARRY, PARITY, CARRY, INTERRUPT, rom[9206], rom[9207], rom[9210], rom[9211], rom[9212], rom[9213], rom[9214], rom[9215] });
    // }
    }

    pub fn WriteOutSingleTraceInformation(self: *CPU) anyerror!void {
        const cwd = std.Io.Dir.cwd();
        var b: [50]u8 = undefined;

        const filename = try bufPrint(&b, "zig_per_iteration_trace_{any}.txt", .{self.iteration});
        var file = try cwd.createFile(self.localInit, filename, .{});
        defer file.close(self.localInit);

        var buffer: [4096]u8 = undefined;
        var file_writer = file.writerStreaming(self.localInit, &buffer);
        const writer = &file_writer.interface;

        const counter = @min(singleIterationTraceIndex, singleIterationTrace.len);
        for (singleIterationTrace[0..counter]) |entry| {
            try entry.write(writer, self.rom);
        }

        try writer.flush();
    }

    pub fn WriteOutTraceInformation(self: *CPU) anyerror!void {
        const cwd = std.Io.Dir.cwd();
        var file = try cwd.createFile(self.localInit, "zig_iterations_trace.txt", .{});
        defer file.close(self.localInit);

        var buffer: [4096]u8 = undefined;
        var file_writer = file.writerStreaming(self.localInit, &buffer);
        const writer = &file_writer.interface;

        const counter = @min(iterationTracesIndex, iterationTraces.len);
        for (iterationTraces[0..counter]) |entry| {
            try entry.write(writer, self.rom);
            //print("entry : {any}", .{entry});
        }

        try writer.flush();
    }

    // All opcodes are 1 byte wide
    pub fn ExecuteInstruction(self: *CPU) anyerror!void {
        if (!self.CRASHED) {
            //self.m_byte = self.FetchRomByte();
            const m_byte = self.FetchRomByte();
            switch (m_byte) {
                0x00 => {
                    self.NOP();
                    try self.OutputInfo("NOP");
                },
                0xc2, 0xc3, 0xca, 0xd2, 0xda, 0xf2, 0xfa => {
                    self.Instruction_JMP(m_byte);
                    try self.OutputInfo("JMP");
                },
                0x01, 0x11, 0x21, 0x31 => {
                    self.Instruction_LXI(m_byte);
                    try self.OutputInfo("LXI");
                },

                0x3e, 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x36 => {
                    self.Instruction_MVI(m_byte);
                    try self.OutputInfo("MVI");
                },

                0xcd, 0xc4, 0xcc, 0xd4, 0xdc => {
                    self.Instruction_CALL(m_byte);
                    try self.OutputInfo("CALL");
                },

                0x0a, 0x1a, 0x3a => {
                    self.Instruction_LDA(m_byte);
                    try self.OutputInfo("LDA");
                },

                0x77, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75 => {
                    self.Instruction_MOVHL(m_byte);
                    try self.OutputInfo("MOVHL");
                },

                0x03, 0x13, 0x23, 0x33 => {
                    self.Instruction_INX(m_byte);
                    try self.OutputInfo("INX");
                },

                0x0b, 0x1b, 0x2b, 0x3b => {
                    self.Instruction_DCX(m_byte);
                    try self.OutputInfo("DCX");
                },

                0x3d, 0x05, 0x0d, 0x15, 0x1d, 0x25, 0x2d, 0x35 => {
                    self.Instruction_DEC(m_byte);
                    try self.OutputInfo("DEC");
                },

                0x3c, 0x04, 0x0c, 0x14, 0x1c, 0x24, 0x2c, 0x34 => {
                    self.Instruction_INC(m_byte);
                    try self.OutputInfo("INC");
                },

                0xc9, 0xc0, 0xc8, 0xd0, 0xd8 => {
                    self.Instruction_RET(m_byte);
                    try self.OutputInfo("RET");
                },

                0x7F, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x47, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46 => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x4f, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x57, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56 => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x5f, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x67, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66 => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0x6f, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e => {
                    self.Instruction_MOV(m_byte);
                    try self.OutputInfo("MOV");
                },

                0xbf, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xfe => {
                    self.Instruction_CMP(m_byte);
                    try self.OutputInfo("CMP");
                },

                0xc5, 0xd5, 0xe5, 0xf5 => {
                    self.Instruction_PUSH(m_byte);
                    try self.OutputInfo("PUSH");
                },

                0xc1, 0xd1, 0xe1, 0xf1 => {
                    self.Instruction_POP(m_byte);
                    try self.OutputInfo("POP");
                },

                0x09, 0x19, 0x29, 0x39 => {
                    self.Instruction_DAD(m_byte);
                    try self.OutputInfo("DAD");
                },

                0xeb => {
                    self.Instruction_XCHG();
                    try self.OutputInfo("XCHG");
                },

                0xe3 => {
                    self.Instruction_XTHL();
                    try self.OutputInfo("XTHL");
                },

                0xd3 => {
                    self.Instruction_OUTP();
                    try self.OutputInfo("OUTP");
                },

                0xdb => {
                    self.Instruction_INP();
                    try self.OutputInfo("INP");
                },

                0xe9 => {
                    self.Instruction_PCHL();
                    try self.OutputInfo("PCHL");
                },

                0xc7, 0xcf, 0xd7, 0xdf, 0xe7, 0xef, 0xf7, 0xff => {
                    self.Instruction_RST(m_byte);
                    try self.OutputInfo("RST");
                },

                0x07 => {
                    self.Instruction_RLC();
                    try self.OutputInfo("RLC");
                },

                0x17 => {
                    self.Instruction_RAL();
                    try self.OutputInfo("RAL");
                },

                0x0f => {
                    self.Instruction_RRC();
                    try self.OutputInfo("RRC");
                },

                0x1f => {
                    self.Instruction_RAR();
                    try self.OutputInfo("RAR");
                },

                0xa7, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xe6 => {
                    self.Instruction_AND(m_byte);
                    try self.OutputInfo("AND");
                },

                0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0xc6 => {
                    self.Instruction_ADD(m_byte);
                    try self.OutputInfo("ADD");
                },

                0x02, 0x12, 0x32 => {
                    self.Instruction_STA(m_byte);
                    try self.OutputInfo("STA");
                },

                0xaf, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xee => {
                    self.Instruction_XOR(m_byte);
                    try self.OutputInfo("XOR");
                },
                0xf3 => {
                    self.Instruction_DI();
                    try self.OutputInfo("DI");
                },
                0xfb => {
                    self.Instruction_EI();
                    try self.OutputInfo("EI");
                },
                0x37 => {
                    self.Instruction_STC();
                    try self.OutputInfo("STC");
                },
                0x3f => {
                    self.Instruction_CMC();
                    try self.OutputInfo("CMC");
                },
                0xb7, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xf6 => {
                    self.Instruction_OR(m_byte);
                    try self.OutputInfo("OR");
                },
                0x97, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0xd6 => {
                    self.Instruction_SUB(m_byte);
                    try self.OutputInfo("SUB");
                },
                0x2a => {
                    self.Instruction_LHLD();
                    try self.OutputInfo("LHLD");
                },
                0x22 => {
                    self.Instruction_SHLD();
                    try self.OutputInfo("SHLD");
                },
                0xde => {
                    self.Instruction_SBBI();
                    try self.OutputInfo("SBBI");
                },
                0x27 => {
                    self.Instruction_DAA();
                    try self.OutputInfo("DAA");
                },
                0x2f => {
                    self.Instruction_CMA();
                    try self.OutputInfo("CMA");
                },
                0x8f, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0xce => {
                    self.Instruction_ADC(m_byte);
                    try self.OutputInfo("ADC");
                },
                else => {
                    self.CRASHED = true;
                    // print("Emulator Crashed @ instruction : {any}", .{m_instructionCounter});
                    return;
                },
            }

            self.instructionCounter += 1;

            // // print("m_instructionCounter : {any}", .{m_instructionCounter});
            // // print("half_instruction_per_frame : {any}", .{half_instruction_per_frame});

            if (self.instructionCounter >= self.half_instruction_per_frame) {
                if (self.interrupt) {
                    // There are two interrupts that occur every frame (address $08 and $10)
                    if (self.interrupt_alternate == 0) {
                        self.CallInterrupt(0x08);
                    } else {
                        self.CallInterrupt(0x10);
                    }
                }
                self.interrupt_alternate = 1 - self.interrupt_alternate;
                self.instructionCounter = 0;
            }
        }
    }

    pub fn CallInterrupt(self: *CPU, inAddress: u16) void {
        // Call the interrupt by pushing current PC on the stack and then jump to interrupt address
        self.interrupt = false;
        self.StackPush(self.pc);
        self.pc = inAddress;
    }

    // ---- control flow --------------------------------------------------------

    pub fn NOP(self: *CPU) void {
        _ = self;
        // No Operation - Do nothing !
    }

    pub fn Instruction_JMP(self: *CPU, byte: u8) void {
        const data16 = self.FetchRomShort(); // always consumed, even if not taken
        const cond = switch (byte) {
            0xC2 => !self.zero,
            0xCA => self.zero,
            0xD2 => !self.carry,
            0xDA => self.carry,
            0xF2 => !self.sign,
            0xFA => self.sign,
            else => true, // 0xC3
        };
        if (cond) { self.pc = data16; }
    }

    pub fn Instruction_CALL(self: *CPU, byte: u8) void {
        const data16 = self.FetchRomShort();
        const cond = switch (byte) {
            0xC4 => !self.zero,
            0xCC => self.zero,
            0xD4 => !self.carry,
            0xDC => self.carry,
            else => true, // 0xCD
        };
        if (cond) {
            self.StackPush(self.pc);
            self.pc = data16;
        }
    }

    pub fn Instruction_RET(self: *CPU, byte: u8) void {
        const cond = switch (byte) {
            0xC0 => !self.zero,
            0xC8 => self.zero,
            0xD0 => !self.carry,
            0xD8 => self.carry,
            else => true, // 0xC9
        };
        if (cond) self.pc = self.StackPop();
    }

    pub fn Instruction_PCHL(self: *CPU) void {
        self.pc = self.hl;
    }

    pub fn Instruction_RST(self: *CPU, byte: u8) void {
        // C7,CF,D7,...,FF -> 0x00,0x08,0x10,...,0x38
        const address: u16 = byte & 0x38;
        self.StackPush(self.pc);
        self.pc = address;
    }

    // ---- loads / stores / moves ---------------------------------------------

    pub fn Instruction_LXI(self: *CPU, byte: u8) void {
        switch (byte) {
            0x01 => self.SetBC(self.FetchRomShort()),
            0x11 => self.SetDE(self.FetchRomShort()),
            0x21 => self.SetHL(self.FetchRomShort()),
            0x31 => self.SetSP(self.FetchRomShort()),
            else => unreachable,
        }
    }

    pub fn Instruction_MVI(self: *CPU, byte: u8) void {
        // 06,0E,16,1E,26,2E,36,3E: destination is bits 3..5 (36 = memory at HL)
        const dst: u3 = @truncate(byte >> 3);
        self.setReg(dst, self.FetchRomByte());
    }

    pub fn Instruction_LDA(self: *CPU, byte: u8) void {
        switch (byte) {
            0x0a => self.source = self.bc,
            0x1a => self.source = self.de,
            0x3a => self.source = self.FetchRomShort(),
            else => unreachable,
        }
        self.SetA(self.ReadByte(self.source));
    }

    pub fn Instruction_STA(self: *CPU, byte: u8) void {
        switch (byte) {
            0x02 => self.WriteByte(self.bc, self.a),
            0x12 => self.WriteByte(self.de, self.a),
            0x32 => {
                const immediate = self.FetchRomShort();
                self.WriteByte(immediate, self.a);
            },
            else => {},
        }
    }

    pub fn Instruction_MOVHL(self: *CPU, byte: u8) void {
        switch (byte) {
        // 70-75 and 77: MOV M,r (76 is HLT, not handled here)
            0x70...0x75, 0x77 => self.WriteByte(self.hl, self.getReg(@truncate(byte))),
            else => {},
        }
    }

    pub fn Instruction_MOV(self: *CPU, byte: u8) void {
        const dst: u3 = @truncate(byte >> 3);
        const src: u3 = @truncate(byte);
        if (dst == 6) return; // MOV M,r is instructionMovHL
        self.setReg(dst, self.getReg(src));
    }

    pub fn Instruction_LHLD(self: *CPU) void {
        const immediate = self.FetchRomShort();
        self.SetHL(self.ReadShort(immediate));
    }

    pub fn Instruction_SHLD(self: *CPU) void {
        const immediate = self.FetchRomShort();
        self.WriteShort(immediate, self.hl);
    }

    pub fn Instruction_XCHG(self: *CPU) void {
        const temp = self.de;
        self.SetDE(self.hl);
        self.SetHL(temp);
    }

    pub fn Instruction_XTHL(self: *CPU) void {
        const sp1 = self.sp +% 1;

        var temp = self.h;
        self.SetH(self.ReadByte(sp1));
        self.WriteByte((sp1), temp);

        temp = self.l;
        self.SetL(self.ReadByte(self.sp));
        self.WriteByte(self.sp, temp);
    }

    pub fn Instruction_OUTP(self: *CPU) void {
        const port = self.FetchRomByte();
        iO.OutputPort(port, self.a);
    }

    pub fn Instruction_INP(self: *CPU) void {
        const port = self.FetchRomByte();
        self.SetA(iO.InputPort(port));
    }

    // ---- stack ---------------------------------------------------------------
    pub fn Instruction_PUSH(self: *CPU, byte: u8) void {
        const value: u16 = switch (byte) {
            0xC5 => self.bc,
            0xD5 => self.de,
            0xE5 => self.hl,
            0xF5 => blk: { // PUSH PSW: A in the high byte, flags in the low byte
                var v: u16 = @as(u16, self.a) << 8;
                if (self.sign) v |= self.BIT7;
                if (self.zero) v |= self.BIT6;
                if (self.interrupt) v |= self.BIT5;
                if (self.half_carry) v |= self.BIT4;
                if (self.carry) v |= self.BIT0;
                break :blk v;
            },
            else => unreachable, // only called for C5/D5/E5/F5
        };
        self.StackPush(value);
    }

    pub fn Instruction_POP(self: *CPU, byte: u8) void {
        const value = self.StackPop();
        switch (byte) {
            0xC1 => self.SetBC(value),
            0xD1 => self.SetDE(value),
            0xE1 => self.SetHL(value),
            0xF1 => {
                self.a = @truncate(value >> 8);
                self.sign = (value & self.BIT7) != 0;
                self.zero = (value & self.BIT6) != 0;
                self.interrupt = (value & self.BIT5) != 0;
                self.half_carry = (value & self.BIT4) != 0;
                self.carry = (value & self.BIT0) != 0;
            },
            else => unreachable,
        }
    }

    // ---- 16-bit arithmetic ---------------------------------------------------
    pub fn Instruction_INX(self: *CPU, byte: u8) void {
        switch (byte) {
            0x03 => self.SetBC(self.bc +% 1),
            0x13 => self.SetDE(self.de +% 1),
            0x23 => self.SetHL(self.hl +% 1),
            0x33 => self.SetSP(self.sp +% 1),
            else => unreachable,
        }
    }

    pub fn Instruction_DCX(self: *CPU, byte: u8) void {
        switch (byte) {
            0x0B => self.SetBC(self.bc -% 1),
            0x1B => self.SetDE(self.de -% 1),
            0x2B => self.SetHL(self.hl -% 1),
            0x3B => self.SetSP(self.sp -% 1),
            else => unreachable,
        }
    }

    pub fn Instruction_DAD(self: *CPU, byte: u8) void {
        switch (byte) {
            0x09 => self.AddHL(self.bc),
            0x19 => self.AddHL(self.de),
            0x29 => self.AddHL(self.hl),
            0x39 => self.AddHL(self.sp),
            else => unreachable,
        }
    }

    // ---- 8-bit arithmetic / logic -------------------------------------------

    pub fn Instruction_DEC(self: *CPU, byte: u8) void {
        const idx: u3 = @truncate(byte >> 3);
        self.setReg(idx, self.PerformDec(self.getReg(idx)));
    }

    pub fn Instruction_INC(self: *CPU, byte: u8) void {
        const idx: u3 = @truncate(byte >> 3);
        self.setReg(idx, self.PerformInc(self.getReg(idx)));
    }

    pub fn Instruction_CMP(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xFE) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformCompSub(v);
    }

    pub fn Instruction_AND(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xE6) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformAnd(v);
    }

    pub fn Instruction_XOR(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xEE) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformXor(v);
    }

    pub fn Instruction_OR(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xF6) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformOr(v);
    }

    pub fn Instruction_ADD(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xC6) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformByteAdd(v, 0);
    }

    pub fn Instruction_ADC(self: *CPU, byte: u8) void {
        const carry_in: u8 = @intFromBool(self.carry);
        const v: u8 = if (byte == 0xCE) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformByteAdd(v, carry_in);
    }

    pub fn Instruction_SUB(self: *CPU, byte: u8) void {
        const v: u8 = if (byte == 0xD6) self.FetchRomByte() else self.getReg(@truncate(byte));
        self.PerformByteSub(v, 0);
    }

    pub fn Instruction_SBBI(self: *CPU) void {
        const immediate = self.FetchRomByte();
        self.PerformByteSub(immediate, @intFromBool(self.carry));
    }

    pub fn Instruction_CMA(self: *CPU) void {
        self.a = ~self.a;
    }

    pub fn Instruction_DAA(self: *CPU) void {
        var acc: u16 = self.a;

        if ((acc & 0x0F) > 9 or self.half_carry) {
            acc += 0x06;
            self.half_carry = true;
        } else {
            self.half_carry = false;
        }

        if (acc > 0x9F or self.carry) {
            acc += 0x60;
            self.carry = true;
        } else {
            self.carry = false;
        }

        self.a = @truncate(acc);
        self.SetFlagZeroSign();
    }

    // ---- rotates -------------------------------------------------------------

    pub fn Instruction_RLC(self: *CPU) void {
        self.a = std.math.rotl(u8, self.a, 1);
        self.carry = (self.a & 0x01) != 0; // old bit 7
        // self.carry = (self.a & BIT0) != 0;
    }

    pub fn Instruction_RRC(self: *CPU) void {
        self.a = std.math.rotr(u8, self.a, 1);
        self.carry = (self.a & 0x80) != 0; // old bit 0
        // self.carry = (self.a & BIT7) != 0;
    }

    pub fn Instruction_RAL(self: *CPU) void {
        const old = self.a;
        self.a = (old << 1) | @intFromBool(self.carry);
        self.carry = (old & 0x80) != 0;
    }

    pub fn Instruction_RAR(self: *CPU) void {
        const old = self.a;
        self.a = (old >> 1) | (@as(u8, @intFromBool(self.carry)) << 7);
        self.carry = (old & 0x01) != 0;
    }

    // ---- flags / interrupts --------------------------------------------------

    pub fn Instruction_DI(self: *CPU) void {
        self.interrupt = false;
    }

    pub fn Instruction_EI(self: *CPU) void {
        self.interrupt = true;
    }

    pub fn Instruction_STC(self: *CPU) void {
        self.carry = true;
    }

    pub fn Instruction_CMC(self: *CPU) void {
        self.carry = false;
    }


















    // new

    // ---- register setters -------------------------------------------------

    pub fn SetA(self: *CPU, v: u16) void {
        self.a = @truncate(v);
    }

    pub fn SetB(self: *CPU, v: u16) void {
        self.b = @truncate(v);
        self.bc = (@as(u16, self.b) << 8) | self.c;
    }

    pub fn SetC(self: *CPU, v: u16) void {
        self.c = @truncate(v);
        self.bc = (@as(u16, self.b) << 8) | self.c;
    }

    pub fn SetD(self: *CPU, v: u16) void {
        self.d = @truncate(v);
        self.de = (@as(u16, self.d) << 8) | self.e;
    }

    pub fn SetE(self: *CPU, v: u16) void {
        self.e = @truncate(v);
        self.de = (@as(u16, self.d) << 8) | self.e;
    }

    pub fn SetH(self: *CPU, v: u16) void {
        self.h = @truncate(v);
        self.hl = (@as(u16, self.h) << 8) | self.l;
    }

    pub fn SetL(self: *CPU, v: u16) void {
        self.l = @truncate(v);
        self.hl = (@as(u16, self.h) << 8) | self.l;
    }

    pub fn SetBC(self: *CPU, v: u16) void {
        self.bc = v;
        self.b = @truncate(v >> 8);
        self.c = @truncate(v);
    }

    pub fn SetDE(self: *CPU, v: u16) void {
        self.de = v;
        self.d = @truncate(v >> 8);
        self.e = @truncate(v);
    }

    pub fn SetHL(self: *CPU, v: u16) void {
        self.hl = v;
        self.h = @truncate(v >> 8);
        self.l = @truncate(v);
    }

    pub fn SetSP(self: *CPU, v: u16) void {
        self.sp = v;
    }

    // ---- memory access ----------------------------------------------------

    pub fn FetchRomByte(self: *CPU) u8 {
        const lvalue = self.rom[self.pc];
        self.pc +%= 1;
        return lvalue;
    }

    pub fn FetchRomShort(self: *CPU) u16 {
        const lvalue = std.mem.readInt(u16, self.rom[self.pc..][0..2], .little);
        self.pc +%= 2;
        return lvalue;
    }

    pub fn ReadByte(self: *const CPU, addr: usize) u8 {
        return self.rom[addr];
    }

    pub fn ReadShort(self: *const CPU, addr: u16) u16 {
        const a: usize = addr;
        return (@as(u16, self.rom[a + 1]) << 8) | self.rom[a];
    }

    pub fn WriteShort(self: *CPU, addr: u16, word: u16) void {
        const a: usize = addr;
        self.rom[a + 1] = @truncate(word >> 8);
        self.rom[a] = @truncate(word);
    }

    pub fn WriteByte(self: *CPU, addr: u16, byte: u16) void {
        self.rom[addr] = @truncate(byte);
    }

    // ---- stack ------------------------------------------------------------

    pub fn StackPush(self: *CPU, inValue: u16) void {
        self.sp -%= 2;
        self.WriteShort(self.sp, inValue);
    }

    pub fn StackPop(self: *CPU) u16 {
        const temp = self.ReadShort(self.sp);
        self.sp +%= 2;
        return temp;
    }

    // ---- ALU helpers ------------------------------------------------------

    pub fn PerformDec(self: *CPU, src: u8) u8 {
        const lvalue = src -% 1;
        self.half_carry = (lvalue & 0x0F) == 0;
        self.zero = lvalue == 0;
        self.sign = (lvalue & 0x80) != 0;
        return lvalue;
    }

    pub fn PerformInc(self: *CPU, src: u8) u8 {
        const lvalue = src +% 1;
        // NOTE: faithful to the C# ((v & 0xF) < 0 || (v & 0xF) > 0), i.e. "!= 0".
        // On a real 8080, INC sets half-carry when the low nibble becomes 0.
        self.half_carry = (lvalue & 0x0F) != 0;
        self.zero = lvalue == 0;
        self.sign = (lvalue & 0x80) != 0;
        return lvalue;
    }

    pub fn SetFlagZeroSign(self: *CPU) void {
        self.zero = self.a == 0;
        self.sign = (self.a & 0x80) != 0;
    }

    pub fn PerformAnd(self: *CPU, v: u8) void {
        self.a &= v;
        self.carry = false;
        self.half_carry = false;
        self.SetFlagZeroSign();
    }

    pub fn PerformXor(self: *CPU, v: u8) void {
        self.a ^= v;
        self.carry = false;
        self.half_carry = false;
        self.SetFlagZeroSign();
    }

    pub fn PerformOr(self: *CPU, v: u8) void {
        self.a |= v;
        self.carry = false;
        self.half_carry = false;
        self.SetFlagZeroSign();
    }

    pub fn PerformByteAdd(self: *CPU, v: u8, carry_in: u8) void {
        const lvalue: u16 = @as(u16, self.a) + v + carry_in;
        const low: u8 = @truncate(lvalue);
        self.half_carry = ((self.a ^ v ^ low) & 0x10) != 0;
        self.a = low;
        self.carry = lvalue > 255;
        self.SetFlagZeroSign();
    }

    pub fn PerformByteSub(self: *CPU, v: u8, carry_in: u8) void {
        const lvalue: u8 = self.a -% v -% carry_in;
        self.carry = lvalue >= self.a and (v | carry_in) > 0;
        self.half_carry = ((self.a ^ v ^ lvalue) & 0x10) != 0;
        self.a = lvalue;
        self.SetFlagZeroSign();
    }

    pub fn PerformCompSub(self: *CPU, v: u8) void {
        const lvalue: u8 = self.a -% v;
        // NOTE: the C# assigns CARRY = inValue here (not 1); treated as a bool now.
        self.carry = lvalue >= self.a and v != 0;
        self.half_carry = ((self.a ^ v ^ lvalue) & 0x10) != 0;
        self.zero = lvalue == 0;
        self.sign = (lvalue & 0x80) != 0;
    }

    pub fn AddHL(self: *CPU, v: u16) void {
        const r = @addWithOverflow(self.hl, v);
        self.SetHL(r[0]);
        self.carry = r[1] == 1;
    }


    // old


    // pub fn SetA(inByte: u8) void {
    //     A = inByte & 0xFF;
    // }
    //
    // pub fn SetB(inByte: u8) void {
    //     B = inByte & 0xFF;
    //     BC = std.math.shl(u16, B, 8) | C;
    // }
    //
    // pub fn SetC(inByte: u8) void {
    //     C = inByte & 0xFF;
    //     BC = std.math.shl(u16, B, 8) | C;
    // }
    //
    // pub fn SetD(inByte: u8) void {
    //     D = inByte;
    //     DE = std.math.shl(u16, D, 8) + E;
    // }
    //
    // pub fn SetE(inByte: u8) void {
    //     E = inByte;
    //     DE = std.math.shl(u16, D, 8) + E;
    // }
    //
    // pub fn SetH(inByte: u8) void {
    //     H = inByte;
    //     HL = std.math.shl(u16, H, 8) + L;
    // }
    //
    // pub fn SetL(inByte: u8) void {
    //     L = inByte;
    //     HL = std.math.shl(u16, H, 8) + L;
    // }
    //
    // pub fn SetBC(inShort: u16) void {
    //     BC = inShort;
    //     B = @truncate(BC >> 8);
    //     C = @truncate(BC & 0xFF);
    // }
    //
    // pub fn SetDE(inShort: u16) void {
    //     DE = inShort;
    //     D = @truncate(DE >> 8);
    //     E = @truncate(DE & 0xFF);
    // }
    //
    // pub fn SetHL(inShort: u16) void {
    //     HL = inShort;
    //     H = @truncate(HL >> 8);
    //     L = @truncate(HL & 0xFF);
    // }
    //
    // pub fn SetSP(inShort: u16) void {
    //     SP = inShort;
    // }
    //
    // pub fn FetchRomByte() u8 {
    //     const rom_value = rom[PC];
    //     //print("rom_value: {any}", .{rom_value});
    //     PC += 1;
    //     return rom_value;
    // }
    //
    // pub fn FetchRomShort() u16 {
    //     var bytes: [2]u8 = [_]u8{ 0, 0 };
    //     bytes[0] = rom[PC + 0];
    //     bytes[1] = rom[PC + 1];
    //     PC += 2;
    //     const result = std.math.shl(u16, (bytes[1] & 0xFF), 8) | (bytes[0] & 0xFF);
    //     return result;
    //     // return std.math.shl(u16, (bytes[1] & 0xFF), 8) | (bytes[0] & 0xFF);
    // }
    //
    // pub fn ReadByte(counter: usize) u8 {
    //     return rom[counter];
    // }
    //
    // pub fn ReadShort(inAddress: u16) u16 {
    //     return std.math.shl(u16, rom[inAddress + 1], 8) + (rom[inAddress + 0]);
    // }
    //
    // pub fn WriteShort(inAddress: u16, inWord: u16) void {
    // //pub fn WriteShort(inAddress: usize, inWord: u16) void {
    //     print("WriteShort inAddress: {any}, inByte: {any}", .{inAddress, inWord});
    //     // print("WriteShort inByte: {any}", .{inWord});
    //     const valueOne: u8 = @intCast(std.math.shr(u16, inWord, 8));
    //     // print("WriteShort valueOne: {any}", .{valueOne});
    //     // rom[inAddress + 1] = @intCast(std.math.shr(u16, inWord, 8));
    //     rom[inAddress + 1] = valueOne;
    //     // print("m_rom[inAddress + 1]: {any}", .{m_rom[inAddress + 1]});
    //     const valueTwo: u8= @truncate(inWord);
    //     print("WriteShort valueOne: {any}, valueTwo: {any}", .{valueOne, valueTwo});
    //     // rom[inAddress + 0] = @truncate(inWord);
    //     rom[inAddress + 0] = valueTwo;
    //     // print("m_rom[inAddress + 0]: {any}", .{m_rom[inAddress + 0]});
    // }
    //
    // pub fn WriteByte(inAddress: u16, inByte: u8) void {
    //     if (inAddress < rom.len) {
    //         print("WriteByte inAddress: {any}, inByte: {any}", .{inAddress, inByte});
    //         // print("WriteByte inByte: {any}", .{inByte});
    //         rom[inAddress] = inByte;
    //     } else {
    //         print("Overflow occurred: {any}", .{rom.len});
    //         print("Overflow occurred: {any}", .{inAddress});
    //     }
    // }
    //
    // pub fn StackPush(inValue: u16) void {
    //     if (SP > 1) {
    //         SP -= 2;
    //         WriteShort(SP, inValue);
    //     }
    // }
    //
    // pub fn StackPop() u16 {
    //     const temp = ReadShort(SP);
    //     SP += 2;
    //     return temp;
    // }
    //
    // pub fn PerformDec(inSource: u16) u8 {
    //     // const value: u16 = @intCast((inSource - 1) & 0xFF);
    //     const cast: i16 = @intCast(inSource);
    //     const localValue: u16 = @intCast((cast - 1) & 0xFF);
    //     HALFCARRY = @intFromBool((localValue & 0x0F) == 0);
    //     ZERO = @intFromBool((localValue & 255) == 0);
    //     SIGN = @truncate(localValue & 128);
    //     const return_value: u8 = @intCast(localValue);
    //     return return_value;
    // }
    //
    // pub fn PerformInc(inSource: u8) u8 {
    //     const localValue = inSource + 1;
    //     HALFCARRY = @intFromBool(((localValue & 0xF) < 0) or ((localValue & 0xF) > 0));
    //     ZERO = @intFromBool((localValue & 255) == 0);
    //     SIGN = @truncate(localValue & 128);
    //     return localValue;
    // }
    //
    // pub fn SetFlagZeroSign() void {
    //     ZERO = @intFromBool(A == 0);
    //     SIGN = @truncate(A & 128);
    // }
    //
    // pub fn PerformAnd(inValue: u8) void {
    //     SetA(A & inValue);
    //     CARRY = 0;
    //     HALFCARRY = 0;
    //     SetFlagZeroSign();
    // }
    //
    // pub fn PerformXor(inValue: u8) void {
    //     SetA(A ^ inValue);
    //     CARRY = 0;
    //     HALFCARRY = 0;
    //     SetFlagZeroSign();
    // }
    //
    // fn PerformOr(inValue: u8) void {
    //     SetA(A | inValue);
    //     CARRY = 0;
    //     HALFCARRY = 0;
    //     SetFlagZeroSign();
    // }
    //
    // pub fn PerformByteAdd(inValue: u8, inCarryValue: u8) void {
    //     const localValue = A + inValue + inCarryValue;
    //     // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
    //     HALFCARRY = (A ^ inValue ^ localValue) & 0x10;
    //     SetA(localValue);
    //     if (localValue > 255) {
    //         CARRY = 1;
    //     } else {
    //         CARRY = 0;
    //     }
    //     SetFlagZeroSign();
    // }
    //
    // pub fn PerformByteSub(inValue: u8, inCarryValue: u8) void {
    //     const localValue: u8 = (A - inValue - inCarryValue);
    //     if ((localValue >= A) and (inValue | inCarryValue) > 0) {
    //         CARRY = 1;
    //     } else {
    //         CARRY = 0;
    //     }
    //     // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
    //     HALFCARRY = (A ^ inValue ^ localValue) & 0x10;
    //     SetA(localValue);
    //     SetFlagZeroSign();
    // }
    //
    // pub fn PerformCompSub(inValue: u16) void {
    //     const cast: i16 = @intCast(inValue);
    //     // const value: i16 = @intCast((A - inValue) & 0xFF);
    //     const localValue: i16 = @intCast((A - cast) & 0xFF);
    //     if ((value >= A) and ToBooleanU16(inValue)) {
    //         CARRY = inValue;
    //     } else {
    //         CARRY = 0;
    //     }
    //     // print("PerformCompSub CARRY: {any}", .{CARRY});
    //     // HALFCARRY = @truncate((A ^ inValue ^ value) & 0x10);
    //     const tempA: u16 = A;
    //     const tempValue: u16 = @intCast(localValue);
    //     HALFCARRY = (tempA ^ inValue ^ tempValue) & 0x10;
    //
    //     // print("PerformCompSub HALFCARRY: {any}", .{HALFCARRY});
    //     ZERO = @intFromBool(localValue == 0);
    //     // print("PerformCompSub ZERO: {any}", .{ZERO});
    //     // SIGN = @truncate(value & 128);
    //     SIGN = @intCast(localValue & 128);
    //     // print("PerformCompSub SIGN: {any}", .{SIGN});
    // }
    //
    // pub fn AddHL(inValue: u16) void {
    //     const localValue = HL + inValue;
    //     SetHL(localValue);
    //     CARRY = @intFromBool(localValue > 65535);
    // }

    // TODO - Temp method
    pub fn SetValueU8(self: *CPU, inValue: u8, bit: u8) void {
        const conv: u16 = @intCast(inValue);
        if (conv != 0) {
            self.value = (self.value | bit);
        } else {
            _ = conv == 0;
        }
    }

    // TODO - Temp method
    pub fn SetValueU16(self: *CPU, inValue: u16, bit: u8) void {
        const conv: u16 = @intCast(inValue);
        if (conv != 0) {
            self.value = (self.value | bit);
        } else {
            _ = conv == 0;
        }
    }

    pub fn SetValueInterrupt(self: *CPU, inValue: bool, bit: u8) void {
        const fudge: bool = inValue;
        if (fudge) {
            self.value = (self.value | bit);
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

    pub fn Reset(self: *CPU) void {
        self.pc = 0;
        self.a = 0;
        self.bc = 0;
        self.de = 0;
        self.hl = 0;
        self.sign = 0;
        self.zero = 0;
        self.half_carry = 0;
        self.parity = false;
        self.carry = 0;
        self.interrupt = false;
        self.CRASHED = false;
    }

    fn getReg(self: *const CPU, idx: u3) u8 {
        return switch (idx) {
            0 => self.b,
            1 => self.c,
            2 => self.d,
            3 => self.e,
            4 => self.h,
            5 => self.l,
            6 => self.ReadByte(self.hl), // M = memory at HL
            7 => self.a,
        };
    }

    fn setReg(self: *CPU, idx: u3, v: u8) void {
        switch (idx) {
            0 => self.SetB(v),
            1 => self.SetC(v),
            2 => self.SetD(v),
            3 => self.SetE(v),
            4 => self.SetH(v),
            5 => self.SetL(v),
            6 => self.WriteByte(self.hl, v),
            7 => self.SetA(v),
        }
    }
};
