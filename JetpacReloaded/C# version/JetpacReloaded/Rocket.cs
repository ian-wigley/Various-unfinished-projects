using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Rocket : BaseObject
    {
        public Rocket(int x, int y, Texture2D image, int frame, int width, int height)
        {
            m_image = image;
            m_frame = frame;
            m_width = width;
            m_height = height;
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
            m_screenLocation = new Vector2(x, y);
        }

        public void Update(int x, int y)
        {
            m_screenLocation.X = x;
            m_screenLocation.Y = y;
        }

        public bool LowerSectionOne()
        {
            m_screenLocation.X = 422;
            if (m_screenLocation.Y < 383)
            {
                m_screenLocation.Y++;
            }
            return m_screenLocation.Y >= 383;
        }

        public bool LowerSectionTwo()
        {
            m_screenLocation.X = 422;
            if (m_screenLocation.Y < 323)
            {
                m_screenLocation.Y++;
            }
            return m_screenLocation.Y >= 323;
        }

        public bool TakeOff()
        {
            m_screenLocation.Y -= 1.5f;
            return m_screenLocation.Y > -200;
        }

        new public void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.Draw(m_image, m_screenLocation, m_rect, Color.White, 0, Vector2.Zero, 1.0f, 0, 0);
        }

        public Rectangle RocketRect
        {
            get { return new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height); }
        }
    }
}
