#include "Headers/header.hlsl"
#include "Headers/sky.hlsl"

float   g_SkyHeight;
float   g_DayTime;

struct VS_INPUT
{
    float3 position : POSITION;
    float3 normal   : NORMAL;
    float2 texcoord : TEXCOORD0;
};

struct VS_OUTPUT
{
	float4 position : POSITION;
//	float3 normal   : NORMAL;
	float2 texcoord : TEXCOORD0;
};


VS_OUTPUT VSMain(VS_INPUT input)
{
	VS_OUTPUT output;

	float t = g_DayTime * 0.01;
	float3 position = rotateZ(input.position, t);
	output.position = mul(float4(position + g_EyePos, 1.0), g_WorldViewProj);
	output.position = output.position.xyww;
//	output.normal = normalize(input.position);
	float3 normal = normalize(input.normal);  // normalize(input.position);
//	output.texcoord = float4(g_DayTime, 1.0 - input.position.y/g_SkyHeight, input.texcoord.xy);

	output.texcoord = input.texcoord;
	return output;
}


TEXTURE2D(g_SkyTex);    SAMPLER2D(s_SkySampler);
float g_fAmount;

// https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
float2 random(float2 uv)
{
    return frac(sin(dot(uv , float2(12.9898, 78.233))) * 43758.5453);
}

float4 PSMain(VS_OUTPUT input): SV_Target
{
/*
	float f = floor(g_DayTime);
	// Max allowed instructions by the target ps_2_0 is 64.
	const int arrayLength = 2;  // a.length() in GLSL
	const float2 a[arrayLength] =
	{
		// some random numbers
		float2(1.01, 3.141),
		float2(2.23, 1.834)
	//	float2(1.10, 0.412)
	};
	float3 distance = {0.0, 0.0, 0.0};
	for(int i = 0; i < arrayLength; ++i)
	{
		float2 point0 = random(a[i] * f);
		distance[i] = 5.0 * length(frac(0.25 * input.texcoord.zw) - point0);
	}
	distance = 1.0 - min(distance, 0.8);

	float d = saturate(distance.x + distance.y);
//	float d = distance.x + distance.y + distance.z;
//	float d = dot(distance, float3(1.0, 1.0, 1.0));
//	const float angle = 3.14159265358979 / 2.0;
	float2 dudv = {1.0, 0.0};//{cos(angle), sin(angle)};
	dudv *= g_DayTime * 0.03;
	float2 texcoord = input.texcoord.zw + dudv;
*/
	float4 color = SAMPLE_TEXTURE2D(g_SkyTex, s_SkySampler, input.texcoord);
//	return float4(d, 0.0, 0.0, 1.0);
//	d *= g_fAmount * 0.4;
//	color.rgb *= d + 0.15 * (g_fAmount - 0.5);
	color.a = 1.0;
	return color;
}
