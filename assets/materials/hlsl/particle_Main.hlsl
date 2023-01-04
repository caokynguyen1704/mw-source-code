#include "Headers/header.hlsl"


struct VS_OUTPUT
{
    float4 pos      : POSITION;
    float4 color0   : COLOR0;
    float2 uv0      : TEXCOORD0;
#ifdef PARTICLE_MASK_TEXTURE
    float2 uv1		: TEXCOORD1;
#endif
};

struct VS_INPUT
{
   	float4 pos      : POSITION;
    float4 color0   : COLOR0;
    float2 uv0      : TEXCOORD0;
	#ifdef PARTICLE_MASK_TEXTURE
    float2 uv1		: TEXCOORD1;
	#endif
};

VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;
    
	output.pos = mul(input.pos,g_WorldViewProj);
    
	output.color0 = input.color0;

    
	output.uv0 = input.uv0;
#if PARTICLE_MASK_TEXTURE
	output.uv1 = input.uv1;
#endif
	return output;
}

float       g_fBlendMode;
TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);
#ifdef PARTICLE_MASK_TEXTURE
TEXTURE2D(g_MaskTex);   SAMPLER2D(s_MaskSampler);
#endif

float4 PSMain(VS_OUTPUT input):SV_Target
{
	float4 color0  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
	float4 color = color0 * input.color0;

#ifdef ALPHA_TEST
	clip(color.a - 0.5);
#endif
	if(g_fBlendMode == 1.0f)
	{
	   if(input.color0.r <= 0.5)
	      color.r = color0.r * input.color0.r / 0.5f;
	   else
	      color.r = 1.0f - (1.0f - color0.r) * (1.0f - input.color0.r) / 0.5f;
	   if(input.color0.g <= 0.5)
	      color.g = color0.g * input.color0.g / 0.5f;
	   else
	      color.g = 1.0f - (1.0f - color0.g) * (1.0f - input.color0.g) / 0.5f;
	   if(input.color0.b <= 0.5)
	      color.b = color0.b * input.color0.b / 0.5f;
	   else
	      color.b = 1.0f - (1.0f - color0.b) * (1.0f - input.color0.b) / 0.5f;	}
	else if(g_fBlendMode == 2.0f)
	{
	   color.rgb = color0.rgb + input.color0.rgb;
	}
	else if(g_fBlendMode == 3.0f)
	{
	   color.rgb = 1.0f - (1.0f - color0.rgb) * (1.0f - input.color0.rgb);
	}
	
#ifdef PARTICLE_MASK_TEXTURE
	color = color * SAMPLE_TEXTURE2D(g_MaskTex,s_MaskSampler,input.uv1);
#endif

	return color;
}