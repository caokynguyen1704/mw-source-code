#include "Headers/header.hlsl"

float4x4 g_Proj;
float4 g_SunColor;

struct VS_INPUT
{
    float3 pos        : POSITION;
    float2 uv        : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 pos : POSITION;
	float2 uv  : TEXCOORD0;	
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	output.pos = mul(float4(input.pos,1.0), g_Proj);
	output.pos = output.pos.xyzz;
	output.uv = input.uv;
	
	return output;
}

TEXTURE2D(g_SunTex);    SAMPLER2D(s_SunSampler);
#if BLEND_TEXTURE2
TEXTURE2D(g_AnotherTex); SAMPLER2D(s_AnotherSampler);
float  g_fAmount;
#endif

float4 PSMain(VS_OUTPUT input):SV_Target
{
	float4 color= SAMPLE_TEXTURE2D(g_SunTex, s_SunSampler, input.uv);
	
#if BLEND_TEXTURE2
	float4 anotherColor = SAMPLE_TEXTURE2D(g_AnotherTex, s_AnotherSampler, input.uv);
	color.rgb = lerp(color.rgb, anotherColor.rgb, g_fAmount);
#else
	color.rgb *= g_SunColor.rgb;
#endif

	return color;
}
