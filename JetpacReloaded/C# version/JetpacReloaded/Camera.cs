using Microsoft.Xna.Framework;

namespace JetpacReloaded
{
    public class Camera
    {
        public Matrix Transform { get; private set; }

        private Matrix position;

        public void Follow(Jetman target)
        {
            float x = 400.0f;
            float y = 300.0f;
            if (target.JetmanPosition.X >= 380 && target.JetmanPosition.X <= 2160)
            {
                x = -target.JetmanPosition.X - (target.JetmanRect.Width / 2);
            }
            else if (target.JetmanPosition.X < 380)
            {
                x = -380 - (target.JetmanRect.Width / 2);
            }
            else if (target.JetmanPosition.X > 2160)
            {
                x = -2160 - (target.JetmanRect.Width / 2);
            }

            if (target.JetmanPosition.Y > 270 && target.JetmanPosition.Y < 620)
            {
                y = -target.JetmanPosition.Y - (target.JetmanRect.Height / 2);
            }
            else if (target.JetmanPosition.Y <= 270)
            {
                y = -270 - (target.JetmanRect.Height / 2);
            }
            else if (target.JetmanPosition.Y >= 620)
            {
                y = -620 - (target.JetmanRect.Height / 2);
            }

            position = Matrix.CreateTranslation(x, y, 0);

            // The offset value is used to move the camera to centred around the player
            Matrix offset = Matrix.CreateTranslation(400, 300, 0);
            Transform = position * offset;

        }

        public Vector2 CameraPos { get { return new Vector2(Transform.Translation.X, Transform.Translation.Y); } }
    }
}
