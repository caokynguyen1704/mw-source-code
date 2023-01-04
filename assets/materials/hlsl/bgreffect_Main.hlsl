#include "Headers/header.hlsl"


TEXTURE2D(g_SceneTexture);    SAMPLER2D(s_DiffuseSampler);


struct VS_INPUT
{
	float4 pos			: POSITION;
	float2 uv0			: TEXCOORD0;
};

//--------------------------------------------------------------------------------------
// Vertex shader output structure
//--------------------------------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Position   : POSITION;   // vertex position 
    float2 TextureUV  : TEXCOORD0;  // vertex texture coords 
};

VS_OUTPUT VSMain(VS_INPUT input)
{
    VS_OUTPUT output;
    
    output.Position = mul(input.pos, g_WorldViewProj);
    output.TextureUV = input.uv0;
    return output;
}

float4 PSMain(VS_OUTPUT input):SV_TARGET
{
	float4 vScene  = SAMPLE_TEXTURE2D(g_SceneTexture,s_DiffuseSampler,input.TextureUV);
	float b = vScene.b;
	vScene.b = vScene.r;
	vScene.r = b;	
	vScene.a = 255;
	return vScene;
}
