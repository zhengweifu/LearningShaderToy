#include "../Common/Camera.glsl"
#include "Common/Intersection.glsl"
#include "../InverseMatrix.glsl"
#include "../MeshData/TriangularMesh.glsl"

#define INF 1000000.0

SPoint GPoints[12];
int GIndices[42];
void MakeScene()
{
    SPoint CubePoints[8];
    int CubeIndices[36];

    mat4 CubeWorldMatrix = IdentityMatrix4();

    MakeCubeMesh(CubePoints, CubeIndices, CubeWorldMatrix);
    for(int i = 0; i < 8; ++i)
    {
        GPoints[i] = CubePoints[i];
    }

    for(int j = 0; j < 36; ++j)
    {
        GIndices[j] = CubeIndices[j];
    }

    SPoint PlanePoints[4];
    int PlaneIndices[6];

    MakePlaneMesh(PlanePoints, PlaneIndices, 2., 2.);
    for(int i = 0; i < 4; ++i)
    {
        GPoints[i + 8] = PlanePoints[i];
    }

    for(int j = 0; j < 6; ++j)
    {
        GIndices[j + 36] = PlaneIndices[j] + 8;
    }
}

void ClosestHit(SRay Ray, inout vec3 Col)
{
    float HitDis = INF;

    for(int i = 0; i < GIndices.length(); i += 3)
    {
        SPoint P0 = GPoints[GIndices[i]],
            P1 = GPoints[GIndices[i + 1]],
            P2 = GPoints[GIndices[i + 2]];
        float T, U, V;
        if(TriangleIntersection(P0.Position, P1.Position, P2.Position, Ray, T, U, V))
        {
            if (T < HitDis) 
            {
                HitDis = T;
                Col = P0.Color * (1. - U - V) + P1.Color * U + P2.Color * V;
            }
        }
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 UV = (2. * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);
    vec3 Eye = vec3(3, 1., 3.);
    mat3 CameraMatrix = MakeCameraMatrix(Eye, vec3(0.));
    SRay Ray;
    Ray.Origin = Eye;
    Ray.Direction = normalize(CameraMatrix * vec3(UV, -1.));

    vec3 Col = vec3(0.);
    MakeScene();
    ClosestHit(Ray, Col);

    fragColor = vec4(Col, 1.);
}