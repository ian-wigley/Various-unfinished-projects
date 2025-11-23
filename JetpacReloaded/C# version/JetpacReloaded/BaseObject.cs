using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System;

namespace JetPacReloaded
{
    public class BaseObject
    {
        protected int m_width;
        protected int m_height;
        protected int m_frame;
        protected Texture2D m_image;
        /// <summary>
        /// m_rect is the rectangle used for displaying sections of the texture
        /// </summary>
        protected Rectangle m_rect;
        protected Vector2 m_screenLocation;
        protected static Random rand = new Random();

        protected BaseObject()
        {
            m_width = 0;
            m_height = 0;
            m_frame = 0;
            m_rect = new Rectangle(0, 0, m_width, m_height);
         }

        public void Draw(SpriteBatch spriteBatch)
        {
            spriteBatch.Draw(m_image, m_screenLocation, Color.White);
        }
    }
}

