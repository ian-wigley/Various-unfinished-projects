import { Color } from "../ts_lib/color.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { SpriteBatch, SpriteEffects, Texture2D } from "../ts_lib/spritebatch.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Jetman extends BaseObject {
    private m_flip: SpriteEffects = SpriteEffects.None;
    private m_debugImage: Texture2D;

    public constructor(x: number, y: number, image: Texture2D, debugimage: Texture2D) {
        super();
        this.m_image = image;
        this.m_height = 68;// image.Height;
        this.m_width = 64;// image.Width / 5;
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
        this.m_screenLocation = new Vector2(x, y);
        this.m_debugImage = debugimage;
    }

    // public void Update(int x, int y, SpriteEffects flip)
    public Update(vec: Vector2, flip/*:SpriteEffects*/): void {
        //m_screenLocation.X = x;
        //m_screenLocation.Y = y;

        this.m_screenLocation = vec;

        //if (y <= 50) { m_screenLocation.Y = 50; }
        //if (y >= 550) { m_screenLocation.Y = 550; }
        //if (x <= 0) { m_screenLocation.X = 0; }
        //if (x >= 750) { m_screenLocation.X = 750; }

        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
        this.m_flip = flip;
    }

    public Draw(spriteBatch: SpriteBatch): void {
        // // spriteBatch.Draw(this.m_debugImage, this.m_screenLocation, this.JetmanRect, Color.White, 0, Vector2.Zero, 1.0, this.m_flip, 0);
        // spriteBatch.Draw(this.m_image, this.m_screenLocation.X, this.m_screenLocation.Y);
        spriteBatch.Draw(this.m_image, this.m_screenLocation, this.m_rect, Color.White, 0, Vector2.Zero, 1.0, this.m_flip, 0);
    }

    public get JetmanRect(): Rectangle {
        return new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
    }

    public get JetmanPosition(): Vector2 { return this.m_screenLocation; }

    public set JetmanAnimFrame(value) { this.m_frame = value; }
}