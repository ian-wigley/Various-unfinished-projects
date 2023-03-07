const std = @import("std");
const CPU = @import("CPU.zig");

pub const IO = struct {
    // Input and output ports
    var OUT_PORT2: u8 = 0;
    // var OUT_PORT3: u8 = 0;
    var OUT_PORT4LO: u8 = 0;
    var OUT_PORT4HI: u8 = 0;
    // var OUT_PORT5: u8 = 0;
    var IN_PORT1: u8 = 0;
    var IN_PORT2: u8 = 0;
    var m_cpu: *CPU = undefined;

    var BIT0: u8 = 1;
    var BIT1: u8 = 2;
    var BIT2: u8 = 4;
    // var BIT3: u8 = 8;
    var BIT4: u8 = 16;
    var BIT5: u8 = 32;
    var BIT6: u8 = 64;
    var BIT7: u8 = 128;

    var m_coin: bool = false;
    var m_start: bool = false;
    var m_left: bool = false;
    var m_right: bool = false;
    var m_fire: bool = false;
    //  var m_tilt: bool = false;

    pub fn New() void {
        // Dipswitch: BIT0 and BIT1 controls starting number of life (from 3 to 6)
        // BIT7 prints additionnal coin message on intro screen
        IN_PORT2 = (IN_PORT2 | (BIT0 | BIT1));
        IN_PORT2 = (IN_PORT2 | (BIT7));
    }

    pub fn SetCPU(cpu: *CPU) void {
        m_cpu = cpu;
    }

    pub fn Update() void {
        //        // Clear player input bits
        //        IN_PORT1 = (byte)(IN_PORT1 & (~(BIT0 | BIT1 | BIT2 | BIT4 | BIT5 | BIT6)));
        //        IN_PORT2 = (byte)(IN_PORT2 & (~(BIT2 | BIT4 | BIT5 | BIT6)));
        //
        //        if (m_coin)
        //        {
        //            IN_PORT1 |= 0x1;
        //            m_coin = false;
        //        }
        //
        //        if (m_start)
        //        {
        //            IN_PORT1 |= 0x4;
        //            m_start = false;
        //        }
        //
        //        if (m_left)
        //        {
        //            // Move left: same key used for player 1 and 2
        //            IN_PORT1 = (byte)(IN_PORT1 | BIT5);
        //            IN_PORT2 = (byte)(IN_PORT2 | BIT5);
        //            m_left = false;
        //        }
        //
        //        if (m_right)
        //        {
        //            // Move right: same key used for player 1 and 2
        //            IN_PORT1 = (byte)(IN_PORT1 | BIT6);
        //            IN_PORT2 = (byte)(IN_PORT2 | BIT6);
        //            m_right = false;
        //        }
        //
        //        if (m_fire)
        //        {
        //            // shoot button: same key used for player 1 and 2
        //            IN_PORT1 = (byte)(IN_PORT1 | BIT4);
        //            IN_PORT2 = (byte)(IN_PORT2 | BIT4);
        //            m_fire = false;
        //        }
    }

    pub fn KetDownCoin() void {
        // Insert a coin
        // m_coin = true;
    }

    pub fn KeyDown1() void {
        // Player 1 start
        // m_start = true;
    }

    pub fn KeyDown2() void {
        // Player 2 start
        // IN_PORT1 = (byte)(IN_PORT1 | BIT1);
    }

    pub fn KeyDownT() void {
        // Tilt detection trigger
        //    IN_PORT2 = (byte)(IN_PORT2 | BIT2);
    }

    pub fn KeyDownLeft() void {
        // Move left: same key used for player 1 and 2
        // m_left = true;
    }

    pub fn KeyDownRight() void {
        // Move right: same key used for player 1 and 2
        // m_right = true;
    }

    pub fn KeyDownSpace() void {
        // Shoot button: same key used for player 1 and 2
        // m_fire = true;
    }

    pub fn OutputPort(port: u8, value: u8) void {
        switch (port) {
            // Port 2 simply stores a 8-bit value
            0x02 => {
                // case 2:
                OUT_PORT2 = value;
                // break;
            },

            // Port 3 controls play of various sound effects
            0x03 => {
                // case 3:
                if ((value & BIT0) == 0) {
                    // sound.StartUfo()
                } else {
                    // sound.StopUfo()
                }
                //     If((value & BIT1) And Not (OUT_PORT3 & BIT1)) sound.PlayShot()
                //     If((value & BIT2) And Not (OUT_PORT3 & BIT2)) sound.PlayBaseHit()
                //     If((value & BIT3) And Not (OUT_PORT3 & BIT3)) sound.PlayInvHit()
                //     If((value & BIT4) And Not (OUT_PORT3 & BIT4)) sound.PlayExtraLife()
                //     If((value & BIT5) And Not (OUT_PORT3 & BIT5)) sound.PlayBeginPlay()
                //     OUT_PORT3 = value
                //    break;
            },
            0x04 => {
                // case 4:
                OUT_PORT4LO = OUT_PORT4HI;
                OUT_PORT4HI = value;
                // break;
            },
            0x05 => {
                // Port 5 also controls sound
                // case 5:
                // If((value & BIT0) And Not (OUT_PORT5 & BIT0)) sound.PlayWalk1()
                // If((value & BIT1) And Not (OUT_PORT5 & BIT1)) sound.PlayWalk2()
                // If((value & BIT2) And Not (OUT_PORT5 & BIT2)) sound.PlayWalk3()
                // If((value & BIT3) And Not (OUT_PORT5 & BIT3)) sound.PlayWalk4()
                // If((value & BIT4) And Not (OUT_PORT5 & BIT4)) sound.PlayUfoHit()
                // OUT_PORT5 = value;
                // break;
            },
            else => {},
        }
    }

    pub fn InputPort(port: u8) u8 {
        var result: u8 = 0;
        // _ = port;
        switch (port) {
            // Player 1 Input keys
            0x01 => {
                //case 1:
                result = IN_PORT1;
                //   break;
            },
            // Player 2 Input keys And dip switches:
            0x02 => {
                // case 2:
                result = IN_PORT2;
                // break;
            },
            0x03 => {
                // case 3:
                // result = (byte)((((OUT_PORT4HI << 8) | OUT_PORT4LO) << OUT_PORT2) >> 8);
                result = std.math.shr(u8, std.math.shl(u8, (std.math.shl(u8, OUT_PORT4HI, 8) | OUT_PORT4LO), OUT_PORT2), 8);
                // break;
            },
            else => {},
        }
        return result;
    }
};
