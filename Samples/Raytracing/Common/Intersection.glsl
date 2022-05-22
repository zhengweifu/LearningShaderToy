#include "Global.glsl"

// 克莱姆法则
// Möller-Trumbore 算法
bool TriangleIntersection(in vec3 V0, in vec3 V1, in vec3 V2, in SRay Ray, out float T, out float U, out float V)
{
    vec3 S = Ray.Origin - V0;
    vec3 E1 = V1 - V0;
    vec3 E2 = V2 - V0;
    vec3 S1 = cross(Ray.Direction, E2);
    vec3 S2 = cross(S, E1);

    float S1E1 = dot(S1, E1);
    float TT = dot(S2, E2) / S1E1;
    float UU = dot(S1, S) / S1E1;
    float VV = dot(S2, Ray.Direction) / S1E1;

    if (TT >= 0. && UU >= 0. && VV >= 0. && (1. - UU - VV) >= 0.) 
    {
        T = TT;
        U = UU;
        V = VV;
        return true;
    }

    return false;
}