using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Ledge : BaseObject
    {
        public Ledge(int x, int y, Texture2D image)
        {
            m_image = image;
            m_height = image.Height;
            m_width = image.Width;
            m_rect = new Rectangle(x, y, m_width, m_height);
            m_screenLocation = new Vector2(x, y);
        }

        public void Update(int x, int y)
        {
            m_screenLocation.X += x;
            m_screenLocation.Y += y;
            m_rect = new Rectangle((int)m_screenLocation.X, (int)m_screenLocation.Y, m_width, m_height);
        }

        public Rectangle LedgeRect
        {
            get { return m_rect; }
        }
    }
}
