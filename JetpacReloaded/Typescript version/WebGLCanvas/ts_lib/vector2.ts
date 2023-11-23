import * as vec3 from "../glmatrix/vec3.js"

export class Vector2 {

    static Zero: any = new Vector2(0, 0);
    private m_x: number;
    private m_y: number;

    constructor(x: number, y: number) {
        this.m_x = x;
        this.m_y = y;
    }

    public get X(): number {
        return this.m_x;
    }

    public set X(value: number) {
        this.m_x = value;
    }

    public get Y(): number {
        return this.m_y;
    }

    public set Y(value: number) {
        this.m_y = value;
    }

    public get Zero(): Vector2 {
        return new Vector2(0, 0);
    }

    public LengthSquared(): number {
        return (this.m_x * this.m_x) + (this.m_y * this.m_y);
    }

    public Equals(other: object): boolean {
        let a = false;
        let b = false;
        if (other instanceof Vector2) {
            a = this.X == other.X;
            b = this.Y == other.Y;
        }
        else {
            a = this.X == parseFloat(other[0].toFixed(2));
            b = this.Y == parseFloat(other[1].toFixed(2));
        }
        return a && b;
    }

    public Subtract(other: object): any {
        let a = 0;
        let b = 0;
        let c = 0;
        if (other instanceof Vector2) {
            a = this.X - other.X;
            b = this.Y - other.Y;
        }
        else {
            a = this.X - other[0];
            b = this.Y - other[1];
        }
        // if (Number.isNaN(a) || Number.isNaN(b)) {
        //     let z = true;
        // }
        return vec3.fromValues(a, b, c);
    }
}