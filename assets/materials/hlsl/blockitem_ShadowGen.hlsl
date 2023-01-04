
#include "Headers/header.hlsl"


struct VS_INPUT
{
    float4 pos        : POSITION;
#ifdef USE_CUSTOM_MODEL
	float4 color      : COLOR0;
#else
	float2 uv0        : TEXCOORD0;
#endif
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
#ifdef USE_CUSTOM_MODEL
	 float4 color      : COLOR0;
#else
	 float2 uv0            : TEXCOORD0;
#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	float3 pos        = input.pos.xyz;
#ifdef USE_CUSTOM_MODEL
	float4 color = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/16.0);
	color = float4(color.rgb, floor(color.a)/15.0);
	output.color = color;
#else
	output.uv0 = input.uv0 * float2(1.0/4096, 1.0/4096);
#endif
	
#ifdef LOG_SHADOWMAP
    float4 wpos = mul(float4(pos,1.0), g_WorldViewProj);
    float2 diff = wpos.xy - g_ShadowCenter.xy;
    float t = length(diff);
    float nt = g_ShadowCenter.w * log(g_ShadowCenter.z*t + 1)/t;

    output.pos.xy = g_ShadowCenter.xy + diff*nt;
    output.pos.zw = wpos.zw;
#else
    output.pos = mul(float4(pos,1.0), g_WorldViewProj);
#endif

	return output;
}


#ifndef USE_CUSTOM_MODEL
    Texture2D g_DiffuseTex;    SamplerState s_DiffuseSampler;
#endif

float4 PSMain(VS_OUTPUT input) : SV_Target
{
#ifdef USE_CUSTOM_MODEL 
	return float4(0, 0, 0, input.color.a);
#else
	#ifdef ALPHA_TEST
		float4 color  =  SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
		clip(color.a-0.8);
		return float4(0, 0, 0, color.a);
	#else
		return float4(0, 0, 0, 1);
	#endif
#endif
}