#define ENG_UV_STARTS_AT_TOP 1
#define ENG_REVERSED_Z 1
#define ENG_GATHER_SUPPORTED 0 // Currently broken on Metal for some reason (May 2017)
#define ENG_CAN_READ_POSITION_IN_FRAGMENT_PROGRAM 1

#include "D3D11Common.hlsl"

#define FXAA_HLSL_4 1 // See ENG_GATHER_SUPPORTED
#define SMAA_HLSL_4 1
