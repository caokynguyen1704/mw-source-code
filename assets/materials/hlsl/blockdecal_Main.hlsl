

#include "Headers/header.hlsl"

float3 g_ChunkOrigin;

struct VS_INPUT
{
    float4 pos        : POSITION;
    float4 color      : COLOR0;
    float2 uv0        : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float4 color          : COLOR0;
    float2 uv0            : TEXCOORD0;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	float3 pos        = input.pos.xyz + g_ChunkOrigin;

	output.pos = mul(float4(pos,1.0), g_WorldViewProj);
	output.color = input.color;
	output.uv0 = input.uv0 * float2(1.0/4096, 1.0/4096);

	return output;
}

TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT input):SV_Target
{
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
#if defined(BLEND_VERTCOLOR)
	color.rgb = lerp(color.rgb, input.color.rgb, input.color.a);
#endif

	return color;
}
