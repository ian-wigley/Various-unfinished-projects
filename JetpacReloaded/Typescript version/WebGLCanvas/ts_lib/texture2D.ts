import * as mat4 from "../glmatrix/mat4.js"
import { Matrix } from "./matrix.js";
import * as vec3 from "../glmatrix/vec3.js"
import { Vector3 } from "./vector3.js";
import { Vector2 } from "./vector2.js";
import { Rectangle } from "./rectangle.js";

export class Texture2D {

    private m_assetName: string = "";
    private m_image: HTMLImageElement;
    private canvas: HTMLCanvasElement;
    private ctx: CanvasRenderingContext2D;


    private transformMatrix: Matrix;

    private gl: WebGLRenderingContext;

    private zNear: number = 0.1;
    private zFar: number = 100.0;
    private aspect: number = 0;
    // In radians
    private fieldOfView: number = 45 * Math.PI / 180;

    private shaderProgram;
    private mvMatrix = mat4.create();
    private pMatrix = mat4.create();

    private vertexPositionBuffer;
    private vertexIndexBuffer;
    private cubeVertexTextureCoordBuffer;

    private vertices;
    private indices;
    private textureCoords;
    private animTexture;

    private x: number = 0;
    private y: number = 0;
    private z: number = -10;
    // private screenLocation = vec3.fromValues(-7.2, 4, this.z);
    private screenLocation = vec3.fromValues(this.x, this.y, this.z);


    constructor(assetName: string, gl: WebGLRenderingContext) {
        this.m_assetName = assetName;
        this.m_image = <HTMLImageElement>document.getElementById(assetName);
        // console.log(assetName);

        this.computeVertices(this.m_image.width, this.m_image.height);

        this.gl = gl;

        this.InitShaders();
        this.InitBuffers();
        this.InitTexture();
        this.SetUpCamera();

        mat4.translate(this.mvMatrix, this.mvMatrix, this.screenLocation)
    }

    private computeVertices(width: number, height: number): void {
        let x = Math.ceil(width / 100);
        let y = Math.ceil(height / 100);
        this.vertices = [
            0.0, 0.0, 0.0,  //v0
            x, 0.0, 0.0,  //v1
            x, -y, 0.0,  //v2
            0.0, -y, 0.0   //v3
        ];
    }

    private SetUpCamera(): void {
        this.aspect = this.gl.drawingBufferWidth / this.gl.drawingBufferHeight;
        mat4.perspective(this.pMatrix,
            this.fieldOfView,
            this.aspect,
            this.zNear,
            this.zFar);
    }

    private InitShaders(): void {
        let fragmentShader = this.GetShader(this.gl, "shader-fs");
        let vertexShader = this.GetShader(this.gl, "shader-vs");

        this.shaderProgram = this.gl.createProgram();
        this.gl.attachShader(this.shaderProgram, vertexShader);
        this.gl.attachShader(this.shaderProgram, fragmentShader);
        this.gl.linkProgram(this.shaderProgram);

        if (!this.gl.getProgramParameter(this.shaderProgram, this.gl.LINK_STATUS)) {
            alert("Could not initialise shaders");
        }

        this.gl.useProgram(this.shaderProgram);

        this.shaderProgram.vertexPositionAttribute = this.gl.getAttribLocation(this.shaderProgram, "aVertexPosition");
        this.gl.enableVertexAttribArray(this.shaderProgram.vertexPositionAttribute);

        // Bind the texture attribute
        this.shaderProgram.textureCoordAttribute = this.gl.getAttribLocation(this.shaderProgram, "aTextureCoord");
        this.gl.enableVertexAttribArray(this.shaderProgram.textureCoordAttribute);

        this.shaderProgram.pMatrixUniform = this.gl.getUniformLocation(this.shaderProgram, "pMatrix");
        this.shaderProgram.mvMatrixUniform = this.gl.getUniformLocation(this.shaderProgram, "mVMatrix");
    }

    private GetShader(gl, id): any {
        let shaderScript = (<HTMLInputElement>document.getElementById(id));
        if (!shaderScript) {
            return null;
        }

        let str = "";
        let k = shaderScript.firstChild;
        while (k) {
            if (k.nodeType == 3) {
                str += k.textContent;
            }
            k = k.nextSibling;
        }

        let shader;
        if (shaderScript.type == "x-shader/x-fragment") {
            shader = gl.createShader(gl.FRAGMENT_SHADER);
        } else if (shaderScript.type == "x-shader/x-vertex") {
            shader = gl.createShader(gl.VERTEX_SHADER);
        } else {
            return null;
        }

        gl.shaderSource(shader, str);
        gl.compileShader(shader);

        if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
            alert(gl.getShaderInfoLog(shader));
            return null;
        }
        return shader;
    }

    private InitBuffers(): void {
        this.vertexPositionBuffer = this.gl.createBuffer();
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.vertexPositionBuffer);

        //           |+ve Y
        //           |
        // X -ve ----0---- +ve X
        //           |
        //           |-ve Y
        // <canvas id="canvas" width="1280" height="720"></canvas>
        // this.vertices = [
        //     0.0, 0.0, 0.0,  //v0
        //     30.0, 0.0, 0.0,  //v1
        //     30.0, -12.0, 0.0,  //v2
        //     0.0, -12.0, 0.0   //v3

        //     // -1.0, -1.0, 0.0,  //v0
        //     // 1.0, -1.0, 0.0,  //v1
        //     // 1.0, 1.0, 0.0,  //v2
        //     // -1.0, 1.0, 0.0   //v3
        // ];
        this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(this.vertices), this.gl.STATIC_DRAW);
        this.vertexPositionBuffer.itemSize = 3;
        this.vertexPositionBuffer.numItems = 4;

        this.cubeVertexTextureCoordBuffer = this.gl.createBuffer();
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexTextureCoordBuffer);
        let textureCoords = [
            0.0, 0.0, //uv0
            1.0, 0.0, //uv1
            1.0, 1.0, //uv2
            0.0, 1.0  //uv3
        ];
        this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(textureCoords), this.gl.STATIC_DRAW);
        this.cubeVertexTextureCoordBuffer.itemSize = 2;
        this.cubeVertexTextureCoordBuffer.numItems = 4;

        this.vertexIndexBuffer = this.gl.createBuffer();
        this.indices = [0, 1, 2, 0, 2, 3];
        this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, this.vertexIndexBuffer);
        this.gl.bufferData(this.gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(this.indices), this.gl.STATIC_DRAW);

        this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, null);
    }

    private InitTexture(): void {
        this.animTexture = this.gl.createTexture();
        this.gl.bindTexture(this.gl.TEXTURE_2D, this.animTexture);

        // Because images have to be download over the internet
        // they might take a moment until they are ready.
        // Until then put a single pixel in the texture so we can
        // use it immediately. When the image has finished downloading
        // we'll update the texture with the contents of the image.
        const level = 0;
        const internalFormat = this.gl.RGBA;
        const width = 1;
        const height = 1;
        const border = 0;
        const srcFormat = this.gl.RGBA;
        const srcType = this.gl.UNSIGNED_BYTE;
        const pixel = new Uint8Array([0, 0, 255, 255]);  // opaque blue
        this.gl.texImage2D(
            this.gl.TEXTURE_2D, level, internalFormat,
            width, height, border, srcFormat, srcType, pixel
        );

        this.animTexture.image = new Image();
        let __this = this;
        this.animTexture.image.onload = function () {

            __this.gl.bindTexture(__this.gl.TEXTURE_2D, __this.animTexture);
            __this.gl.texImage2D(__this.gl.TEXTURE_2D, 0, __this.gl.RGBA, __this.gl.RGBA, __this.gl.UNSIGNED_BYTE, __this.animTexture.image);

            // WebGL1 has different requirements for power of 2 images vs non power of 2 images so check if the image is a
            // power of 2 in both dimensions.
            if (__this.IsPowerOf2(__this.animTexture.image.width) && __this.IsPowerOf2(__this.animTexture.image.height)) {
                // Yes, it's a power of 2. Generate mips.
                __this.gl.generateMipmap(__this.gl.TEXTURE_2D);
            } else {
                // No, it's not a power of 2. Turn of mips and set wrapping to clamp to edge
                __this.gl.texParameteri(__this.gl.TEXTURE_2D, __this.gl.TEXTURE_WRAP_S, __this.gl.CLAMP_TO_EDGE);
                __this.gl.texParameteri(__this.gl.TEXTURE_2D, __this.gl.TEXTURE_WRAP_T, __this.gl.CLAMP_TO_EDGE);
                __this.gl.texParameteri(__this.gl.TEXTURE_2D, __this.gl.TEXTURE_MIN_FILTER, __this.gl.LINEAR);
            }

            // Enable transparency
            __this.gl.blendFunc(__this.gl.SRC_ALPHA, __this.gl.ONE_MINUS_SRC_ALPHA);
            __this.gl.enable(__this.gl.BLEND);

        }
        this.animTexture.image.src = this.m_image.src;
    }

    private IsPowerOf2(value): boolean {
        return (value & (value - 1)) == 0;
    }

    // <canvas id="canvas" width="1280" height="720"></canvas>
    // 1280/2 = 640
    // 720/2 = 360
    //           |+ve
    //           |
    //   -ve ----0---- +ve
    //           |
    //           |-ve
    // -7.2, 4, this.z
    public setScreenLocation(newLocation: Vector2): void {
        // Apply offsets first
        newLocation = new Vector2(newLocation.X / 100 - 7.2, -(newLocation.Y / 100) + 4);
        // if the old location Vector != new location Vector
        // Take one away from the other to give us the amount of movement required ...
        if (!newLocation.Equals(this.screenLocation)) {
            let difference = newLocation.Subtract(this.screenLocation);
            mat4.translate(this.mvMatrix, this.mvMatrix, difference);
            this.screenLocation = vec3.fromValues(newLocation.X, newLocation.Y, this.z);
        }
    }



    private count: number = 0.0588;
    private startX: number = 0;
    private endX: number = this.count;
    // private delay: boolean = false;


    public GrabTexture(rectangle: Rectangle): void {

        this.computeVertices(rectangle.Width, rectangle.Height);

        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.vertexPositionBuffer);
        this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(this.vertices), this.gl.STATIC_DRAW);
        this.vertexPositionBuffer.itemSize = 3;
        this.vertexPositionBuffer.numItems = 4;

        this.startX = this.calculateTextrePercentage(rectangle.X, this.m_image.width);
        this.endX = this.calculateTextrePercentage(rectangle.X + rectangle.Width, this.m_image.width);
        let startY = this.calculateTextrePercentage(rectangle.Y, this.m_image.height);
        let endY = this.calculateTextrePercentage(rectangle.Y + rectangle.Height, this.m_image.height);

        // Bind the buffer
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexTextureCoordBuffer);

        let data = [
            this.startX, startY, //0.0, //uv0
            this.endX, startY,   //0.0, //uv1
            this.endX, endY,     // 1.0, // / 4, //uv2
            this.startX, endY,   //1.0, // / 4  //uv3
        ];

        // Update the buffer values
        this.gl.bufferSubData(this.gl.ARRAY_BUFFER, 0, new Float32Array(data));

        // Un-bind the buffer
        this.gl.bindBuffer(this.gl.ARRAY_BUFFER, null);
    }

    // Method computes the size of the texture coordinate as Texels in range of 0..1
    private calculateTextrePercentage(pixels: number, divisor: number): number {
        return pixels / divisor;
    }

    public get width() {
        return this.m_image.width;
    }

    public get height() {
        return this.m_image.height;
    }

    public get Indices() {
        return this.indices;
    }

    public get GL() {
        return this.gl;
    }

    public get ShaderProgram() {
        return this.shaderProgram;
    }

    public get VertexPositionBuffer() {
        return this.vertexPositionBuffer;
    }

    public get VertexIndexBuffer() {
        return this.vertexIndexBuffer;
    }

    public get CubeVertexTextureCoordBuffer() {
        return this.cubeVertexTextureCoordBuffer;
    }

    public get AnimTexture() {
        return this.animTexture;
    }

    public get PMatrix() {
        return this.pMatrix;
    }

    public get MvMatrix() {
        return this.mvMatrix;
    }
}