using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetPacReloaded
{
    public class Jetman : BaseObject
    {
        private SpriteEffects m_flip = SpriteEffects.None;
        private Texture2D m_debugImage;

        public Jetman(int x, int y, Texture2D image, Texture2D debugimage)
        {
            m_image = image;
            m_height = 68;// image.Height;
            m_width = 64;// image.Width / 5;
            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
            m_screenLocation = new Vector2(x, y);
            m_debugImage = debugimage;
        }

        //        public void Update(int x, int y, SpriteEffects flip)
        public void Update(Vector2 vec, SpriteEffects flip)
        {
            //m_screenLocation.X = x;
            //m_screenLocation.Y = y;

            m_screenLocation = vec;

            //if (y <= 50) { m_screenLocation.Y = 50; }
            //if (y >= 550) { m_screenLocation.Y = 550; }
            //if (x <= 0) { m_screenLocation.X = 0; }
            //if (x >= 750) { m_screenLocation.X = 750; }

            m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
            m_flip = flip;
        }

        public new void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.Draw(m_debugImage, m_screenLocation, JetmanRect, Color.White, 0, Vector2.Zero, 1.0f, m_flip, 0);
            //spriteBatch.Draw(m_image, m_screenLocation, m_rect, Color.White, 0, Vector2.Zero, 1.0f, m_flip, 0);
        }

        public Rectangle JetmanRect
        {
            get { return new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height); }
        }

        public Vector2 JetmanPosition { get { return m_screenLocation; } }

        public int JetmanAnimFrame { set { m_frame = value; } }




    }
}
