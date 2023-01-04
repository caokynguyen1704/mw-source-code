
#include "Headers/header.hlsl"

// #define OPEN_ROLE_SHADOW  1

float g_ModelTransparent ;  //: MODEL_XPARENT
float3	g_SelfPower;
float	g_SpecPower;

float3 g_SunDirection;
float4 g_SkyLightColor;
float4 g_TorchLightColor;
float4 g_InstanceData;

#ifdef USE_RIM_COLOR
    float4 g_RimColor;
    float g_RimPower;  //1-20
#endif
//UV动画的修改
#ifdef SYS_USE_SELFILLUM_TEX
    float g_TransU ;
    float g_TransV ;
    float g_ScaleU ;
    float g_ScaleV ;
    float g_RotUV ;
#endif

struct VS_INPUT
{
        float4 pos        : POSITION;
        float3 normal        : NORMAL;
        float2 uv0            : TEXCOORD0;

    #ifdef SYS_SKIN_MAXINFL_ENABLE
        float4 blendweights : BLENDWEIGHT;
        float4 blendindices : BLENDINDICES;
    #endif

       
    #if SYS_USE_SELFILLUM_TEX
        float2 uv1 : TEXCOORD1;
    #endif
};

struct VS_OUTPUT
{
    float4 pos            : POSITION;
    float4 color0        : COLOR0; //color0.xyz=ambient lighting,  color0.w=specular lighting
    float4 uv0            : TEXCOORD0;

#ifdef OPEN_G_DIR_LIGHT
    // float4 color1        : COLOR1; //color1.xyz=shadowed_lighting,  color1.w=specular lighting
    float4 shadowUV            : TEXCOORD1;    
#endif

#if defined(FOG_HEIGHT) || defined(FOG_DISTANCE)
	float2 fogc	: TEXCOORD2;
#endif

#ifdef SYS_USE_SELFILLUM_TEX
	float2 uv2 : TEXCOORD3;
#endif 

#ifdef USE_RIM_COLOR
    //世界法线
    float3 world_normal:TEXCOORD4;
    float3 view_dir:TEXCOORD5;
#endif
};



VS_OUTPUT VSMain(VS_INPUT input)
{
    VS_OUTPUT output;
    
    float3 pos;
    float3 normal;

#ifdef SYS_SKIN_MAXINFL_ENABLE
	DoSkinVertex(input.blendindices, input.blendweights, input.pos, input.normal, pos, normal);
#else
    pos        = input.pos.xyz;
 
#endif
    normal    = input.normal;
    normal = normalize(normal);

    output.pos = mul(float4(pos,1.0), g_WorldViewProj);
#if defined(USE_RIM_COLOR) || defined(OPEN_ROLE_SHADOW)
    float3 world_normal = ObjectToWorldDir(normal);
    float4 wpos2 = ObjectToWorldPos(pos);
    //边缘光
    #if defined(USE_RIM_COLOR)
        float3 viewdir = normalize(g_EyePos - wpos2.xyz);
        // world_normal.rgb = normal;
        output.world_normal=normalize(world_normal);
        output.view_dir=viewdir;
    #endif
#endif
    float n = 1.0;
// #endif

    float t = g_InstanceData.x*g_SkyLightColor.a;
    
    float3 ambient = max(t*g_SkyLightColor.rgb, g_InstanceData.y*g_TorchLightColor.rgb) * n;
    output.color0.rgb = ambient + (1.0-t)*g_AmbientLight.xyz + float3(0.2, 0.2, 0.2);
    output.color0.a = 0;
    // output.color0=g_TorchLightColor;
#ifdef SELFILLUM_COLOR
    output.color0.rgb += g_SelfPower.rgb;
#endif

    output.color0.a *= g_SpecPower;

    output.uv0.xy = input.uv0;

#if defined(OPEN_G_DIR_LIGHT) && defined(OPEN_ROLE_SHADOW)
	output.shadowUV = CalShadowProjUV(wpos2);
    output.uv0.z = max(0, dot(world_normal.xyz,g_SunLightDir.xyz));
#endif


#if defined(FOG_HEIGHT) || defined(FOG_DISTANCE)
	output.fogc = DoFog(pos);
#endif

#ifdef SYS_USE_SELFILLUM_TEX
	float angle = radians(g_RotUV);
	float2 uv = (input.uv1 - float2(0.5,0.5))*float2(g_ScaleU, g_ScaleV);
	float u = uv.x*cos(angle) + uv.y*sin(angle);
	float v = -uv.x*sin(angle) + uv.y*cos(angle);
	output.uv2 = float2(u,v) + float2(0.5,0.5) + float2(g_TransU, g_TransV);
#endif 


    return output;
}



 TEXTURE2D(g_DiffuseTex);   SAMPLER2D(s_DiffuseSampler);

#ifdef ALPHATEX_DI
    TEXTURE2D(g_AlphaDITex);   SAMPLER2D(s_AlphaDISampler);
#endif


#ifdef EMISSIVE
float       g_fUVMul;
float       g_ftime;
TEXTURE2D (g_EmissiveTex);  SAMPLER2D(s_EmissiveSampler);
#endif

#ifdef OPEN_G_DIR_LIGHT
    TEXTURE2D(g_depthtexture);   SAMPLER2D(s_DepthMapSampler);
#endif

//
#ifdef SYS_USE_SELFILLUM_TEX
    TEXTURE2D(g_SpecSelfTex);   SAMPLER2D(s_SpecSelfSampler);
#endif

#ifdef OVERLAY_MODE_TEX 
    TEXTURE2D(g_OverlayTex);    SAMPLER2D(s_OverlaySampler);
    float3 g_MaskColor;
#endif

#if defined(OVERLAY_MODE_COLOR) 
    float3 g_OverlayColor;
#endif


float4 PSMain(VS_OUTPUT input):SV_TARGET
{
    
	float4 color  = SAMPLE_TEXTURE2D(g_DiffuseTex,s_DiffuseSampler,input.uv0.xy);
   
    #ifdef ALPHATEX_DI
        color.a = SAMPLE_TEXTURE2D(g_AlphaDITex,s_AlphaDISampler,input.uv0.xy).r;
    #endif

    #ifdef ALPHA_TEST 
        clip(color.a-0.5);
    #endif

    #ifdef OVERLAY_MODE_TEX
        float4 mcolor = SAMPLE_TEXTURE2D(g_OverlayTex,s_OverlaySampler, input.uv0.xy);
        color.rgb = lerp(color.rgb, mcolor.rgb*g_MaskColor, mcolor.a);
    #endif


    #ifdef SELFILLUM_TEX
        float4 selfspec = SAMPLE_TEXTURE2D(g_SpecSelfTex,s_SpecSelfSampler, input.uv0);
    #elif defined(SELFILLUM_ALL)
        float4 selfspec = SAMPLE_TEXTURE2D(g_SpecSelfTex,s_SpecSelfSampler, input.uv2);
    #endif

    float4 lighting = input.color0;


    // return lighting;
    #if defined(SELFILLUM_ALPHA)   ||   defined(SELFILLUM_ALL)
        lighting.rgb = lerp(lighting.rgb, 1.0, color.a); 
    #else
        lighting = clamp(lighting, 0, 1.0);
    #endif

     #if defined(OPEN_G_DIR_LIGHT) && defined(OPEN_ROLE_SHADOW)
        float shadow = DoHardShadow(TEXTURE2D_PARAM(g_depthtexture,s_DepthMapSampler), input.shadowUV, input.shadowUV.z/input.shadowUV.w); 
        // shadow = 1.0f - (1.0f - shadow)*g_shadowdensity;
        // color.rgb = color.rgb * input.color0.rgb *  min(shadow*input.uv0.z+0.8, 1.05);
        shadow = shadow*input.uv0.z;
        lighting.rgb = lighting.rgb  *  min(shadow*input.uv0.z+0.9, 1.05);
    #endif
   

    #ifdef LIGHT_SPECULAR
            #ifdef SYS_USE_SELFILLUM_TEX
                color.rgb = lighting.rgb*color.rgb + g_SpecularColor*lighting.a*0.2f + selfspec.rgb*g_SelfPower;
            #else
                color.rgb = lighting.rgb*color.rgb + g_SpecularColor*lighting.a;
            #endif//USE_SELFILLUM_TEX
     #else
            #ifdef SYS_USE_SELFILLUM_TEX
                color.rgb = lighting.rgb*color.rgb + selfspec.rgb*g_SelfPower;
            #else
                color.rgb = lighting.rgb*color.rgb;
            #endif//USE_SELFILLUM_TEX
    #endif //LIGHT_SPECULAR

  
    #ifdef MODEL_TRANSPARENT_ALPHA
        color.a *= g_ModelTransparent;
    #endif
    
    #ifdef MODEL_TRANSPARENT_RGB
        color *= g_ModelTransparent;
    #endif


    #if defined(OVERLAY_MODE_COLOR)
        color.rgb += g_OverlayColor.rgb;
    #endif
        
    #ifdef EMISSIVE
        float4 tcolor = SAMPLE_TEXTURE2D(g_EmissiveTex,s_EmissiveSampler, input.uv0.xy * g_fUVMul) * g_ftime;
        color.rgb += tcolor.rgb;
    #endif
        

    #if defined(FOG_DISTANCE)
        color.rgb = lerp(g_DistFogColor.rgb, color.rgb, input.fogc.x);
    #endif
    #if defined(FOG_HEIGHT)
        color.rgb = lerp(g_HeightFogColor.rgb, color.rgb, input.fogc.y);
    #endif
//边缘光
#ifdef USE_RIM_COLOR
    float rim = 1.0 - saturate(dot (input.view_dir, input.world_normal));
    float rimRange=pow (rim, g_RimPower);
    float rimRange2=pow (rim, g_RimPower*100);
    float rimRangeA=pow (rim, g_RimPower*5);

    color.rgb=g_RimColor.rgb*rimRange2+ g_RimColor.rgb* rimRange;
    color.a= g_RimColor.a* rimRangeA; 
    
#endif

// #ifdef ALPHA_FOR_BLOOM
// 	#if defined(EMISSIVE)
// 		color.a	= GetLuminance(color.rgb)*tcolor.a;
// 	#endif
// #endif

	
	return color;
}
