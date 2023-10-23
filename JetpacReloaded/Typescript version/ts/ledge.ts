import { Rectangle } from "../ts_lib/rectangle.js";
import { Texture2D } from "../ts_lib/spritebatch.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Ledge extends BaseObject {
    constructor(x: number, y: number, image: Texture2D) {
        super();
        this.m_image = image;
        this.m_height = image.height;
        this.m_width = image.width;
        this.m_rect = new Rectangle(x, y, this.m_width, this.m_height);
        this.m_screenLocation = new Vector2(x, y);
    }
    public Update(x: number, y: number): void {
        this.m_screenLocation.X += x;
        this.m_screenLocation.Y += y;
        this.m_rect = new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
    }
    public get LedgeRect(): Rectangle {
        return this.m_rect;
    }
}