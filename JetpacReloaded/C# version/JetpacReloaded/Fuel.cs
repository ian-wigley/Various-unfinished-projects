using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System.Collections.Generic;

namespace JetpacReloaded
{
    class Fuel : BaseObject
    {
        private bool landedOnLedge = false;

        public Fuel(Texture2D image)
        {
            m_image = image;
            m_width = image.Width;
            m_height = image.Height + 2;
            m_screenLocation = new Vector2(rand.Next(0, 750), -30);
        }

        public void Update(List<Ledge> ledges)
        {
            m_rect = new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height);

            if (!landedOnLedge)
            {
                foreach (Ledge ledge in ledges)
                {
                    if (!m_rect.Intersects(ledge.LedgeRect))
                    {
                        m_screenLocation.Y += 0.2f;
                    }
                    else
                    {
                        landedOnLedge = true;
                    }
                }
            }
        }

        public void UpdatePosition(int x, int y)
        {
            m_screenLocation.X = x;
            m_screenLocation.Y = y;
        }

        public bool LowerFuel()
        {
            m_screenLocation.X = 440;
            if (m_screenLocation.Y < 450)
            {
                m_screenLocation.Y++;
            }
            return m_screenLocation.Y > 448;
        }

        public Rectangle FuelRect
        {
            get { return m_rect; }
        }
    }
}

