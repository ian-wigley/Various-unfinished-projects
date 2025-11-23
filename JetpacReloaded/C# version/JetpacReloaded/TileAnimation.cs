using Microsoft.Xna.Framework;

namespace JetPacReloaded
{
    public class TileAnimation : Tile
    {
        private int m_animFrames;
        private int m_frame;
        private int m_timer;

        public TileAnimation(int value, int x, int y, int animFrames, TileCollisionType tileCollisionType) : base(value, x, y, tileCollisionType)
        {
            m_animFrames = animFrames;
            m_frame = 0;// value * m_width;
            m_timer = 0;
        }

        public override Rectangle TileTexture
        {
            get
            {
                m_timer += 1;
                if (m_timer == 20)
                {
                    m_frame = (m_frame + 1) % m_animFrames;
                    TextureX = (Value + m_frame) * m_width;
                    m_timer = 0;
                }
                return new Rectangle(TextureX, TextureY, m_width, m_height);
            }
        }
    }
}
