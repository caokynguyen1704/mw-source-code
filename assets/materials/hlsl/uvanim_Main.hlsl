
#include "Headers/header.hlsl"
float g_ModelTransparent ;  //: MODEL_XPARENT

float g_TransU = 0.0f;
float g_TransV = 0.0f;
float g_ScaleU = 1.0f;
float g_ScaleV = 1.0f;
float g_RotUV = 0.0f;

struct VS_INPUT
{
    float4 pos        : POSITION;
    float3 normal        : NORMAL;
    float4 color        :COLOR0;
    
#if SKIN_MAXINFL > 0
    float4 blendweights : BLENDWEIGHT;
    float4 blendindices : BLENDINDICES;
#endif

    float2 uv0            : TEXCOORD0;
    float2 uv1            : TEXCOORD1;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
#ifdef RECEIVE_LIGHTING
	float4 color0     : COLOR0;
#endif
    float2 uv0            : TEXCOORD0;
    float2 uv1            : TEXCOORD1;

#ifdef RECEIVE_LIGHTING
#ifdef LIGHT_SHADOW
    float4 color1        : COLOR1; //color1.xyz=shadowed_lighting,  color1.w=specular lighting
    float4 uv2            : TEXCOORD2;
#endif
#endif

#if RECEIVE_FOG==1
#if FOG_HEIGHT>0 || FOG_DISTANCE>0
	float2 fogc	: TEXCOORD3;
#endif
#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
	float3 pos;
	float3 normal;

#if SKIN_MAXINFL > 0
	DoSkinVertex(input.blendindices, input.blendweights, input.pos, input.normal, pos, normal);
#else
	pos		= input.pos;
	normal	= input.normal;
	normal	= normalize(normal);
#endif

	output.pos = mul(float4(pos,1.0), g_WorldViewProj);

	float angle = radians(g_RotUV);
	float2 uv = (input.uv0 - float2(0.5,0.5))*float2(g_ScaleU, g_ScaleV);
	float u = uv.x*cos(angle) + uv.y*sin(angle);
	float v = -uv.x*sin(angle) + uv.y*cos(angle);

	output.uv0 = float2(u,v) + float2(0.5,0.5) + float2(g_TransU, g_TransV);
	output.uv1 = input.uv1;

#ifdef RECEIVE_LIGHTING
	output.color0 = DoLighting(input.pos, input.normal, 0);
#ifdef LIGHT_SHADOW
    output.color1 = DoLighting(input.pos, input.normal, 1);
    float4 wpos2 = mul(input.pos, g_World);
    output.uv2 = CalShadowProjUV(wpos2);
#endif
#endif


#if defined(FOG_HEIGHT) || defined(FOG_DISTANCE)
	float3 wpos = mul(input.pos, g_World);
	output.fogc = DoFog(wpos);
#endif
	return output;
}


TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);
#ifdef LIGHT_SHADOW
    TEXTURE2D(g_depthtexture);   SAMPLER2D(s_DepthMapSampler);
#endif

#if USE_MASK_TEX==1
      TEXTURE2D(g_MaskTex);   SAMPLER2D(s_MaskSampler);
#endif


float4 PSMain(VS_OUTPUT input):COLOR0
{
	float4 color0  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
#if USE_MASK_TEX==1
	float4 color1 = SAMPLE_TEXTURE2D(g_MaskTex,s_MaskSampler, input.uv1);
#else
	float4 color1 = float4(1.0, 1.0, 1.0, 1.0);
#endif

#ifdef RECEIVE_LIGHTING
     float4 lighting = input.color0;
#ifdef LIGHT_SHADOW
	float shadow = DoHardShadow(TEXTURE2D_PARAM(g_depthtexture,s_DepthMapSampler), input.uv2, input.uv2.z/input.uv2.w); 
	shadow = 1.0f - (1.0f - shadow)*g_shadowdensity;
	lighting += shadow*input.color1;
#endif

	float4 color = float4(lighting.rgb,1.0)*color0*color1;
#else
	float4 color = color0*color1;
#endif

#ifdef MODEL_TRANSPARENT
	color *= g_ModelTransparent;
#endif

// #if RECEIVE_FOG==1

// #if BLEND_MODE < 3

//     #if FOG_DISTANCE>0
//         color.rgb = lerp(g_DistFogColor, color.rgb, input.fogc.x);
//     #endif
//     #if FOG_HEIGHT > 0
//         color.rgb = lerp(g_HeightFogColor, color.rgb, input.fogc.y);
//     #endif

// #else //blend_mode>=3

// #if FOG_DISTANCE>0
// 	color *= input.fogc.x;
// #endif
// #if FOG_HEIGHT > 0
// 	color *= input.fogc.y;
// #endif

// #endif

// #endif

	return color;
}