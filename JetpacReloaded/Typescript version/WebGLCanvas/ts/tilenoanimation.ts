import { Rectangle } from "../ts_lib/rectangle.js";
import { Tile, TileCollisionType } from "./tile.js";

export class TileNoAnimation extends Tile {

    constructor(value: number, x: number, y: number, tileCollisionType: TileCollisionType) {
        super(value, x, y, tileCollisionType);
    }

    public get TileTexture(): Rectangle {
        return new Rectangle(this.TextureX, this.TextureY, this.m_width, this.m_height);
    }
}