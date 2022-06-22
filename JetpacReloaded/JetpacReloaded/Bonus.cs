using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    class Bonus : BaseObject
    {
        private bool bonusLanded = false;
        private int m_prevFrame = 0;

        public Bonus(Texture2D image)
        {
            m_frame = rand.Next(0, 4);
            m_image = image;
            m_width = image.Width / 5;
            m_height = image.Height + 2;
            m_screenLocation = new Vector2(rand.Next(0, 750), -30);
        }

        public void Update()
        {
            if (!bonusLanded)
            {
                m_screenLocation.Y++;
            }
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
        }

        new public void Draw(SpriteBatch spriteBatch)
        {
            Vector2 bonusLocation = new Vector2(m_screenLocation.X, m_screenLocation.Y);
            spriteBatch.Draw(m_image, bonusLocation, m_rect, Color.White, 0, Vector2.Zero, 1.0f, 0, 0);
        }

        public Rectangle BonRect
        {
            get
            {
                return new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height);
            }
        }

        public bool BonusLanded { set { bonusLanded = value; } }

        public void Reset()
        {
            m_prevFrame = m_frame;
            m_frame = rand.Next(0, 4);
            if (m_frame == m_prevFrame)
            {
                m_frame = (m_frame + 1) % 4;
            }
            m_screenLocation.X = rand.Next(0, 750);
            m_screenLocation.Y = -30;
            bonusLanded = false;
        }
    }
}
