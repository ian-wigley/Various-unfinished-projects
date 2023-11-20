import { Rectangle } from "../ts_lib/rectangle.js";

export enum TileCollisionType {
    Passable = 0,
    Impassable = 1,
    Platform = 2,
    Wall = 4
}

export class Tile {
    protected m_width: number = 62;
    protected m_height: number = 48;
    protected X: number;
    protected Y: number;
    protected TextureX: number;
    protected TextureY: number;
    protected Value: number;
    private tileCollisionsType: TileCollisionType;

    constructor(value: number, x: number, y: number, tileCollisionType: TileCollisionType) {
        this.Value = value;
        this.X = x;
        this.Y = y;
        this.TextureX = value * this.m_width;
        this.TextureY = 0;
        this.tileCollisionsType = tileCollisionType;
        // console.log(tileCollisionType);
    }

    public Drawable(x: number, y: number): boolean {
        return true;
    }

    public get TileRect(): Rectangle {
        return new Rectangle(this.X, this.Y, this.m_width, this.m_height);
    }

    public get GetTileCollisionType():TileCollisionType {
        return this.tileCollisionsType;
    }

    // public TileTexture: Rectangle;
}