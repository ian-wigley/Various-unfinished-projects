import { Rectangle } from "../ts_lib/rectangle.js";
import { Texture2D } from "../ts_lib/spritebatch.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";
import { Ledge } from "./ledge.js";

export class Fuel extends BaseObject {
    private landedOnLedge: boolean = false;
    constructor(image: Texture2D) {
        super();
        this.m_image = image;
        this.m_width = image.width;
        this.m_height = image.height + 2;
        this.m_screenLocation = new Vector2(this.rand.Next(0, 750), -30);
    }
    public Update(ledges: Array<Ledge>): void {
        this.m_rect = new Rectangle(this.m_screenLocation.X, this.m_screenLocation.Y, this.m_width, this.m_height);
        if (!this.landedOnLedge) {
            ledges.forEach(function (ledge) {
                if (!this.m_rect.Intersects(ledge.LedgeRect)) {
                    this.m_screenLocation.Y += 0.2;
                }
                else {
                    this.landedOnLedge = true;
                }
            });
        }
    }
    public UpdatePosition(x: number, y: number): void {
        this.m_screenLocation.X = x;
        this.m_screenLocation.Y = y;
    }
    public LowerFuel(): boolean {
        this.m_screenLocation.X = 440;
        if (this.m_screenLocation.Y < 450) {
            this.m_screenLocation.Y++;
        }
        return this.m_screenLocation.Y > 448;
    }
    public get FuelRect(): Rectangle {
        return this.m_rect;
    }
}
