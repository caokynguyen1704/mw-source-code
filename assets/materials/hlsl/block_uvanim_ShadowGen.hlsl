

#include "Headers/header.hlsl"


float3 g_ChunkOrigin;

float2 g_UVTranslate;

struct VS_INPUT
{
    float4 pos        : POSITION;
    float4 color         : COLOR0;
    float2 uv0            : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float4 color0        : COLOR0; //color0.xyz=ambient lighting,  color0.w=specular lighting
    float2 uv0            : TEXCOORD0;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	float3 pos        = input.pos.xyz + g_ChunkOrigin;
	output.pos = mul(float4(pos,1.0), g_WorldViewProj);

	output.color0 = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0);

output.uv0 = input.uv0*float2(1.0/4096, 1.0/4096) + g_UVTranslate.xy;

	return output;
}



TEXTURE2D(g_DiffuseTex);    SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT input):SV_Target
{

#if ALPHA_TEST 
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0)*input.color0;
	clip(color.a-0.5);
	return float4(0, 0, 0, color.a);
#else
	return float4(0,0,0,0.8);
#endif
}
