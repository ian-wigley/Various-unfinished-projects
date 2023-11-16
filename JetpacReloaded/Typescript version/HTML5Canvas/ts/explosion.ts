import { Color } from "../ts_lib/color.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { SpriteBatch, Texture2D } from "../ts_lib/spritebatch.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Explosion extends BaseObject {
    private m_animationComplete: boolean = false;
    constructor(x: number, y: number, image: Texture2D) {
        super();
        this.m_image = image;
        this.m_height = image.height;
        this.m_width = image.width / 16;
        this.m_screenLocation = new Vector2(x, y);
    }
    public Update(): void {
        if (this.m_frame < 16) {
            this.m_frame += 1;
        }
        else {
            this.m_animationComplete = true;
        }
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
    }
    public Draw(spriteBatch: SpriteBatch): void {
        spriteBatch.Draw(this.m_image, this.m_screenLocation, this.m_rect, Color.White, 0, Vector2.Zero, 1.0, 0, 0);
    }
    public get AnimationComplete(): boolean {
        return this.m_animationComplete;
    }
}