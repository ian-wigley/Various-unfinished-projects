using Microsoft.Xna.Framework;

namespace JetPacReloaded
{
    public class TileNoAnimation : Tile
    {
        public TileNoAnimation(int value, int x, int y, TileCollisionType tileCollisionType) : base(value, x, y, tileCollisionType)
        {
        }

        public override Rectangle TileTexture { get { return new Rectangle(TextureX, TextureY, m_width, m_height); } }
    }
}
