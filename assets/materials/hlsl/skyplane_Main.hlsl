#include "Headers/header.hlsl"
#include "Headers/sky.hlsl"


float   g_SkyHeight;
float   g_DayTime;
float3  g_SunDirect;
float4  g_SunColor;
float   g_fSpeed;

struct VS_INPUT
{
    float3 position      : POSITION;
    float3 normal        : NORMAL;
    float2 staruv        : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 position : POSITION;
	float4 diffuse : COLOR0;
	float2 uv0 : TEXCOORD0;
	float4 uv1 : TEXCOORD1;
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	float t0 = g_fSpeed * 0.01;
	float3 position = rotateZ(input.position, t0);
	output.position = mul(float4(position + g_EyePos, 1.0), g_WorldViewProj);

	output.position = output.position.xyww;
	float t = (dot(g_SunDirect, input.normal) + 1.0) * 0.5;
	output.diffuse.rgb = t * t * g_SunColor.rgb;
	output.diffuse.a = g_SunColor.a;
	output.uv0 = float2(g_DayTime, 1.0 - input.position.y / g_SkyHeight);
	output.uv1.xy = input.staruv;
	output.uv1.zw = input.staruv * 1.2;
	return output;
}


TEXTURE2D(g_SkyTex);    SAMPLER2D(s_SkySampler);
TEXTURE2D(g_StarTex);   SAMPLER2D(s_StarSampler);

#if BLEND_TEXTURE2
TEXTURE2D(g_AnotherTex); SAMPLER2D(s_AnotherSampler);
#endif

float4  g_SkyModColor;

float4 PSMain(VS_OUTPUT input):SV_Target
{
	float4 color1 = SAMPLE_TEXTURE2D(g_SkyTex, s_SkySampler, input.uv0);
	float4 color2 = SAMPLE_TEXTURE2D(g_StarTex, s_StarSampler, input.uv1.xy);
	
#if BLEND_TEXTURE2
	float2 texcoord = frac(input.uv1.zw);
	color2 += SAMPLE_TEXTURE2D(g_AnotherTex, s_AnotherSampler, texcoord);
#endif
	color2 *= g_SkyModColor.a;
	float3 color = color1.rgb + input.diffuse.rgb + input.diffuse.a * color2.rgb;
	
	color *= g_SkyModColor.rgb;
	return float4(color, 1.0);
}
