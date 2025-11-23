using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetPacReloaded
{
    public class Bullet : BaseObject
    {
        private bool m_left = false;

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
            if (m_screenLocation.X is >= 800 or <= -40)
            {
                Offscreen = true;
            }
        }

        public bool Offscreen { get; private set; }

        public Rectangle BulletRect => new((int)m_screenLocation.X, (int)m_screenLocation.Y, m_image.Width, m_image.Height);
    }
}
