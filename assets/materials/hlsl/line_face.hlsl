#include "Headers/header.hlsl"
float3 g_ChunkOrigin;

float4 g_SkyLightColor;
float4 g_TorchLightColor;

float g_fUV0Mul;

#ifdef HAND_LIGHT
float3 g_HandLightPos;  //in local space
#endif

struct VS_INPUT
{
    float4 pos        : POSITION;
#ifdef LIGHT_SHADOW
    float3 normal        : NORMAL;
#endif
    float4 color         : COLOR0; //rgb:  biome color,   a: normal effect
    float2 uv0            : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float4 color0        : COLOR0; //rgb:  biome color,   a: normal effect

#ifdef FOG_DISTANCE
    float4 color1        : COLOR1;
#endif


#ifdef LIGHT_SHADOW
    float3 uv0            : TEXCOORD0;
    float4 uv1            : TEXCOORD1;
#else
    float2 uv0            : TEXCOORD0;
#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	float4 pos        = input.pos + float4(g_ChunkOrigin, 0);
	output.pos = mul(float4(pos.xyz,1.0), g_WorldViewProj);
#ifdef LIGHT_SHADOW
	output.uv0 = float3(input.uv0, 1.0) * float3(1.0/4096, 1.0/4096, 1.0) * g_fUV0Mul;
#else
	output.uv0 = input.uv0 * float2(1.0/4096, 1.0/4096) * g_fUV0Mul;
#endif

	float4 color = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0);
	
	float lt_s = floor(pos.w/256.0) / 127.0;
	float lt_t = frac(pos.w/128.0);
	float3 lighting = max(lt_s*g_SkyLightColor.a*g_SkyLightColor.rgb, lt_t*g_TorchLightColor.rgb) + g_AmbientLight.rgb;
	color.rgb = lighting*color.rgb*color.a;
	
	// output.color0 = g_TorchLightColor.rgb;
	output.color0 = color;

#ifdef FOG_DISTANCE
	output.color1 = float4(g_DistFogColor.rgb, DoFogDist(pos.xyz));
#endif

#ifdef OPEN_G_DIR_LIGHT
	output.uv1 = CalShadowProjUV(float4(pos.xyz,1.0));
	float3 normal = input.normal * float3(2/255.0, 2/255.0, 2/255.0) - float3(1.0, 1.0, 1.0);
	float4 wnor=mul(float4(normal,1.0), g_World);
	wnor.xyz=normalize(wnor.xyz);
	output.uv0.z = max(0, dot(wnor.xyz,g_SunLightDir.xyz));
#endif
	return output;
}


#ifdef DIFFUSE_TEX
    TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);
#endif

#ifdef ALPHATEX_DI
    TEXTURE2D(g_AlphaTexDI);   SAMPLER2D(s_AlphaDISampler);
#endif

#ifdef EMISSIVE
	float       g_fUVMul;
	float       g_ftime;
	TEXTURE2D(g_EmissiveTex);    SAMPLER2D(s_EmissiveSampler);
	float3      g_vSaturation;
	float3      g_vColorScale;
#endif

#ifdef LIGHT_SHADOW
	TEXTURE2D(g_depthtexture);    SAMPLER2D(s_DepthMapSampler);
#endif


/*
#if OVERLAY > 0
sampler2D s_OverlaySampler;
#endif
*/


float4 PSMain(VS_OUTPUT input):SV_Target
{
#ifdef DIFFUSE_TEX
	float4 color =  SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0.xy);
#else
	float4 color = float4(1.0f, 1.0f, 1.0f, 1.0f);
#endif

#ifdef ALPHATEX_DI
	color.a = SAMPLE_TEXTURE2D(g_AlphaTexDI,s_AlphaDISampler,input.uv0.xy).r;
#endif
	//float4 tcolor = color;
#ifdef ALPHA_TEST
	clip(color.a-0.5);
#endif
#ifdef LIGHT_SHADOW
	float shadow = DoHardShadow(TEXTURE2D_PARAM(g_depthtexture,s_DepthMapSampler),input.uv1, input.uv1.z/input.uv1.w); 
	color.rgb = color.rgb * input.color0.rgb *  min(shadow*input.uv0.z+0.8, 1.05);
#else
	color.rgb = color.rgb * input.color0.rgb;
#endif
// return float4(shadow,shadow,shadow,1);
#if defined(EMISSIVE)
	float4 tcolor =   SAMPLE_TEXTURE2D(g_EmissiveTex,s_EmissiveSampler, input.uv0.xy * g_fUVMul) * g_ftime;  
  	color.rgb += tcolor.rgb;
#endif

#if defined(FOG_DISTANCE)
	color.rgb = input.color1.rgb + (color.rgb - input.color1.rgb) * input.color1.a;
#endif


// #ifdef ALPHA_FOR_BLOOM
// 	#if defined(EMISSIVE)
// 		color.a	= GetLuminance(tcolor.rgb)*tcolor.a;
// 	#else
// 		color.a=0;
// 	#endif
// #endif

	return color;
}

