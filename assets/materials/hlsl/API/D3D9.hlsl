// ALso used for Direct3D 11 "feature level 9.x" target for Windows Store and Windows Phone
#define ENG_UV_STARTS_AT_TOP 1
#define ENG_REVERSED_Z 0
#define ENG_GATHER_SUPPORTED 0
#define ENG_CAN_READ_POSITION_IN_FRAGMENT_PROGRAM 1


#define TEXTURE2D_SAMPLER2D(textureName, samplerName) sampler2D samplerName
#define TEXTURE3D_SAMPLER3D(textureName, samplerName) sampler3D samplerName

#define TEXTURE2D(textureName) 
#define SAMPLER2D(samplerName)  sampler2D samplerName

#define TEXTURE3D(textureName) 
#define SAMPLER3D(samplerName)  sampler3D samplerName


#define TEXTURE2D_ARGS(textureName, samplerName) sampler2D samplerName
#define TEXTURE2D_PARAM(textureName, samplerName) samplerName

#define TEXTURE3D_ARGS(textureName, samplerName) sampler3D samplerName
#define TEXTURE3D_PARAM(textureName, samplerName) samplerName

//新增的
#define SAMPLE_TEXTURE2D_PRO(textureName, samplerName, coord4)   tex2Dproj(samplerName, coord4)

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(samplerName, float4(coord2, 0.0, lod))

#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3) tex3D(samplerName, coord3)

#define LOAD_TEXTURE2D(textureName, texelSize, icoord2) tex2D(samplerName, icoord2 / texelSize)
#define LOAD_TEXTURE2D_LOD(textureName, texelSize, icoord2) tex2Dlod(samplerName, float4(icoord2 / texelSize, 0.0, lod))

#define SAMPLE_DEPTH_TEXTURE(textureName, samplerName, coord2) SAMPLE_TEXTURE2D(samplerName, samplerName, coord2).r
#define SAMPLE_DEPTH_TEXTURE_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_LOD(samplerName, samplerName, coord2, lod).r


#define TEXTURECUBE(textureName) 
#define SAMPLERCUBE(samplerName)    samplerCUBE  samplerName
#define SAMPLE_TEXTURECUBE(textureName,samplerName,coord3)  texCUBE(samplerName,coord3)
#define TEXTURECUBE_ARGS(textureName, samplerName) samplerCUBE samplerName


#define CBUFFER_START(name)
#define CBUFFER_END

#define FXAA_HLSL_3 1
#define SMAA_HLSL_3 1
