
float4x4 g_WorldViewProj ;
//shader有错误的替代方案
struct VS_INPUT {
    float4 pos : POSITION;
};

struct VS_OUTPUT {
    float4 pos : SV_POSITION;
};

VS_OUTPUT VSMain (VS_INPUT v)
{
    VS_OUTPUT o;
    o.pos = mul(float4(v.pos.xyz,1.0), g_WorldViewProj);
    return o;
}

float4 PSMain(VS_OUTPUT input):SV_Target
{
     return float4(1,0,1,1);
}