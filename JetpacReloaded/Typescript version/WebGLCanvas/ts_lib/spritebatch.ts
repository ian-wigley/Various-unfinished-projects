import { Color } from "./color.js";
import { Rectangle } from "./rectangle.js";
import { Vector2 } from "./vector2.js";
import { Texture2D } from "../ts_lib/texture2D.js";

import * as mat4 from "../glmatrix/mat4.js"
import * as vec3 from "../glmatrix/vec3.js"
import { Matrix } from "./matrix.js";

export enum SpriteEffects {
    /// <summary>
    /// No options specified.
    /// </summary>
    None = 0,
    /// <summary>
    /// Render the sprite reversed along the X axis.
    /// </summary>
    FlipHorizontally = 1,
    /// <summary>
    /// Render the sprite reversed along the Y axis.
    /// </summary>
    FlipVertically = 2
}

// export type Texture2D = HTMLImageElement;

export class SpriteBatch {

    private canvas: HTMLCanvasElement;
    private ctx: CanvasRenderingContext2D;
    private transformMatrix: Matrix;

    private gl: WebGLRenderingContext;

    // private zNear: number = 0.1;
    // private zFar: number = 100.0;
    // private aspect: number = 0;
    // // In radians
    // private fieldOfView: number = 45 * Math.PI / 180;

    // private shaderProgram;
    private mvMatrix = mat4.create();
    private pMatrix = mat4.create();

    // private vertexPositionBuffer;
    // private vertexIndexBuffer;
    // private cubeVertexTextureCoordBuffer;

    // private vertices;
    // private indices;
    // private textureCoords;
    // private animTexture;

    // count = texturewidth / number of frames (1/17 = 0.0588)
    private count: number = 0.0588;
    private startX: number = 0;
    private endX: number = this.count;

    private red: number = 0;
    private blue: number = 0;
    private green: number = 0;
    private hmtlColour: string = "#000000";

    private delay: boolean = false;

    public get Canvas(): HTMLCanvasElement {
        return this.canvas;
    }

    constructor(non?: any) {
        this.canvas = <HTMLCanvasElement>document.getElementById("canvas");
        // mat4.translate(this.mvMatrix, this.mvMatrix, vec3.fromValues(-5, 4, -10))
    }

    public configureGL(): void {
        let canvas = <HTMLCanvasElement>document.getElementById("canvas");
        let names = ["webgl", "experimental-webgl", "webkit-3d", "mozwebgl"];
        for (const name of names) {
            try {
                this.gl = <WebGLRenderingContext>canvas.getContext(name);
            } catch (e) { }
            if (this.gl) {
                break;
            }
        }
        if (this.gl == null) {
            //this.ctx = this.canvas.getContext("2d");
            alert("Could not initialise WebGL");
            return null;
        }
    }

    public get GL(): WebGLRenderingContext {
        return this.gl;
    }

    private DrawScene(texture: Texture2D, param2: any, param3?: any, param4?: any, param5?: any, param6?: any, param7?: any, param8?: any, param9?: any): void {

        // this.gl = texture.GL;
        // mat4.rotate(this.mvMatrix, this.mvMatrix, 0.01, vec3.fromValues(0, 1, 0));
        // mat4.translate(this.mvMatrix, this.mvMatrix, vec3.fromValues(param2.X/100, param2.Y/100, 0))
        // mat4.translate(this.mvMatrix, this.mvMatrix, vec3.fromValues(0, 0, 0))


        this.gl.useProgram(texture.ShaderProgram);

        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, texture.VertexPositionBuffer);
        this.gl.vertexAttribPointer(texture.ShaderProgram.vertexPositionAttribute, texture.VertexPositionBuffer.itemSize, this.gl.FLOAT,
            false, 0, 0);
        this.gl.enableVertexAttribArray(texture.ShaderProgram.vertexPositionAttribute);

        // Tell WebGL how to pull out the texture coordinates from
        // the texture coordinate buffer into the textureCoord attribute.
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, texture.CubeVertexTextureCoordBuffer);
        this.gl.vertexAttribPointer(texture.ShaderProgram.textureCoordAttribute, texture.CubeVertexTextureCoordBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
        this.gl.enableVertexAttribArray(texture.ShaderProgram.textureCoordAttribute);

        // Tell WebGL we want to affect texture unit 0
        this.gl.activeTexture(this.gl.TEXTURE0);

        // Bind the texture to texture unit 0
        this.gl.bindTexture(this.gl.TEXTURE_2D, texture.AnimTexture);

        // Tell the shader we bound the texture to texture unit 0
        this.gl.uniform1i(texture.ShaderProgram.samplerUniform, 0);

        this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, texture.VertexIndexBuffer);

        this.SetMatrixUniforms(texture);
        this.gl.drawElements(this.gl.TRIANGLES, texture.Indices.length, this.gl.UNSIGNED_SHORT, 0);
        // this.UpdateTextureBuffer();
    }

    private SetMatrixUniforms(texture): void {
        this.gl.uniformMatrix4fv(texture.ShaderProgram.pMatrixUniform, false, texture.PMatrix);
        this.gl.uniformMatrix4fv(texture.ShaderProgram.mvMatrixUniform, false, texture.MvMatrix);
    }

    public Draw(texture: Texture2D, param2: any, param3?: any, param4?: any, param5?: any, param6?: any, param7?: any, param8?: any, param9?: any): void {

        // Commented out for now...
        param2.X = param2.X + this.transformMatrix.M41;///100;
        param2.Y = param2.Y + this.transformMatrix.M42;///100;

        if (this.ctx == null) {

            // If param2 is vector, check its initial location
            // if theres a change call translate

            if (param2 instanceof Vector2) {
                texture.setScreenLocation(param2);
            }

            if (param2 instanceof Rectangle) {
                let p = new Vector2(param2.X, param2.Y);
                texture.setScreenLocation(p);
            }


            if (param3 instanceof Rectangle) {
                texture.GrabTexture(param3);
            }


            this.DrawScene(texture, param2, param3, param4, param5, param6, param7, param8, param9);
        }
        else {
            // // drawImage(image, dx, dy)
            // // drawImage(image, dx, dy, dWidth, dHeight)
            // // drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)

            // // if (!param4) {
            // // // if (typeof (param2) == "number" && typeof (param3) =="number" ) {
            // //     this.ctx.drawImage(texture, param2, param3);
            // // }
            // // else {
            // //     // this.ctx.drawImage(texture, param2.x, param3.y, param4, param5, param6, param7, param8, param9);
            // //     this.ctx.drawImage(texture, param2.x, param3.y, 64, 64, 100, 100, 64, 64);
            // // }mat4.translate(this.mvMatrix, this.mvMatrix, vec3.fromValues(0, 0, -7.0))

            // if (param2 instanceof Vector2 && typeof (param3) == "string" && !param4 && !param5 && !param6 && !param7 && !param8 && !param9) {
            //     this.ctx.drawImage(texture, param2.X, param2.Y);
            // }

            // // //public Draw(texture: Texture2D, position: Vector2, sourceRectangle?: Rectangle, color?: Color): void;
            // // if (param2 instanceof Vector2 && param3 instanceof Rectangle && typeof (param4) == "string" && !param5 && !param6 && !param7 && !param8 && !param9) {
            // //     this.ctx.drawImage(texture, param3.X, param3.Y, param3.Width, param3.Height, param2.X, param2.Y, param3.Width, param3.Height);
            // // }

            // // //public Draw(texture: Texture2D, position: Vector2, sourceRectangle?: Rectangle, color?: Color, rotation?: number, origin?: Vector2, scale?: Vector2, effects?: SpriteEffects, layerDepth?: number): void;
            // // if (param2 instanceof Vector2 && param3 instanceof Rectangle && typeof (param4) == "string" && typeof (param5) == "number"
            // //     && param6 instanceof Vector2 && param7 instanceof Vector2 && typeof (param8) == "number" && typeof (param9) == "number") {
            // //     //alert("Not implemented");
            // // }

            // // //public Draw(texture: Texture2D, position: Vector2, sourceRectangle?: Rectangle, color?: Color, rotation?: number, origin?: Vector2, scale?: number, effects?: SpriteEffects, layerDepth?: number): void;
            // if (param2 instanceof Vector2 && param3 instanceof Rectangle && typeof (param4) == "string" && typeof (param5) == "number"
            //     && param6 instanceof Vector2 && typeof (param7) == "number" && typeof (param8) == "number" && typeof (param9) == "number") {
            //     this.ctx.drawImage(texture, param3.X, param3.Y, param3.Width, param3.Height, param2.X, param2.Y, param3.Width, param3.Height);
            // }

            // // //public Draw(texture: Texture2D, destinationRectangle: Rectangle, color: Color): void;
            // // if (param2 instanceof Rectangle && typeof (param3) == "string" && !param4 && !param5 && !param6 && !param7 && !param8 && !param9) {

            // // }

            // // //public Draw(texture: Texture2D, destinationRectangle: Rectangle, sourceRectangleColor?: Rectangle, color?: Color): void;
            // if (param2 instanceof Rectangle && param3 instanceof Rectangle && typeof (param4) == "string" && !param5 && !param6 && !param7 && !param8 && !param9) {
            //     this.ctx.drawImage(texture, param3.X, param3.Y, param3.Width, param3.Height, param2.X, param2.Y, param3.Width, param3.Height);
            // }

            // // //public Draw(texture: Texture2D, destinationRectangle: Rectangle, sourceRectangle?: Rectangle, color?: Color, rotation?: number, origin?: Vector2, effects?: SpriteEffects, layerDepth?: number): void;
            // // if (param2 instanceof Rectangle && param3 instanceof Rectangle && typeof (param4) == "string" && typeof (param5) == "number"
            // //     && param6 instanceof Vector2 && typeof (param7) == "number" && typeof (param8) == "number" && !param9) {
            // // }

        }
    }

    public DrawString(font: any, value: any, position: any, color: any): void {
        if (this.ctx != null) {
            this.ctx.font = font;
            this.ctx.fillStyle = color;
            this.ctx.fillText(value, position.X, position.Y);
        }
    }

    public Begin(
        sortMode = null,
        blendState = null,
        samplerState = null,
        depthStencilState = null,
        rasterizerState = null,
        effect = null,
        transformMatrix?: Matrix
    ): void {
        this.transformMatrix = sortMode;

        // if (this.ctx == null) {
        //     this.gl.clearColor(0.0, 0.0, 0.0, 1.0);  // Clear to black, fully opaque
        //     this.gl.clearDepth(1.0);                 // Clear everything
        //     this.gl.enable(this.gl.DEPTH_TEST);      // Enable depth testing
        //     this.gl.depthFunc(this.gl.LEQUAL);       // Near things obscure far things
        //     // Clear the canvas before we start drawing on it.
        //     this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
        // }
        // else {
        //     this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        //     this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        // }
    }

    public Clear(col: string): void {
        this.ConvertColour(col);
        if (this.ctx == null) {
            // Clear using the r, g, b values, fully opaque
            this.gl.clearColor(this.red, this.green, this.blue, 1.0);
            this.gl.clearDepth(1.0);                 // Clear everything
            this.gl.enable(this.gl.DEPTH_TEST);      // Enable depth testing
            this.gl.depthFunc(this.gl.LEQUAL);       // Near things obscure far things
            // Clear the canvas before we start drawing on it.
            this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
        }
        else {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
            this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        }
    }

    private ConvertColour(colour: string): void {
        if (this.hmtlColour != colour) {
            if (colour.length == 7) {
                this.red = this.parseValue(colour[1], colour[2]);
                this.green = this.parseValue(colour[3], colour[4]);
                this.blue = this.parseValue(colour[5], colour[6]);
            }
            this.hmtlColour = colour;
        }
    }

    private parseValue(one: string, two: string): number {
        return parseInt('0x' + one + two) / 255;
    }

    // TODO
    public End(): void { }

}