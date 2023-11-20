import { Color } from "../ts_lib/color.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { SpriteBatch } from "../ts_lib/spritebatch.js";
import { Texture2D } from "../ts_lib/texture2D.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Rocket extends BaseObject {
    constructor(x: number, y: number, image: Texture2D, frame: number, width: number, height: number) {
        super();
        this.m_image = image;
        this.m_frame = frame;
        this.m_width = width;
        this.m_height = height;
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
        this.m_screenLocation = new Vector2(x, y);
    }
    public Update(x: number, y: number): void {
        this.m_screenLocation.X = x;
        this.m_screenLocation.Y = y;
    }
    public LowerSectionOne(): boolean {
        this.m_screenLocation.X = 422;
        if (this.m_screenLocation.Y < 383) {
            this.m_screenLocation.Y++;
        }
        return this.m_screenLocation.Y >= 383;
    }
    public LowerSectionTwo(): boolean {
        this.m_screenLocation.X = 422;
        if (this.m_screenLocation.Y < 323) {
            this.m_screenLocation.Y++;
        }
        return this.m_screenLocation.Y >= 323;
    }
    public TakeOff(): boolean {
        this.m_screenLocation.Y -= 1.5;
        return this.m_screenLocation.Y > -200;
    }
    public Draw(spriteBatch: SpriteBatch): void {
        spriteBatch.Draw(this.m_image, this.m_screenLocation, this.m_rect, Color.White, 0, Vector2.Zero, 1.0, 0, 0);
    }
    public get RocketRect(): Rectangle {
        return new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
    }
}