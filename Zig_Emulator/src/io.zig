namespace Emulator
{
    public class IO
    {
        // Input and output ports
        private byte OUT_PORT2;
        //private byte OUT_PORT3;
        private byte OUT_PORT4LO;
        private byte OUT_PORT4HI;
        //private byte OUT_PORT5;
        private byte IN_PORT1 = 0;
        private byte IN_PORT2 = 0;
        private CPU m_cpu;

        private byte BIT0 = 1;
        private byte BIT1 = 2;
        private byte BIT2 = 4;
        //private byte BIT3 = 8;
        private byte BIT4 = 16;
        private byte BIT5 = 32;
        private byte BIT6 = 64;
        private byte BIT7 = 128;

        private bool m_coin = false;
        private bool m_start = false;
        private bool m_left = false;
        private bool m_right = false;
        private bool m_fire = false;
        // private bool m_tilt = false;

        public IO()
        {
            // Dipswitch: BIT0 and BIT1 controls starting number of life (from 3 to 6)
            // BIT7 prints additionnal coin message on intro screen
            IN_PORT2 = (byte)(IN_PORT2 | (BIT0 | BIT1));
            IN_PORT2 = (byte)(IN_PORT2 | (BIT7));
        }


        public void SetCPU(CPU cpu)
        {
            m_cpu = cpu;
        }

        public void Update()
        {
            // Clear player input bits
            IN_PORT1 = (byte)(IN_PORT1 & (~(BIT0 | BIT1 | BIT2 | BIT4 | BIT5 | BIT6)));
            IN_PORT2 = (byte)(IN_PORT2 & (~(BIT2 | BIT4 | BIT5 | BIT6)));

            if (m_coin)
            {
                IN_PORT1 |= 0x1;
                m_coin = false;
            }

            if (m_start)
            {
                IN_PORT1 |= 0x4;
                m_start = false;
            }

            if (m_left)
            {
                // Move left: same key used for player 1 and 2
                IN_PORT1 = (byte)(IN_PORT1 | BIT5);
                IN_PORT2 = (byte)(IN_PORT2 | BIT5);
                m_left = false;
            }

            if (m_right)
            {
                // Move right: same key used for player 1 and 2
                IN_PORT1 = (byte)(IN_PORT1 | BIT6);
                IN_PORT2 = (byte)(IN_PORT2 | BIT6);
                m_right = false;
            }

            if (m_fire)
            {
                // shoot button: same key used for player 1 and 2
                IN_PORT1 = (byte)(IN_PORT1 | BIT4);
                IN_PORT2 = (byte)(IN_PORT2 | BIT4);
                m_fire = false;
            }
        }

        public void KetDownCoin()
        {
            // Insert a coin
            m_coin = true;
        }

        public void KeyDown1()
        {
            // Player 1 start
            m_start = true;
        }

        public void KeyDown2()
        {
            // Player 2 start
            IN_PORT1 = (byte)(IN_PORT1 | BIT1);
        }

        public void KeyDownT()
        {
            // Tilt detection trigger
            IN_PORT2 = (byte)(IN_PORT2 | BIT2);
        }

        public void KeyDownLeft()
        {
            // Move left: same key used for player 1 and 2
            m_left = true;
        }

        public void KeyDownRight()
        {
            // Move right: same key used for player 1 and 2
            m_right = true;
        }

        public void KeyDownSpace()
        {
            // Shoot button: same key used for player 1 and 2
            m_fire = true;
        }

        public void OutputPort(byte port, byte value)
        {
            switch (port)
            {
                // Port 2 simply stores a 8-bit value
                case 2:
                    OUT_PORT2 = value;
                    break;

                // Port 3 controls play of various sound effects
                case 3:
                    if ((value & BIT0) == 0)
                    {
                        // sound.StartUfo()
                    }
                    else
                    {
                        // sound.StopUfo()
                    }
                    //            If((value & BIT1) And Not (OUT_PORT3 & BIT1)) sound.PlayShot()
                    //            If((value & BIT2) And Not (OUT_PORT3 & BIT2)) sound.PlayBaseHit()
                    //            If((value & BIT3) And Not (OUT_PORT3 & BIT3)) sound.PlayInvHit()
                    //            If((value & BIT4) And Not (OUT_PORT3 & BIT4)) sound.PlayExtraLife()
                    //            If((value & BIT5) And Not (OUT_PORT3 & BIT5)) sound.PlayBeginPlay()
                    //            OUT_PORT3 = value
                    break;

                case 4:
                    OUT_PORT4LO = OUT_PORT4HI;
                    OUT_PORT4HI = value;
                    break;

                // Port 5 also controls sound
                case 5:
                    //        If((value & BIT0) And Not (OUT_PORT5 & BIT0)) sound.PlayWalk1()
                    //            If((value & BIT1) And Not (OUT_PORT5 & BIT1)) sound.PlayWalk2()
                    //            If((value & BIT2) And Not (OUT_PORT5 & BIT2)) sound.PlayWalk3()
                    //            If((value & BIT3) And Not (OUT_PORT5 & BIT3)) sound.PlayWalk4()
                    //            If((value & BIT4) And Not (OUT_PORT5 & BIT4)) sound.PlayUfoHit()
                    //            OUT_PORT5 = value
                    break;
            }
        }

        public byte InputPort(byte port)
        {
            byte result = 0;

            switch (port)
            {
                // Player 1 Input keys
                case 1:
                    result = IN_PORT1;
                    break;
                // Player 2 Input keys And dip switches:
                case 2:
                    result = IN_PORT2;
                    break;
                case 3:
                    result = (byte)((((OUT_PORT4HI << 8) | OUT_PORT4LO) << OUT_PORT2) >> 8);
                    break;
            }
            return result;
        }
    }
}