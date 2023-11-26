import { Color } from "../ts_lib/color.js";
import { SpriteBatch } from "../ts_lib/spritebatch.js";
import { Texture2D } from "../ts_lib/texture2D.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";

export class Star extends BaseObject {
    starLayer1X: number = this.rand.Next(0, 800);
    starLayer1Y: number = this.rand.Next(50, 440);
    starLayer2X: number = this.rand.Next(0, 800);
    starLayer2Y: number = this.rand.Next(52, 440);

    constructor(image: Texture2D) {
        super();
        this.m_image = image;
    }

    public Update(): void {
        if (this.starLayer1X < 800) {
            this.starLayer1X++;
        }
        else {
            this.starLayer1X = this.rand.Next(-400, 0);
        }
        if (this.starLayer2X < 800) {
            this.starLayer2X += 2;
        }
        else {
            this.starLayer2X = this.rand.Next(-400, 0);
        }
    }

    public Draw(spriteBatch: SpriteBatch): void {
        let starLocationLayer1: Vector2 = new Vector2(this.starLayer1X, this.starLayer1Y);
        spriteBatch.Draw(this.m_image, starLocationLayer1, Color.DarkGray);
        let starLocationLayer2: Vector2 = new Vector2(this.starLayer2X, this.starLayer2Y);
        spriteBatch.Draw(this.m_image, starLocationLayer2, Color.White);
    }
}