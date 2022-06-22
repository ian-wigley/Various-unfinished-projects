package com.water.gdx;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.glutils.ShapeRenderer;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.math.Vector3;


public class PrimitiveBatch {

    // this constant controls how large the vertices buffer is. Larger buffers will
    // require flushing less often, which can increase performance. However, having
    // buffer that is unnecessarily large will waste memory.
    int DefaultBufferSize = 500;

    // a block of vertices that calling AddVertex will fill. Flush will draw using
    // this array, and will determine how many primitives to draw from
    // positionInBuffer.
    //VertexPositionColor[] vertices = new VertexPositionColor[DefaultBufferSize];
    Vector2[] vertices = new Vector2[DefaultBufferSize];

    // keeps track of how many vertices have been added. this value increases until
    // we run out of space in the buffer, at which time Flush is automatically
    // called.
    int positionInBuffer = 0;

    // a basic effect, which contains the shaders that we will use to draw our
    // primitives.
    //BasicEffect basicEffect;

    // the device that we will issue draw calls to.
    //GraphicsDevice device;

    // this value is set by Begin, and is the type of primitives that we are
    // drawing.
    //PrimitiveType primitiveType;
    ShapeRenderer.ShapeType primitiveType;

    // how many verts does each of these primitives take up? points are 1,
    // lines are 2, and triangles are 3.
    int numVertsPerPrimitive = 2;

    // hasBegun is flipped to true once Begin is called, and is used to make
    // sure users don't call End before Begin is called.
    boolean hasBegun = false;

    boolean isDisposed = false;
    ShapeRenderer sr = new ShapeRenderer();

    // the constructor creates a new PrimitiveBatch and sets up all of the internals
    // that PrimitiveBatch will need.
    public PrimitiveBatch()//GraphicsDevice graphicsDevice)
    {
        int i = 0;
//        if (graphicsDevice == null)
//        {
//            throw new ArgumentNullException("graphicsDevice");
//        }
//        device = graphicsDevice;
//
//        // set up a new basic effect, and enable vertex colors.
//        basicEffect = new BasicEffect(graphicsDevice);
//        basicEffect.VertexColorEnabled = true;
//
//        // projection uses CreateOrthographicOffCenter to create 2d projection
//        // matrix with 0,0 in the upper left.
//        basicEffect.Projection = Matrix.CreateOrthographicOffCenter
//                (0, graphicsDevice.Viewport.Width,
//                        graphicsDevice.Viewport.Height, 0,
//                        0, 1);
    }

    public void Dispose()
    {
        this.Dispose(true);
        //GC.SuppressFinalize(this);
    }

    protected void Dispose(boolean disposing)
    {
        if (disposing && !isDisposed)
        {
            //if (basicEffect != null)
                //basicEffect.Dispose();

            isDisposed = true;
        }
    }

    // Begin is called to tell the PrimitiveBatch what kind of primitives will be
    // drawn, and to prepare the graphics card to render those primitives.
    public void Begin(ShapeRenderer.ShapeType primitiveType)
    {
//        if (hasBegun)
//        {
////            throw new InvalidOperationException
////                    ("End must be called before Begin can be called again.");
//        }
//
//        // these three types reuse vertices, so we can't flush properly without more
//        // complex logic. Since that's a bit too complicated for this sample, we'll
//        // simply disallow them.
////        if (primitiveType == PrimitiveType.LineStrip ||
////                primitiveType == PrimitiveType.TriangleStrip)
////        {
////            throw new NotSupportedException
////                    ("The specified primitiveType is not supported by PrimitiveBatch.");
////        }
////
        this.primitiveType = primitiveType;

////        // how many verts will each of these primitives require?
////        this.numVertsPerPrimitive = NumVertsPerPrimitive(primitiveType);
////
////        //tell our basic effect to begin.
////        basicEffect.CurrentTechnique.Passes[0].Apply();
//
//        // flip the error checking boolean. It's now ok to call AddVertex, Flush,
//        // and End.
        hasBegun = true;
    }

    // AddVertex is called to add another vertex to be rendered. To draw a point,
    // AddVertex must be called once. for lines, twice, and for triangles 3 times.
    // this function can only be called once begin has been called.
    // if there is not enough room in the vertices buffer, Flush is called
    // automatically.
    public void AddVertex(Vector2 vertex, Color color)
    {
        int i = 0;
////        if (!hasBegun)
////        {
////            throw new InvalidOperationException
////                    ("Begin must be called before AddVertex can be called.");
////        }
//
        // are we starting a new primitive? if so, and there will not be enough room
        // for a whole primitive, flush.
        boolean newPrimitive = ((positionInBuffer % numVertsPerPrimitive) == 0);

        if (newPrimitive &&
                (positionInBuffer + numVertsPerPrimitive) >= vertices.length)
        {
            Flush();
        }

        // once we know there's enough room, set the vertex in the buffer,
        // and increase position.
////        vertices[positionInBuffer].Position = new Vector3(vertex, 0);
////        vertices[positionInBuffer].Color = color;
        vertices[positionInBuffer] = vertex; //new Vector3(vertex, 0);
        positionInBuffer++;
    }

    // End is called once all the primitives have been drawn using AddVertex.
    // it will call Flush to actually submit the draw call to the graphics card, and
    // then tell the basic effect to end.
    public void End()
    {
//        if (!hasBegun)
//        {
//            throw new InvalidOperationException
//                    ("Begin must be called before End can be called.");
//        }

        // Draw whatever the user wanted us to draw
        Flush();

        hasBegun = false;
    }

    // Flush is called to issue the draw call to the graphics card. Once the draw
    // call is made, positionInBuffer is reset, so that AddVertex can start over
    // at the beginning. End will call this to draw the primitives that the user
    // requested, and AddVertex will call this if there is not enough room in the
    // buffer.
    private void Flush()
    {
//        if (!hasBegun)
//        {
//            throw new InvalidOperationException
//                    ("Begin must be called before Flush can be called.");
//        }

        // no work to do
        if (positionInBuffer == 0)
        {
            return;
        }

        // how many primitives will we draw?
        int primitiveCount = positionInBuffer / numVertsPerPrimitive;

        // submit the draw call to the graphics card
//        device.DrawUserPrimitives<VertexPositionColor>(primitiveType, vertices, 0,
//            primitiveCount);

        //Gdx.gl.glClearColor(0, 0, 0, 0);
        //Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

        //sr.setColor(Color.BLUE);

        sr.setColor(new Color(0, 0.5f, 1.5f, 0.5f));
        sr.begin(this.primitiveType);
        if(this.primitiveType.equals(ShapeRenderer.ShapeType.Filled)) {
            for (int i = 0; i < (vertices.length) - 2; i += 2) { //Vector3 verts : vertices){
                //sr.rectLine(vertices[i], vertices[i+1],2.0f);
                //	public void triangle (float x1, float y1, float x2, float y2, float x3, float y3) {
                sr.triangle(vertices[i].x, vertices[i].y, vertices[i + 1].x, vertices[i+1].y,0,0);
            }
        }
        else if (this.primitiveType.equals(ShapeRenderer.ShapeType.Line)) {
        //sr.rectLine(100.0f, 100.0f, 200.0f, 200.0f,1.0f, Color.WHITE, Color.WHITE);
            for (int i = 0; i < (vertices.length) - 2; i += 2) { //Vector3 verts : vertices){
                //sr.rectLine(vertices[i], vertices[i+1],2.0f);
                sr.line(vertices[i], vertices[i + 1]);
            }
        }
        sr.end();


        // now that we've drawn, it's ok to reset positionInBuffer back to zero,
        // and write over any vertices that may have been set previously.
        positionInBuffer = 0;
    }


    // NumVertsPerPrimitive is a boring helper function that tells how many vertices
    // it will take to draw each kind of primitive.
//    static private int NumVertsPerPrimitive(PrimitiveType primitive)
//    {
//        int numVertsPerPrimitive;
//        switch (primitive)
//        {
//            case PrimitiveType.LineList:
//                numVertsPerPrimitive = 2;
//                break;
//            case PrimitiveType.TriangleList:
//                numVertsPerPrimitive = 3;
//                break;
//            default:
//                throw new InvalidOperationException("primitive is not valid");
//        }
//        return numVertsPerPrimitive;
//    }


}
