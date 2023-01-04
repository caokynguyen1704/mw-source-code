#include "Headers/header.hlsl"


struct VS_OUTPUT
{
    float4 pos      : POSITION;
    float4 color0   : COLOR0;
    float2 uv0      : TEXCOORD0;
#if MASK_TEXTURE_1
    float2 uv1		: TEXCOORD1;
#endif
};


VS_OUTPUT VSMain( float4 pos : POSITION,
                   float4 color0 : COLOR0,
                   float2 uv0 : TEXCOORD0,
                   float2 uv1 : TEXCOORD1
                          )
{
	VS_OUTPUT output;
    
	output.pos = mul(pos, g_WorldViewProj);
    
	output.color0 = color0;

    
	output.uv0 = uv0;
#if MASK_TEXTURE_1
	output.uv1 = uv1;
#endif
	return output;
}

float       g_fBlendMode;
TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);


float4 PSMain(VS_OUTPUT input):SV_Target
{
	return (tex2D(s_DiffuseSampler,input.uv0)-128.0f/255.0f)*input.color0.a + 128.0f/255.0f;
}