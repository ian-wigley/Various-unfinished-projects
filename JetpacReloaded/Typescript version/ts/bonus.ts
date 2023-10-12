import { Color } from "../ts_lib/color.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { SpriteBatch, Texture2D } from "../ts_lib/spritebatch.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Bonus extends BaseObject {
    private bonusLanded: boolean = false;
    private m_prevFrame: number = 0;

    constructor(image: Texture2D) {
        super();
        this.m_frame = this.rand.Next(0, 4);
        this.m_image = image;
        this.m_width = image.width / 5;
        this.m_height = image.height + 2;
        this.m_screenLocation = new Vector2(this.rand.Next(0, 750), -30);
    }

    public Update(): void {
        if (!this.bonusLanded) {
            this.m_screenLocation.Y++;
        }
        this.m_rect = new Rectangle(this.m_frame * this.m_width, 0, this.m_width, this.m_height);
    }
    public Draw(spriteBatch: SpriteBatch): void {
        let bonusLocation: Vector2 = new Vector2(this.m_screenLocation.X, this.m_screenLocation.Y);
        spriteBatch.Draw(this.m_image, bonusLocation, this.m_rect, Color.White, 0, Vector2.Zero, 1.0, 0, 0);
    }
    public get BonRect(): Rectangle {
        return new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
    }
    public set BonusLanded(value: boolean) {
        this.bonusLanded = value;
    }
    public Reset(): void {
        this.m_prevFrame = this.m_frame;
        this.m_frame = this.rand.Next(0, 4);
        if (this.m_frame == this.m_prevFrame) {
            this.m_frame = (this.m_frame + 1) % 4;
        }
        this.m_screenLocation.X = this.rand.Next(0, 750);
        this.m_screenLocation.Y = -30;
        this.bonusLanded = false;
    }
}
