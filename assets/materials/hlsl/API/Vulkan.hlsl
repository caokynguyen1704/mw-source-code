#define ENG_UV_STARTS_AT_TOP 1
#define ENG_REVERSED_Z 1
#define ENG_GATHER_SUPPORTED (SHADER_TARGET >= 50)
#define ENG_CAN_READ_POSITION_IN_FRAGMENT_PROGRAM 1

#include "D3D11Common.hlsl"

#if ENG_GATHER_SUPPORTED
    #define FXAA_HLSL_5 1
    #define SMAA_HLSL_4_1 1
#else
    #define FXAA_HLSL_4 1
    #define SMAA_HLSL_4 1
#endif
