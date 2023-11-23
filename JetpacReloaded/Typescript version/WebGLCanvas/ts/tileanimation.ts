import { Rectangle } from "../ts_lib/rectangle.js";
import { Tile, TileCollisionType } from "./tile.js";

export class TileAnimation extends Tile {
    private m_animFrames: number;
    private m_frame: number;
    private m_timer: number;

    constructor(value: number, x: number, y: number, animFrames: number, tileCollisionType: TileCollisionType) {
        super(value, x, y, tileCollisionType);
        this.m_animFrames = animFrames;
        this.m_frame = 0;
        this.m_timer = 0;
    }

    public get TileTexture(): Rectangle {
        this.m_timer += 1;
        if (this.m_timer == 20) {
            this.m_frame = (this.m_frame + 1) % this.m_animFrames;
            this.TextureX = (this.Value + this.m_frame) * this.m_width;
            this.m_timer = 0;
        }
        return new Rectangle(this.TextureX, this.TextureY, this.m_width, this.m_height);
    }
}