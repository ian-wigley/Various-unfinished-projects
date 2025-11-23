using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetPacReloaded
{
    public class Explosion : BaseObject
    {
        public Explosion(int x, int y, Texture2D image)
        {
            m_image = image;
            m_height = image.Height;
            m_width = image.Width / 16;
            m_screenLocation = new Vector2(x, y);
        }

        public void Update()
        {
            if (m_frame < 16)
            {
                m_frame += 1;
            }
            else
            {
                AnimationComplete = true;
            }
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
        }

        public new void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.Draw(m_image, m_screenLocation, m_rect, Color.White, 0, Vector2.Zero, 1.0f, 0, 0);
        }

        public bool AnimationComplete { get; private set; }
    }
}
