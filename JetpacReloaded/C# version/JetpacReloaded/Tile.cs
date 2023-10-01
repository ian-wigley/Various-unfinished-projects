using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    /// <summary>
    /// Controls the collision detection and response behavior of a tile.
    /// </summary>
    public enum TileCollisionType
    {
        /// <summary>
        /// A passable tile is one which does not hinder player motion at all.
        /// </summary>
        Passable = 0,

        /// <summary>
        /// An impassable tile is one which does not allow the player to move through
        /// it at all. It is completely solid.
        /// </summary>
        Impassable = 1,

        /// <summary>
        /// A platform tile is one which behaves like a passable tile except when the
        /// player is above it. A player can jump up through a platform as well as move
        /// past it to the left and right, but can not fall down through the top of it.
        /// </summary>
        Platform = 2,

        Wall = 4,
    }

    public class Tile
    {
        protected const int m_width = 62;
        protected const int m_height = 48;

        public Tile(int value, int x, int y, TileCollisionType tileCollisionType)
        {
            Value = value;
            X = x;
            Y = y;
            TextureX = value * m_width;
            TextureY = 0;//  value * m_height;
            GetTileCollisionType = tileCollisionType;
        }

        public bool Drawable(int x, int y)
        {
            //var draw = X < x + 800 && Y < y + 600;
            //return X < x + 800 && Y < y + 600;
            return true;
        }

        protected int X { get; private set; }
        protected int Y { get; private set; }
        protected int TextureX { get; set; }
        protected int TextureY { get; private set; }
        protected int Value { get; private set; }

        public TileCollisionType GetTileCollisionType { get; private set; }

        public Rectangle TileRect { get { return new Rectangle(X, Y, m_width, m_height); } }

        public virtual Rectangle TileTexture { get; }

            //protected Rectangle TileTexture { get { return new Rectangle(TextureX, TextureY, m_width, m_height); } }
        }
}
