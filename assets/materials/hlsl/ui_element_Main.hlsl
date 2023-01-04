#include "Headers/header.hlsl"

struct VS_INPUT
{
	float4 pos			: POSITION;
	float4 color         : COLOR0;
	float2 uv0			: TEXCOORD0;
	float2 uv1			: TEXCOORD1;
};



struct VS_OUTPUT
{
	float4 pos			: POSITION;
	float4 color			: COLOR0;
	float2 uv0			: TEXCOORD0;
	float2 uv1			: TEXCOORD1;
};
float		g_Alpha;

#ifdef TRANSFORM_XYZ

#endif


	VS_OUTPUT VSMain(VS_INPUT input)
	{
		VS_OUTPUT output;
	#ifdef TRANSFORM_XYZ
		output.pos = mul(input.pos, g_WorldViewProj);
	#else
		output.pos = input.pos;
	#endif
		output.color = input.color;
		output.color.a = output.color.a * g_Alpha;
		output.uv0 = input.uv0;
		output.uv1 = input.uv1;

		return output;
	}


	TEXTURE2D(g_DiffuseTex);   
	SAMPLER2D(s_DiffuseSampler);

	#ifdef ALPHATEX_DI
		TEXTURE2D(g_AlphaTexDI);   SAMPLER2D(s_AlphaDISampler);
	#endif

	#if defined(MASK_TEXTURE_1) || defined(MASK_TEXTURE_2)
		TEXTURE2D(g_MaskTex); SAMPLER2D(s_MaskSampler);
		float3 g_MaskColor;
	#endif


	float4 PSMain(VS_OUTPUT input):SV_TARGET
	{
		float4 color0 = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0);
		#ifdef ALPHATEX_DI
			color0.a = SAMPLE_TEXTURE2D(g_AlphaTexDI,s_AlphaDISampler,input.uv0).r;
		#endif

		#if defined(RGB_MOD_GRAY)
			color0 *= input.color;
			color0.rgb = dot(color0.rgb, float3(0.299, 0.587, 0.114));
		#elif defined(RGB_MOD_COLOR)
			color0.rgb = input.color.rgb;
			color0.a = color0.a * input.color.a;
		#else
			color0 *= input.color;
		#endif

		#if defined(MASK_TEXTURE_1)
			color0 *= SAMPLE_TEXTURE2D(g_MaskTex,s_MaskSampler,input.uv1);
		#elif defined(MASK_TEXTURE_2)
			color0.rgb = color0.rgb +  SAMPLE_TEXTURE2D(g_MaskTex,s_MaskSampler,input.uv1).rgb * g_MaskColor * color0.a;
		#endif

		return color0;
	}

