#include "Headers/header.hlsl"

float   g_SkyHeight;
float   g_DayTime;
float3  g_SunDirect;
float4  g_SunColor;

struct VS_INPUT
{
    float3 pos        : POSITION;
    float3 normal     : NORMAL;
    float4 staruv     : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 position : POSITION;
	float3 normal   : TEXCOORD1;
	float4 texcoord : TEXCOORD0;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	output.position = mul(float4(input.pos+g_EyePos,1.0), g_WorldViewProj).xyww;
	output.normal = input.normal;
	output.texcoord.xy = float2(g_DayTime, 1.0 - input.pos.y/g_SkyHeight);
	output.texcoord.zw = input.staruv.xy;
	return output;
}


TEXTURE2D(g_SkyTex);    SAMPLER2D(s_SkySampler);
TEXTURE2D(g_AnotherTex);   SAMPLER2D(s_AnotherSampler);

float  g_fAmount;

float4 PSMain(VS_OUTPUT input): SV_Target
{
	float4 color1 = SAMPLE_TEXTURE2D(g_SkyTex, s_SkySampler, input.texcoord.xy);
	float4 color2 = SAMPLE_TEXTURE2D(g_AnotherTex, s_AnotherSampler, input.texcoord.xy);
	float4 color = lerp(color1, color2, g_fAmount);
	
	float t = (dot(g_SunDirect, input.normal) + 1.0) * 0.5;
	float4 diffuse;
	diffuse.rgb = /*t * t*/ float3(1.0, 0.0, 0.0);//  g_SunColor.rgb;
	diffuse.a = g_SunColor.a;
	
	return color * diffuse;
}
