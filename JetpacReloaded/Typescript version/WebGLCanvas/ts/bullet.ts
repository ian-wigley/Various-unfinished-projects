import { Rectangle } from "../ts_lib/rectangle.js";
import { Texture2D } from "../ts_lib/texture2D.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Bullet extends BaseObject {
    private m_left: boolean = false;
    private m_offscreen: boolean = false;

    constructor(x: number, y: number, image: Texture2D, left: boolean) {
        super();
        this.m_image = image;
        this.m_left = left;
        this.m_screenLocation = new Vector2(x, y);
    }
    public Update(): void {
        if (this.m_screenLocation.X < 800 && !this.m_left) {
            this.m_screenLocation.X += 6;
        }
        else if (this.m_screenLocation.X > -40) {
            this.m_screenLocation.X -= 6;
        }
        if (this.m_screenLocation.X >= 800 || this.m_screenLocation.X <= -40) {
            this.m_offscreen = true;
        }
    }
    public get Offscreen(): boolean {
        return this.m_offscreen;
    }
    public get BulletRect(): Rectangle {
        return new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_image.width, this.m_image.height);
    }
}
