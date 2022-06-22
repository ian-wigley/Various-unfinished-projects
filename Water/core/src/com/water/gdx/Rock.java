package com.water.gdx;

import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.Vector2;

public class Rock {

    public Vector2 Position, Velocity;
    static final Vector2 Gravity = new Vector2(0, 0.3f);

    public Rock(Vector2 Position, Vector2 Velocity)
    {
        this.Position = Position;
        this.Velocity = Velocity;
    }

    public void Update(Water water) {
        if (Position.y > water.GetHeight(Position.x)) {
            Velocity.x *= 0.84f;
            Velocity.y *= 0.84f;
        }
        Position.x += Velocity.x;
        Position.y += Velocity.y;
        Velocity.x += Gravity.x;
        Velocity.y += Gravity.y;
    }

    public void Draw(SpriteBatch spriteBatch, Texture texture) {
        Vector2 origin = new Vector2(texture.getWidth()/2, texture.getHeight()/2);// / 2f;
        //spriteBatch.draw(texture, Position.x, Position.y);//, null, Color.WHITE, 0f, origin, 1f, 0, 0);
        spriteBatch.draw(texture, Position.x, Position.y, texture.getWidth(), texture.getHeight(), 0, 0, texture.getWidth(),
                texture.getHeight(), false, true);
    }

}
