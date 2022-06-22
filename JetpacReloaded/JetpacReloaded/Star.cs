using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace JetpacReloaded
{
    public class Star : BaseObject
    {
        int starLayer1X = rand.Next(0, 800);
        int starLayer1Y = rand.Next(50, 440);

        int starLayer2X = rand.Next(0, 800);
        int starLayer2Y = rand.Next(52, 440);

        public Star(Texture2D image)
        {
            m_image = image;
        }

        public void Update()
        {
            if (starLayer1X < 800)
            {
                starLayer1X++;
            }
            else
            {
                starLayer1X = rand.Next(-400, 0);
            }

            if (starLayer2X < 800)
            {
                starLayer2X += 2;
            }
            else
            {
                starLayer2X = rand.Next(-400, 0);
            }
        }

        new public void Draw(SpriteBatch spriteBatch)
        {
            Vector2 starLocationLayer1 = new Vector2(starLayer1X, starLayer1Y);
            spriteBatch.Draw(m_image, starLocationLayer1, Color.DarkGray);

            Vector2 starLocationLayer2 = new Vector2(starLayer2X, starLayer2Y);
            spriteBatch.Draw(m_image, starLocationLayer2, Color.White);
        }
    }
}
