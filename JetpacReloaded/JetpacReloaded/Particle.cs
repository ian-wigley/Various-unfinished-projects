using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Particle : BaseObject
    {
        private readonly int lifeSpan = 20;
        private int particleX;
        private int particleY;
        private int length = 0;
        private int count = 0;
        private float scale = 1.0f;
        private readonly Color[] colors = {Color.White,
                          Color.Yellow,
                          Color.Orange,
                          Color.Brown,
                          Color.Red,
                          Color.Brown,
                          Color.Brown,
                          Color.Black };

        public Particle(Texture2D image)
        {
            m_image = image;
        }

        public void Update(int x, int y, bool facingLeft, bool showParticles)
        {
            if (showParticles == true)
            {
                if (particleY < length)
                {
                    particleY++;
                }
                if (particleY >= length)
                {
                    if (facingLeft == true)
                    {
                        particleX = x + 20 + rand.Next(0, 10);
                        length = y + 40 + lifeSpan;
                        particleY = y + 40 + rand.Next(0, 10);
                    }
                    else
                    {
                        particleX = x + rand.Next(0, 10);
                        length = y + 40 + lifeSpan;
                        particleY = y + 40 + rand.Next(0, 10);
                    }
                }

                if (particleY == (length - 20))
                {
                    count = 0;
                    scale = 1.0f;
                }
                if (particleY == (length - 15))
                {
                    count = 1;
                    scale = 0.9f;
                }
                if (particleY == (length - 10))
                {
                    count = 2;
                    scale = 0.8f;
                }
                if (particleY == (length - 5))
                {
                    count = 3;
                    scale = 0.7f;
                }
                if (particleY == (length))
                {
                    count = 4;
                    scale = 0.45f;
                }
            }

            // Hide the particles when not in use
            if (showParticles == false)
            {
                count = 7;
                particleX = 0;
                particleY = 0;
                length = 0;
            }
        }

        new public void Draw(SpriteBatch spriteBatch, Camera camera)
        {
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Additive, transformMatrix: camera.Transform);
            Vector2 particleLocation = new Vector2(particleX, particleY);
            spriteBatch.Draw(m_image, particleLocation, null, colors[count], 0, new Vector2(0, 9), scale, SpriteEffects.None, 0);
            spriteBatch.End();
        }
    }
}
