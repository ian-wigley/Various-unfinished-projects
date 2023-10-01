using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Bullet : BaseObject
    {
        private bool m_left = false;
        private bool m_offscreen = false;

        public Bullet(int x, int y, Texture2D image, bool left)
        {
            m_image = image;
            m_left = left;
            m_screenLocation = new Vector2(x, y);
        }

        public void Update()
        {
            if (m_screenLocation.X < 800 && !m_left)
            {
                m_screenLocation.X += 6;
            }
            else if (m_screenLocation.X > -40)
            {
                m_screenLocation.X -= 6;
            }
            if (m_screenLocation.X >= 800 || m_screenLocation.X <= -40)
            {
                m_offscreen = true;
            }
        }

        public bool Offscreen
        {
            get { return m_offscreen; }
        }

        public Rectangle BulletRect
        {
            get { return new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_image.Width, m_image.Height); }
        }
    }
}
