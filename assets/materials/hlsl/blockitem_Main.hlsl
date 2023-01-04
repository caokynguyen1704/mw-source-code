#include "Headers/header.hlsl"

#ifdef USE_CUSTOM_MODEL
    float4 g_SkyLightColor;
    #endif
    float3 LightDir; //transform into model coordinate
    float3 GrassColor;

#ifdef USE_TEXTURE_2
    float2 g_UVTranslate;
#endif

float4 g_TorchLightColor;
float4 g_InstanceData;


struct VS_INPUT
{
    float4 pos        : POSITION;
    float4 color      : COLOR0;

#ifndef USE_CUSTOM_MODEL
    float2 uv0        : TEXCOORD0;
#endif

#ifdef SYS_SKIN_MAXINFL_ENABLE
	float  blendindices : BLENDINDICES;
#endif
};

struct VS_OUTPUT
{
    float4 pos        : POSITION;
    float4 color      : COLOR0;

#ifndef USE_CUSTOM_MODEL
    float2 uv0        : TEXCOORD0;
#endif

};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    	
	
#ifdef SYS_SKIN_MAXINFL_ENABLE
	float4 pos = float4(input.pos.xyz,1.0);
	int indices = input.blendindices * 3;
	pos = float4(dot(pos,g_BoneTM[indices]),dot(pos,g_BoneTM[indices+1]),dot(pos,g_BoneTM[indices+2]), input.pos.w);
	//DoItemVertex(input.blendindices, input.pos, pos);
#else
	float4 pos = input.pos;
#endif
	output.pos = mul(float4(pos.xyz,1.0), g_WorldViewProj);
#ifdef USE_CUSTOM_MODEL
	float4 color = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/16.0);
	float emissive = 1.0 - frac(color.a)*16.0/15.0;
	color = float4(color.rgb, floor(color.a)/15.0);
	float t = g_InstanceData.x*g_SkyLightColor.a;
	float3 ambient = max(t*g_SkyLightColor.rgb, g_InstanceData.y*g_TorchLightColor.rgb);
	float3 lighting = ambient + g_AmbientLight.rgb*(1.0-t) + float3(0.2, 0.2, 0.2);
	output.color = float4(lighting*color.rgb*pos.w/255.0 + color.rgb*emissive, color.a);
#else
	float2 uv0 = input.uv0 * float2(1.0/4096, 1.0/4096);
	float lt_s = floor(pos.w/256.0) / 127.0;
	float4 color = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0) * lt_s;
	output.color = float4(GrassColor.rgb*color.rgb*color.a, 1.0);
	#ifdef USE_TEXTURE_2
		output.uv0 = uv0.xy + g_UVTranslate;
	#else
		output.uv0 = uv0.xy;
	#endif
#endif
	return output;
}




#if defined(USE_TEXTURE_1) || defined(USE_TEXTURE_2)

	#ifndef USE_CUSTOM_MODEL
		TEXTURE2D(g_DiffuseTex); SAMPLER2D(s_DiffuseSampler);
	#endif

	#if defined(OVERLAY_MODE_COLOR)
		float3 g_OverlayColor;
	#endif

#endif

#ifdef EMISSIVE
    float       g_fUVMul;
    float       g_ftime;
    TEXTURE2D(g_EmissiveTex);    SAMPLER2D(s_EmissiveSampler);
#endif

float4 PSMain(VS_OUTPUT input):SV_Target
{
#ifdef USE_TEXTURE_1
	#ifdef USE_CUSTOM_MODEL
		float4 color = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#else
		float4 color = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0.xy);
	#endif
	#ifdef ALPHA_TEST
		clip(color.a-0.5);
	#endif
		color = color * input.color;
	#if defined(OVERLAY_MODE_COLOR)
		color.rgb += g_OverlayColor.rgb;
	#endif
	#if defined(EMISSIVE) && !defined(USE_CUSTOM_MODEL)
		float4 tcolor = SAMPLE_TEXTURE2D(g_EmissiveTex,s_EmissiveSampler, input.uv0.xy * g_fUVMul) * g_ftime;
		color.rgb += tcolor.rgb;
	#endif
		return color;

#elif defined(USE_TEXTURE_2)
	#if !defined(USE_CUSTOM_MODEL) && defined(OVERLAY_MODE_COLOR)
		float4 color =  SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0.xy);
		color.rgb = color.rgb*g_OverlayColor + input.color.rgb;
		#ifdef EMISSIVE
			float4 tcolor = SAMPLE_TEXTURE2D(s_EmissiveSampler, input.uv0.xy * g_fUVMul) * g_ftime;
			color.rgb += tcolor.rgb;
		#endif
			return color;
	#else
		return input.color;
	#endif

#else
	return input.color;
#endif
}
