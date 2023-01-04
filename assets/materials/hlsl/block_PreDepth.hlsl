#include "Headers/header.hlsl"
float3 g_ChunkOrigin;
////还没用上
struct VS_INPUT
{
    float4 pos        : POSITION;
    float2 uv0            : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float2 uv0            : TEXCOORD0;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	float3 pos = input.pos.xyz + g_ChunkOrigin;
	output.uv0 = input.uv0 * float2(1.0/4096, 1.0/4096);
    output.pos = mul(float4(pos,1.0), g_WorldViewProj);
#endif

	return output;
}

TEXTURE2D(g_DiffuseTex);    SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT input) : SV_Target
{
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
	clip(color.a-0.8);
	return float4(0, 0, 0, 0);
}

