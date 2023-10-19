import { Color } from "../ts_lib/color";
import { Rectangle } from "../ts_lib/rectangle";
import { SpriteBatch, Texture2D } from "../ts_lib/spritebatch";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Enemy extends BaseObject {

    constructor(image: Texture2D) {
        super();
        this.m_image = image;
        this.m_width = image.width / 8;
        this.m_height = image.height;
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
        this.m_screenLocation = new Vector2(this.rand.Next(0, 800), this.rand.Next(50, 440));
    }

    public Update(level: number): void {
        if (this.m_screenLocation.X > -70) {
            this.m_screenLocation.X--;
        }
        else {
            this.ResetMeteor();
        }
        this.m_frame = level % 8;
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
    }

    public ResetMeteor(): void {
        this.m_screenLocation.X = this.rand.Next(800, 1200);
        this.m_screenLocation.Y = this.rand.Next(50, 400);
    }

    public Draw(spriteBatch: SpriteBatch): void {
        spriteBatch.Draw(this.m_image, this.m_screenLocation, this.m_rect, Color.White, 0, Vector2.Zero, 1.0, 0, 0);
    }

    public get AlienRect(): Rectangle {
        return new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
    }
}