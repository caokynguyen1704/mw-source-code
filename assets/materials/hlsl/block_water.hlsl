

#include "Headers/header.hlsl"

float3 g_ChunkOrigin;
float4 g_SkyLightColor;
float4 g_TorchLightColor;

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
    float4 pos          : POSITION;
    float4 color        : COLOR0;
    float2 uv0          : TEXCOORD0;
    float2 bumpuv       : TEXCOORD1;
    float4 reflectxy_refractyx : TEXCOORD2;
    float4 eyevec : TEXCOORD3;
    
#if FOG_HEIGHT>0 || FOG_DISTANCE>0
	float2 fogc	: TEXCOORD4;
#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	float3 pos        = input.pos.xyz + g_ChunkOrigin;
	float4 projpos = mul(float4(pos,1.0), g_WorldViewProj);
	output.pos = projpos;

	float4 color = input.color * float4(1.0/255.0, 1.0/255.0, 1.0/255.0, 1.0/255.0);

	float lt_s = floor(input.pos.w/256.0) / 128.0;
	float lt_t = frac(input.pos.w/128.0);

	float3 lighting = max(lt_s*g_SkyLightColor.a*g_SkyLightColor.rgb, lt_t*g_TorchLightColor.rgb) + g_AmbientLight.rgb; //ȫ�ֹ���
	color.rgb = lighting*color.rgb*color.a;
	color.a = lt_s;

	output.color = color;

	output.uv0 = input.uv0 * float2(1.0/8192, 1.0/8192);
	output.bumpuv = input.pos.xz / 9216.0;

#if ENG_UV_STARTS_AT_TOP==1
	float scale = -1.0;
#else
	float scale = 1.0f;
#endif
	float2 reflect_pos = (float2(-projpos.x, scale*projpos.y) + projpos.w) * 0.5;

	float2 refract_pos = (float2(projpos.x, -projpos.y) + projpos.w) * 0.5;
	output.reflectxy_refractyx = float4( reflect_pos.x, reflect_pos.y, refract_pos.y, refract_pos.x);
	
	float3 eyevec = normalize(g_EyePosModel.xyz - pos.xyz);
	output.eyevec = float4(eyevec, projpos.w);

#if FOG_HEIGHT>0 || FOG_DISTANCE>0
	output.fogc = DoFog(pos.xyz);
#endif

	return output;
}



float		g_NumTexRepeat;
float		g_fSpeed;
float		g_fAmp;

TEXTURE2D(g_DiffuseTex);    SAMPLER2D(s_DiffuseSampler);

TEXTURE2D(g_NormalTex);     SAMPLER2D(NormalSampler);

TEXTURE2D(g_ReflectTex);    SAMPLER2D(ReflectSampler);



float4 PSMain(VS_OUTPUT input) : SV_TARGET
{
	float uvmove = g_fSpeed * g_fTime * 0.30f;


	float4 nor1 = SAMPLE_TEXTURE2D(g_NormalTex,NormalSampler,g_NumTexRepeat*input.bumpuv*0.8f + float2(uvmove,0.1f) );
	float4 nor2 = SAMPLE_TEXTURE2D(g_NormalTex,NormalSampler,g_NumTexRepeat*input.bumpuv*0.8f + float2(-uvmove,0.1f) );

	//float3 nor3 = tex2D( NormalSampler,g_NumTexRepeat*input.bumpuv + float2(0.3f,g_fSpeed*g_fTime) );
	//float3 nor4 = tex2D( NormalSampler,g_NumTexRepeat*input.bumpuv + float2(0.7f,-g_fSpeed*g_fTime) );
	//float3 normal = 0.25*(nor1+nor2+nor3+nor4);
	//nor1 = nor1*2.0 - 1.0;
	//nor2 = nor2*2.0 - 1.0;
	float3 normal = nor2.rgb * 2.0f - nor1.rgb * 2.0f;
	//normal *= 0.5f;
	//normal = normal*2.0 - 1.0;

	float4 watercolor = input.color * SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler, input.uv0);

	float ooW = 1.0f / input.eyevec.w;
	float4 uv = normal.xyxy*g_fAmp*0.01f + input.reflectxy_refractyx*ooW;

	float4 reflect_color = SAMPLE_TEXTURE2D(g_ReflectTex,ReflectSampler, uv.xy);

	float3 eyevec = normalize(input.eyevec.xyz);
	float alpha = (1.0 - eyevec.y*eyevec.y)*0.55 + 0.35;

	float t = input.color.a * 0.5;
	float4 color = lerp(watercolor, reflect_color, t);


#if FOG_DISTANCE>0
	color.rgb = lerp(g_DistFogColor.rgb, color.rgb, input.fogc.x);
#endif
#if FOG_HEIGHT > 0
	color.rgb = lerp(g_HeightFogColor.rgb, color.rgb, input.fogc.y);
#endif

	return 	float4(color.rgb, alpha);
}
