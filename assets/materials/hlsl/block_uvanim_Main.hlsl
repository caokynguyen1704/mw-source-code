

#include "Headers/header.hlsl"

float3 g_ChunkOrigin;

float2 g_UVTranslate;

struct VS_INPUT
{
    float4 pos        : POSITION;
#ifdef LIGHT_SHADOW
    float3 normal        : NORMAL;
#endif
    float4 color         : COLOR0;
    float2 uv0            : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float4 color0        : COLOR0; //color0.xyz=ambient lighting,  color0.w=specular lighting
    float2 uv0            : TEXCOORD0;

#ifdef LIGHT_SHADOW
    float4 color1        : COLOR1; //color1.xyz=shadowed_lighting,  color1.w=specular lighting
    float4 uv1            : TEXCOORD1;
#endif

#if FOG_HEIGHT>0 || FOG_DISTANCE>0
	float2 fogc	: TEXCOORD2;
#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	float3 pos        = input.pos.xyz + g_ChunkOrigin;
	output.pos = mul(float4(pos,1.0), g_WorldViewProj);

	output.color0 = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0);

	output.uv0 = input.uv0 * float2(1.0/4096, 1.0/4096) + g_UVTranslate.xy;

#ifdef LIGHT_SHADOW
	float3 normal    = input.normal * float3(2/255.0, 2/255.0, 2/255.0) - float3(1.0, 1.0, 1.0);
	output.color1 = DoLighting(pos, normal, 1);
   
	float4 wpos2 = mul(float4(pos,1.0), g_World);
	output.uv1 = CalShadowProjUV(wpos2);
#endif


#if defined(FOG_DISTANCE) || defined(FOG_HEIGHT)
	output.fogc = DoFog(pos);
#endif

	return output;
}


TEXTURE2D(g_DiffuseTex);    SAMPLER2D(s_DiffuseSampler);

float4 PSMain(VS_OUTPUT input):SV_TARGET
{
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0)*input.color0;
#if defined(ALPHA_TEST)
	clip(color.a-0.5);
#endif

#if defined(FOG_DISTANCE)
	color.rgb = lerp(g_DistFogColor.rgb, color.rgb, input.fogc.x);
#endif
#if defined(FOG_HEIGHT)
	color.rgb = lerp(g_HeightFogColor.rgb, color.rgb, input.fogc.y);
#endif

	return color;
}
