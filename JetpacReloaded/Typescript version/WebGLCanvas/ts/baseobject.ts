import { Color } from "../ts_lib/color.js";
import { Random } from "../ts_lib/random.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { SpriteBatch } from "../ts_lib/spritebatch.js";
import { Texture2D } from "../ts_lib/texture2D.js";
import { Vector2 } from "../ts_lib/vector2.js";

export class BaseObject {
    protected m_width: number;
    protected m_height: number;
    protected m_frame: number;
    protected m_image: Texture2D;
    protected m_rect: Rectangle;
    protected m_screenLocation: Vector2;
    protected rand: Random = new Random();

    constructor() {
        this.m_width = 0;
        this.m_height = 0;
        this.m_frame = 0;
        this.m_rect = new Rectangle(0, 0, this.m_width, this.m_height);
    }

    public Draw(spriteBatch: SpriteBatch): void {
        spriteBatch.Draw(this.m_image, this.m_screenLocation, Color.White);
    }
}