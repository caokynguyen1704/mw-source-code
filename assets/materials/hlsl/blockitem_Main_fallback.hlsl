#include "Headers/header.hlsl"


struct VS_INPUT
{
    float4 pos        : POSITION;
    float4 color      : COLOR0;
#ifndef USE_CUSTOM_MODEL
    float2 uv0        : TEXCOORD0;
#endif

#if SYS_SKIN_MAXINFL_ENABLE
	float  blendindices : BLENDINDICES;
#endif
};

struct VS_OUTPUT
{
    float4 pos        : POSITION;
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

	return output;
}




float4 PSMain(VS_OUTPUT input):SV_Target
{
	return float4(1,0,1,1);
}
