#include "Headers/std_lib.hlsl"
#define LT_POINTLIGHT 0
#define LT_DIRLIGHT 1

#define RENDER_USAGE_UI 1
#define RENDER_USAGE_GENERAL 2
#define RENDER_USAGE_REFLECT 4
#define RENDER_USAGE_SHADOWMAPGEN 8
#define RENDER_USAGE_GLOW 16
#define RENDER_USAGE_DISTORT 32
#define RENDER_USAGE_SHADOWCUBEMAPGEN 64
#define RENDER_USAGE_REFRACT 128

#if defined(SKIN_MAXINFL_X) || defined(SKIN_MAXINFL_XY) || defined(SKIN_MAXINFL_XYZ) || defined(SKIN_MAXINFL_XYZW) || defined(SKIN_MAXINFL_STATIC)
//SYS_开头表示内部自定义的宏
#define SYS_SKIN_MAXINFL_ENABLE 1
#endif

#if  defined(SELFILLUM_TEX) ||  defined(SELFILLUM_ALL)
#define SYS_USE_SELFILLUM_TEX  1
#endif


#define BLEND_ALPHATEST 1

// struct SED_Light
// {
//     float4 color;
//     float4 position;
// };

float	g_shadowdensity;
float	g_fTime;



float3 g_EyePos ;
float3 g_EyePosModel;
float3 g_LightSCMPos ;
//阴影用的数值
float4 g_ShadowCenter ;
float4x4  g_depthproj;
float4x4 g_referencepoint;
float3 g_warfogparameter;
float3 g_warfogcolor;

// #ifdef OPEN_G_DIR_LIGHT
//     #define NUM_LIGHTS 1
//      #ifndef LIGHT0_TYPE
//         #define LIGHT0_TYPE  LT_DIRLIGHT
//     #endif
//     #ifndef LIGHT0_SHADOW 
//         #define  LIGHT0_SHADOW 1
//     #endif
//      #ifndef LIGHT0_SPECULAR 
//         #define  LIGHT0_SPECULAR 1
//     #endif
// #endif

//灯光计算
#ifdef OPEN_G_DIR_LIGHT
    // float4 g_LightColor[NUM_LIGHTS];
    // float4 g_LightPos[NUM_LIGHTS];
    // //开了全局光照，开启这个Light阴影宏
    // #define LIGHT_SHADOW 1
    // #ifdef LIGHT0_SPECULAR
    //     #define LIGHT_SPECULAR
        
    // #endif

    #define LIGHT_SHADOW 1
    #define LIGHT_SPECULAR 1

    //太阳直线光的数据
    float4 g_SunLightColor;
    float4 g_SunLightDir;

    float4 g_SpecularColor : SPECULAR_COLOR;

    // TEXTURE2D(g_ShadowMap); 
    // float4x4 g_ShadowMapProj : SHADOWMAP_MATRIX;

    //diffuse
    float3 DoDiffuseLight_Point(float4 lightpos, float4 lightcolor, float3 pos, float3 normal)
    {
        float3 l = lightpos.xyz - pos;
        float r2 = dot(l, l);
        l = normalize(l);
        return lightcolor.xyz * max(0, dot(normal, l)) * max( 0, (1.0 - r2 / lightpos.w / lightpos.w) );
    }

    float3 DoDiffuseLight_Dir(float4 lightpos, float4 lightcolor, float3 pos, float3 normal)
    {
        //float3 dir = normalize(lightpos.xyz);
        return lightcolor.xyz * max(0, dot(normal, lightpos.xyz));
    //	float3 diffuse = (dot(normal,dir)*0.5 + 0.5) * light.color.xyz;
    //	return diffuse*diffuse;
    }


    #ifdef LIGHT_SPECULAR
        //灯的高光计算
         float DoSpecularLight_Point(float4 lightpos, float4 lightcolor, float3 pos, float3 normal)
        {
            float3 viewdir = normalize(g_EyePosModel - pos);
            viewdir = -reflect(viewdir, normal);
            
            float3 l = lightpos.xyz - pos;
            float spec = max(dot(viewdir, normalize(l)), 0);
        
        //spec = pow(spec, 4.0);
            float specTemp = spec*spec;
            spec = specTemp * specTemp;

            float r2 = dot(l, l);
            return spec * max(0, (1.0 - r2/lightpos.w/lightpos.w));
        }

        float DoSpecularLight_Dir(float4 lightDir, float4 lightcolor, float3 pos, float3 normal)
        {
            float3 viewdir = normalize(g_EyePosModel - pos);
            viewdir = reflect(viewdir, normal);

            float spec = max(dot(-viewdir, lightDir.xyz),0.0f);
        
        // spec = pow(spec,4.0);
            float specTemp = spec*spec;
            spec = specTemp * specTemp;

            return spec;
        }
    #endif

    float4 DoOnePointLight(float4 lightpos, float4 lightcolor, float3 pos, float3 normal) {
        float4 color = float4(0,0,0,0);
        color.xyz = DoDiffuseLight_Point(lightpos, lightcolor, pos, normal);
        #ifdef LIGHT_SPECULAR
            color.w = DoSpecularLight_Point(lightpos, lightcolor, pos, normal);
        #else
            color.w = 0;
        #endif
        return color;
    }

    float4 DoOneDirLight(float4 lightpos, float4 lightcolor, float3 pos, float3 normal) {
        float4 color = float4(0,0,0,0);
        color.xyz = DoDiffuseLight_Dir(lightpos, lightcolor, pos, normal);
        #ifdef LIGHT_SPECULAR
            color.w = DoSpecularLight_Dir(lightpos, lightcolor, pos, normal);
        #else
            color.w = 0;
        #endif
        return color;
    }

    
#endif //OPEN_G_DIR_LIGHT

float4 g_AmbientLight : AMBIENT_LIGHT;
float4 DoLighting(float3 pos, float3 normal, uniform int doshadow)
{
	float4 color;
	color = doshadow>0?float4(0.0f,0.0f,0.0f,0.0f):g_AmbientLight;        
    #ifdef OPEN_G_DIR_LIGHT
        color += DoOneDirLight(g_SunLightDir, g_SunLightColor, pos, normal);
    #endif //OPEN_G_DIR_LIGHT

	return color;
}

#if defined(FOG_DISTANCE) || defined(FOG_HEIGHT)
    #if defined(FOG_DISTANCE) 
        float4 g_DistFogColor ;  //: DIST_FOG_COLOR
    #endif
    #if defined(FOG_HEIGHT)
        float4 g_HeightFogColor ;  //: HEIGHT_FOG_COLOR
    #endif
    float4 g_FogParam ;  //: FOG_PARAM
#endif

#ifdef SYS_SKIN_MAXINFL_ENABLE
    float4 g_BoneTM[210]    ;  //:BONE_MATRIX
#endif

float4x4 g_World            ;  //: WORLD
float4x4 g_WorldView        ;  //: WORLDVIEW
float4x4 g_WorldViewProj    ;

// TEXTURE2D(g_LightMap);
// TEXTURE2D(g_ReflectMap);
// TEXTURE2D(g_FracMap);

#if MORPH_POS > 0  || MORPH_UV0 > 0
    #if MORPH_POS > 0
    float4 g_MorphRangePos[2] : MORPH_RANGE_POS;
    #endif
    
    #if MORPH_UV0 > 0
    float4 g_MorphRangeUV : MORPH_RANGE_UV;
    #endif
#endif


#if MORPH_POS > 0
    float4 DoPosMorph(float4 pos0, float4 pos1)
    {
        float4 inputpos = pos0*(1.0-g_fTime) + pos1*g_fTime;
        inputpos = g_MorphRangePos[0] + g_MorphRangePos[1]*inputpos.zyxw;
        return inputpos;
    }

    float3 DoNormalMorph(float3 normal0, float3 normal1)
    {
        float3 inputnorm = normal0*(1.0-g_fTime) + normal1*g_fTime;
        return inputnorm;
    }
#endif

#if MORPH_UV0 > 0
    float2 DoUVMorph(float2 uv0, float2 uv1)
    {
        float2 uv = uv0*(1.0-g_fTime) + uv1*g_fTime;
        uv = g_MorphRangeUV.xy + g_MorphRangeUV.zw*uv;
        return uv;
    }
#endif

float2 DoSphereEnvMapping(float3 normal)
{
    float4 tmpnormal = mul(float4(normal, 0), g_WorldView);
    return  tmpnormal.xy*float2(0.5, -0.5) + float2(0.5, 0.5);
}

#ifdef SYS_SKIN_MAXINFL_ENABLE
    #ifdef SKIN_MAXINFL_STATIC
        void DoSkinVertex(float4 blendindices, float4 blendweights, float4 inputpos, float3 inputnorm, out float3 pos, out float3 normal)
        {
            #if SHADER_API_D3D9 
                blendweights.xyz=blendweights.zyx;
            #endif
            pos = float3(dot(inputpos,g_BoneTM[0]),dot(inputpos,g_BoneTM[1]),dot(inputpos,g_BoneTM[2]));
            normal = float3(dot(inputnorm.xyz,g_BoneTM[0].xyz),dot(inputnorm.xyz,g_BoneTM[1].xyz),dot(inputnorm.xyz,g_BoneTM[2].xyz));
            normal = normalize(normal);
        }
    #else
        void DoSkinVertex(float4 blendindices, float4 blendweights, float4 inputpos, float3 inputnorm, out float3 pos, out float3 normal)
        {
            #if SHADER_API_D3D9 
                blendweights.xyz=blendweights.zyx;
            #endif
            pos = float3(0, 0, 0);
            normal = float3(0, 0, 0);
            int4 indices = blendindices * 3;
            pos += float3(dot(inputpos,g_BoneTM[indices.x]),dot(inputpos,g_BoneTM[indices.x+1]),dot(inputpos,g_BoneTM[indices.x+2])) * blendweights.x;
            normal += float3(dot(inputnorm,g_BoneTM[indices.x].xyz),dot(inputnorm,g_BoneTM[indices.x+1].xyz),dot(inputnorm,g_BoneTM[indices.x+2].xyz)) * blendweights.x;

            #if defined(SKIN_MAXINFL_XY) || defined(SKIN_MAXINFL_XYZ) || defined(SKIN_MAXINFL_XYZW)
                pos += float3(dot(inputpos,g_BoneTM[indices.y]),dot(inputpos,g_BoneTM[indices.y+1]),dot(inputpos,g_BoneTM[indices.y+2])) * blendweights.y;
                normal += float3(dot(inputnorm,g_BoneTM[indices.y].xyz),dot(inputnorm,g_BoneTM[indices.y+1].xyz),dot(inputnorm,g_BoneTM[indices.y+2].xyz)) * blendweights.y;
            #endif

            #if  defined(SKIN_MAXINFL_XYZ) || defined(SKIN_MAXINFL_XYZW)
                pos += float3(dot(inputpos,g_BoneTM[indices.z]),dot(inputpos,g_BoneTM[indices.z+1]),dot(inputpos,g_BoneTM[indices.z+2])) * blendweights.z;
                normal += float3(dot(inputnorm,g_BoneTM[indices.z].xyz),dot(inputnorm,g_BoneTM[indices.z+1].xyz),dot(inputnorm,g_BoneTM[indices.z+2].xyz)) * blendweights.z;
            #endif

            #if defined(SKIN_MAXINFL_XYZW)
                pos += float3(dot(inputpos,g_BoneTM[indices.w]),dot(inputpos,g_BoneTM[indices.w+1]),dot(inputpos,g_BoneTM[indices.w+2])) * blendweights.w;
                normal += float3(dot(inputnorm,g_BoneTM[indices.w].xyz),dot(inputnorm,g_BoneTM[indices.w+1].xyz),dot(inputnorm,g_BoneTM[indices.w+2].xyz)) * blendweights.w;
            #endif

            normal = normalize(normal);
        }
    #endif //SKIN_MAXINFL_STATIC

#endif //SYS_SKIN_MAXINFL_ENABLE

// float DoSCMShadow(TEXTURECUBE_ARGS(g_ShadowCubeMap,s_SCMSampler),float3 pos)
// {
// 	float linearZ = dot(pos,pos) - 5000.0f - 100000000.0f;

//     float CubeZ =  SAMPLE_TEXTURECUBE(g_ShadowCubeMap,s_SCMSampler,pos).x;
    
// 	float shadow = ( (linearZ - CubeZ ) > 0.0f )?0.0f:1.0f;
	
// 	return shadow;
// } 

// #define SHADOWMAP_SIZE  1024.0


//软阴影
// float DoSoftShadow(TEXTURE2D_ARGS(g_depthtexture,s_DepthMapSampler),float4 uv,float z)
// {
//     float shadow = 0.0f; 
//     for(int i=-1;i<2;i++)
//         for(int j=-1;j<2;j++)
//         {
//             float2 texuv = uv.w * float2(i/SHADOWMAP_SIZE,j/SHADOWMAP_SIZE);
//             shadow += SAMPLE_TEXTURE2D_LOD( g_depthtexture,s_DepthMapSampler, uv.xy + texuv,0).x;//
//         }
//     return shadow*0.1111f;
// }
#define SHADOWMAP_SIZE  1024.0
float DoSoftShadow(TEXTURE2D_ARGS(depthTex,depthSample),float4 uv,float z)
{
    float shadow = 0.0f; 
    for(int i=-1;i<2;i++)
    {
        for(int j=-1;j<2;j++)
        {
            float2 texuv =  float2(i/SHADOWMAP_SIZE,j/SHADOWMAP_SIZE);
            #if defined(SHADER_API_D3D9)
                uv.xy=uv.xy+texuv;
                shadow += SAMPLE_TEXTURE2D_PRO(depthTex,depthSample, uv).x;
            #else
                uv.xy=uv.xy+texuv;
                shadow += SAMPLE_DEPTH_TEXTURE(depthTex,depthSample, uv.xy);
            #endif
            //shadow += SAMPLE_TEXTURE2D_LOD( g_depthtexture,s_DepthMapSampler, uv.xy + texuv,0).x;//
        }
    }
        
    return shadow*0.1111f;
}



float DoHardShadow(TEXTURE2D_ARGS(depthTex,depthSample),float4 uv,float z)
{
    #if defined(SHADER_API_D3D9)
        return SAMPLE_TEXTURE2D_PRO(depthTex,depthSample, uv).x;
    #elif defined(SHADER_API_OGLES)
        return SAMPLE_DEPTH_TEXTURE(depthTex,depthSample, uv.xy/uv.w)*uv.w > uv.z;
    #else
        return SAMPLE_DEPTH_TEXTURE(depthTex,depthSample, uv.xy/uv.w)*uv.w > uv.z;
    #endif
}



#if defined(FOG_DISTANCE)
    float DoFogDist(float3 pos)
    {
        float dist = distance(pos, g_EyePosModel);
        float fogc_d = (g_FogParam.y - dist)/(g_FogParam.y - g_FogParam.x);

        return clamp(fogc_d, 0, 1.0);
    }
#endif

#if defined(FOG_HEIGHT) || defined(FOG_DISTANCE)
    float2 DoFog(float3 pos)
    {
        float fogc_d = 1.0;
        float fogc_h = 1.0f;

   #if defined(FOG_DISTANCE)
        float dist = distance(pos, g_EyePosModel);
        fogc_d = (g_FogParam.y - dist)/(g_FogParam.y - g_FogParam.x);
    #endif

    #if defined(FOG_HEIGHT)
        fogc_h = (g_FogParam.w + pos.y)/(g_FogParam.w - g_FogParam.z);
    #endif


        return clamp(float2(fogc_d, fogc_h), 0, 1.0);
    }
#endif

float2 FixScreenUV(float2 uv)
{

    return  uv * float2(1.0, -1.0) + float2(0.0, 1.0);

}

//计算UV
float4 CalShadowProjUV(float4 pos)
{
	float4 projpos = mul(pos, g_depthproj);

#ifdef LOG_SHADOWMAP
	float2 diff = projpos.xy - g_ShadowCenter.xy;
	float t = length(diff);
	float nt = g_ShadowCenter.w * log(g_ShadowCenter.z*t + 1)/t;

	float4 uv;
	uv.xy = (g_ShadowCenter.xy + diff*nt)*float2(0.5, -0.5) + float2(0.5, 0.5)*projpos.w;
	uv.zw = projpos.zw;
#else
	float4 uv;
	//uv.xy = projpos*float2(0.5, -0.5) + float2(0.5, 0.5)*projpos.w;
	uv.xy = projpos.xy;
	uv.zw = projpos.zw;
#endif
	return uv;
}

//物体到世界方向
inline float3 ObjectToWorldDir( in float3 norm )
{
    return normalize(mul(norm, (float3x3)g_World));
}
//物体到世界坐标
inline float4 ObjectToWorldPos( in float3 pos)
{
    return mul(float4(pos,1),g_World);
}

//齐次空间
inline float4 ObjectToClipPos( in float3 pos )
{
    return mul(float4(pos, 1.0),g_WorldViewProj);
}

// inline float4 ObjectToViewPos( in float3 pos )
// {
//     return mul(float4(pos, 1.0),g_WorldView);
// }


float GetLuminance(float3 val)
{
    return dot(val, float3(0.299, 0.587, 0.114));
}

//亮度过滤值
#define CONST_THRESHOLD  0.4
#define CONST_KNEE    0.5
float4 LightThreshold(float4 color, float threshold, float3 curve)
{
    // Pixel brightness
    float br = GetLuminance(color.rgb)*step(0.1,color.a);
    
    float rq = clamp(br - curve.x, 0.0, curve.y);
    rq = curve.z * rq * rq;
    float vv= max(rq, br - threshold) / max(br, 0.001f);

    color.rgb *= vv;
    return color;
}



// half3 LinearToSRGB(half3 c)
// {
// #if USE_VERY_FAST_SRGB
//     return sqrt(c);
// #elif USE_FAST_SRGB
//     return max(1.055 * PositivePow(c, 0.416666667) - 0.055, 0.0);
// #else
//     half3 sRGBLo = c * 12.92;
//     half3 sRGBHi = (PositivePow(c, half3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
//     half3 sRGB = (c <= 0.0031308) ? sRGBLo : sRGBHi;
//     return sRGB;
// #endif
// }

// half4 LinearToSRGB(half4 c)
// {
//     return half4(LinearToSRGB(c.rgb), c.a);
// }

