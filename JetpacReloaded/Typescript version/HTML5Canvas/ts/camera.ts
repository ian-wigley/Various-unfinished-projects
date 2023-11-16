import { Matrix } from "../ts_lib/matrix.js"
import { Vector2 } from "../ts_lib/vector2.js";

export class Camera {

    private transform: Matrix;
    private position: Matrix;

    public Follow(target): void {
        let x = 400.0;
        let y = 300.0;
        if (target.JetmanPosition.X >= 380 && target.JetmanPosition.X <= 2160) {
            x = -target.JetmanPosition.X - (target.JetmanRect.Width / 2);
        }
        else if (target.JetmanPosition.X < 380) {
            x = -380 - (target.JetmanRect.Width / 2);
        }
        else if (target.JetmanPosition.X > 2160) {
            x = -2160 - (target.JetmanRect.Width / 2);
        }

        if (target.JetmanPosition.Y > 270 && target.JetmanPosition.Y < 620) {
            y = -target.JetmanPosition.Y - (target.JetmanRect.Height / 2);
        }
        else if (target.JetmanPosition.Y <= 270) {
            y = -270 - (target.JetmanRect.Height / 2);
        }
        else if (target.JetmanPosition.Y >= 620) {
            y = -620 - (target.JetmanRect.Height / 2);
        }

        this.position = Matrix.CreateTranslation(x, y, 0);

        // The offset value is used to move the camera to centred around the player
        let offset: Matrix = Matrix.CreateTranslation(400, 300, 0);
        this.Transform =  Matrix.Multiply(this.position, offset);
    }

    public get Transform(): Matrix {
        return this.transform;
    }

    public set Transform(value: Matrix) {
        this.transform = value;
    }

    public get CameraPos(): Vector2 {
        return new Vector2(this.Transform.Translation.X, this.Transform.Translation.Y);
    }
}