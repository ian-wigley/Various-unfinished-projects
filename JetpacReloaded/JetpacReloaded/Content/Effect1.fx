#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

Texture2D SpriteTexture;
sampler s0;

texture lightMask;
sampler lightSampler = sampler_state{Texture = <lightMask>;};

float param1;

sampler2D SpriteTextureSampler = sampler_state
{
	Texture = <SpriteTexture>;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float4 Color : COLOR0;
	float2 TextureCoordinates : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{
	//return tex2D(SpriteTextureSampler,input.TextureCoordinates) * input.Color;
	float4 color = tex2D(s0, input.TextureCoordinates);
	color.gb = color.r;
    return color;
}


float4 PixelShaderFunction(float2 coords: TEXCOORD0) : COLOR0
{
//	float4 color = tex2D(s0, coords);
//	if (coords.y > param1)
//		color = float4(0,0,0,0);
//	return color;

    float4 color = tex2D(s0, coords);
    float4 lightColor = tex2D(lightSampler, coords);
    return color * lightColor;
}


technique SpriteDrawing
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL PixelShaderFunction();
	}
};