using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Enemy : BaseObject
    {
        public Enemy(Texture2D image)
        {
            m_image = image;
            m_width = image.Width / 8;
            m_height = image.Height;
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
            m_screenLocation = new Vector2(rand.Next(0, 800), rand.Next(50, 440));
        }

        public void Update(int level)
        {
            if (m_screenLocation.X > -70)
            {
                m_screenLocation.X--;
            }
            else
            {
                ResetMeteor();
            }
            m_frame = level % 8;
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
        }

        public void ResetMeteor()
        {
            m_screenLocation.X = rand.Next(800, 1200);
            m_screenLocation.Y = rand.Next(50, 400);
        }

        new public void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.Draw(m_image, m_screenLocation, m_rect, Color.White, 0, Vector2.Zero, 1.0f, 0, 0);
        }

        public Rectangle AlienRect
        {
            get { return new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height); }
        }
    }
}
