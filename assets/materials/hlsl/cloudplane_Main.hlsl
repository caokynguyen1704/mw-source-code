

#include "Headers/header.hlsl"

struct VS_INPUT
{
    float3 pos        : POSITION;
    float2 uv        : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 position : POSITION;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	output.position = mul(float4(input.pos+g_EyePos,1.0), g_WorldViewProj);
	output.position=output.position.xyww;
	output.uv0 = input.uv;
	output.uv1 = input.uv;
	
	return output;
}

TEXTURE2D(g_CloudTex);      SAMPLER2D(s_CloudSampler);

TEXTURE2D(g_CloudLightTex);     SAMPLER2D(s_CloudLightSampler);

float4 g_SkyModColor;


float4 PSMain(VS_OUTPUT input):SV_Target
{
	float4 color0 = SAMPLE_TEXTURE2D(g_CloudTex,s_CloudSampler,input.uv0);
	float4 color1 = SAMPLE_TEXTURE2D(g_CloudLightTex,s_CloudLightSampler,input.uv1);
	return float4(color1.rgb + 0.5 * g_SkyModColor.rgb, color0.a);
}
