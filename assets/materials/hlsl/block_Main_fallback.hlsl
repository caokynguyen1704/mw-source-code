#include "Headers/header.hlsl"
float3 g_ChunkOrigin;
struct VS_INPUT {
    float4 pos : POSITION;
};

struct VS_OUTPUT {
    float4 pos : POSITION;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
   VS_OUTPUT output;
	float4 pos        = input.pos + float4(g_ChunkOrigin, 0);
	output.pos = mul(float4(pos.xyz,1.0), g_WorldViewProj);
    return output;
}

float4 PSMain(VS_OUTPUT input):SV_Target
{
     return float4(1,0,1,1);
}