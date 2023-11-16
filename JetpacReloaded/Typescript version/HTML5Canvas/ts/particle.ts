import { Color } from "../ts_lib/color";
import { SpriteBatch, Texture2D } from "../ts_lib/spritebatch";
import { Vector2 } from "../ts_lib/vector2.js";
import { BaseObject } from "./baseobject.js";
import { Camera } from "./camera.js";

export class Particle extends BaseObject {
    private lifeSpan: number = 20;
    private particleX: number;
    private particleY: number;
    private length: number = 0;
    private count: number = 0;
    private scale: number = 1.0;
    private colors: Color[] = [Color.White,
    Color.Yellow,
    Color.Orange,
    Color.Brown,
    Color.Red,
    Color.Brown,
    Color.Brown,
    Color.Black];

    constructor(image: Texture2D) {
        super();
        this.m_image = image;
    }
    
    public Update(x: number, y: number, facingLeft: boolean, showParticles: boolean): void {
        if (showParticles == true) {
            if (this.particleY < this.length) {
                this.particleY++;
            }
            if (this.particleY >= this.length) {
                if (facingLeft == true) {
                    this.particleX = x + 20 + this.rand.Next(0, 10);
                    this.length = y + 40 + this.lifeSpan;
                    this.particleY = y + 40 + this.rand.Next(0, 10);
                }
                else {
                    this.particleX = x + this.rand.Next(0, 10);
                    this.length = y + 40 + this.lifeSpan;
                    this.particleY = y + 40 + this.rand.Next(0, 10);
                }
            }
            if (this.particleY == (this.length - 20)) {
                this.count = 0;
                this.scale = 1.0;
            }
            if (this.particleY == (this.length - 15)) {
                this.count = 1;
                this.scale = 0.9;
            }
            if (this.particleY == (this.length - 10)) {
                this.count = 2;
                this.scale = 0.8;
            }
            if (this.particleY == (this.length - 5)) {
                this.count = 3;
                this.scale = 0.7;
            }
            if (this.particleY == (this.length)) {
                this.count = 4;
                this.scale = 0.45;
            }
        }
        if (showParticles == false) {
            this.count = 7;
            this.particleX = 0;
            this.particleY = 0;
            this.length = 0;
        }
    }
    // public Draw(spriteBatch: SpriteBatch, camera: Camera): void {
    //     spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Additive,/*transformMatrix:*/camera.Transform);
    //     let particleLocation: Vector2 = new Vector2(this.particleX, this.particleY);
    //     spriteBatch.Draw(this.m_image, particleLocation, null, this.colors[this.count], 0, new Vector2(0, 9), this.scale, SpriteEffects.None, 0);
    //     spriteBatch.End();
    // }
}