#define AA 4
#define AA2 (AA * AA)

#include "../../Common/Camera.glsl"
#include "../../MeshData/TriangularMesh.glsl"
#iChannel0 "../../../Assets/Textures/Checker.jpg"
#iChannel1 "../../../Assets/Textures/Girl.jpg"

// Create a geometry data
#define VECTICES_COUNT 12
#define INDICES_COUNT 42

SPoint GPoints[VECTICES_COUNT];
int GIndices[INDICES_COUNT];

void MakeMesh()
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

    MakePlaneMesh(PlanePoints, PlaneIndices, 3., 3.);
    for(int i = 0; i < 4; ++i)
    {
        GPoints[i + 8] = PlanePoints[i];
    }

    for(int j = 0; j < 6; ++j)
    {
        GIndices[j + 36] = PlaneIndices[j] + 8;
    }
}

vec2 FixUV(in vec2 fragCrood)
{
    return (2. * fragCrood - iResolution.xy) / min(iResolution.x, iResolution.y);
}

vec2 FixUV2(in vec2 fragCrood)
{
    return fragCrood / iResolution.xy * 2.0 - 1.0;
}

// Create a grid
vec3 Grid(vec2 UV, int Num)
{
    vec3 Col = vec3(0.4);

    vec2 UV2 = float(Num) * UV;
    vec2 Cell = floor(mod(UV2, 2.));
    if(Cell.x == Cell.y) Col = vec3(0.6);

    if(abs(UV.y) < fwidth(UV.y))
    {
        Col = vec3(0., 0., 0.);
    }

    if(abs(UV.x) < fwidth(UV.x))
    {
        Col = vec3(0., 0., 0.);
    }

    return Col;
}

// > 0 B is the left of A
// = 0 B and A coincide
// < 0 B is the right of A
float Cross2d(vec2 A, vec2 B)
{
    return A.x * B.y - A.y * B.x;
}

void VertexFromWorldToNDCSpace(mat4 MVP, in SPoint InPoint, out SPoint OutPoint, out float W)
{
    vec4 Position = MVP * vec4(InPoint.Position, 1.0);
    vec4 Normal = MVP * vec4(InPoint.Normal, 1.0);
    W = Position.w;
    OutPoint.Position = Position.xyz / W;
    OutPoint.Normal = Normal.xyz;
    OutPoint.Color = InPoint.Color;
    OutPoint.UV = InPoint.UV / W;
}


// reference https://www.bilibili.com/video/BV1X7411F744?p=5 about 52 minutes
bool InsideTriangle(vec2 P, vec2 V1, vec2 V2, vec2 V3, out vec3 D)
{
    // anti-clockwise
    // So the left-hand side of the edge vector
    D.x = Cross2d(V2- V1, P - V1);
    D.y = Cross2d(V3 - V2, P - V2);
    D.z = Cross2d(V1 - V3, P - V3);
    if(D.x >= 0. && D.y >= 0. && D.z >= 0.)
    {
        return true;
    }
    return false;
}

// 计算相机空间的深度值
float LinearDepth(float Depth, float Near, float Far)
{
    float Z = Depth;// * 2. - 1.;
    return (2. * Near * Far) / ((Far + Near) - Z * (Near - Far)); 
}

// reference https://zhuanlan.zhihu.com/p/403259571
// reference https://zhuanlan.zhihu.com/p/512511648
vec3 PerspectiveCorrection(vec3 AlphaBetaGamma, float Z1, float Z2, float Z3)
{
    float Alpha = AlphaBetaGamma.x / Z1;
    float Beta = AlphaBetaGamma.y / Z2;
    float Gamma = AlphaBetaGamma.z / Z3;
    float Zn = 1. / ( Alpha + Beta + Gamma);
    return Zn * vec3(Alpha, Beta, Gamma);
}


vec4 Render(vec2 P)
{
    const float Near= -.1, Far = -1000.; 
    float Aspect = iResolution.x / iResolution.y;
    P.x /= Aspect;
    mat4 ProjectMatrix = MakeOrthographic(- 5., 5., 5./ Aspect, -5./ Aspect, Near, Far);
    float Mov = (sin(iTime) + 1.)/2.;
    mat4 ViewMatrix = MakeCameraInverseMatrix(vec3(5. * Mov, 5. * Mov, 5.), vec3(0.));
    ProjectMatrix = MakePerspective(53., Aspect, Near, Far);

    vec4 Col = vec4(0.);

    MakeMesh();

    float Depth = -99999999.; 
    for(int i = 0; i < INDICES_COUNT; i += 3)
    {
        vec3 D;
        SPoint V1 = GPoints[GIndices[i]], V2 = GPoints[GIndices[i+1]], V3 = GPoints[GIndices[i+2]];
        mat4 MVP = ProjectMatrix * ViewMatrix;
        SPoint VV1, VV2, VV3;
        float W1, W2, W3;
        VertexFromWorldToNDCSpace(MVP, V1, VV1, W1);
        VertexFromWorldToNDCSpace(MVP, V2, VV2, W2);
        VertexFromWorldToNDCSpace(MVP, V3, VV3, W3);
        bool bRenderVV1 = VV1.Position.z <= 1. && VV1.Position.z >= -1.;
        bool bRenderVV2 = VV2.Position.z <= 1. && VV2.Position.z >= -1.;
        bool bRenderVV3 = VV3.Position.z <= 1. && VV3.Position.z >= -1.;
        if(!bRenderVV1 && !bRenderVV2 && !bRenderVV3) continue;
        bool bInside = InsideTriangle(P, VV1.Position.xy, VV2.Position.xy, VV3.Position.xy, D);
        if(bInside)
        {
            // reference: https://www.bilibili.com/video/BV1X7411F744?p=9 about 10 minutes
            // Triangle interpolate
            // Barycenteric coord
            //      P3 
            //     / \
            //    / P \
            //   p1----p2
            // P(x, y) = a * P1 + b * P2 + c * P3
            // α + β + γ = 1 (a >= 0 && b >= 0 && c >= 0)
            vec3 AlphaBetaGamma = D.yzx / (D.x + D.y + D.z);

            // Perspective correction
            float Depth1 = LinearDepth(VV1.Position.z, Near, Far);
            float Depth2 = LinearDepth(VV2.Position.z, Near, Far);
            float Depth3 = LinearDepth(VV3.Position.z, Near, Far);
            AlphaBetaGamma = PerspectiveCorrection(AlphaBetaGamma, Depth1, Depth2, Depth3);

            float CDepth = AlphaBetaGamma.x * Depth1
                + AlphaBetaGamma.y * Depth2
                + AlphaBetaGamma.z * Depth3;
            
            if(CDepth < Depth) continue;
            Depth = CDepth;

            vec3 C = AlphaBetaGamma.x * V1.Color 
                + AlphaBetaGamma.y * V2.Color 
                + AlphaBetaGamma.z * V3.Color;

            
            if(i >= 36)
            {
                vec2 UV = AlphaBetaGamma.x * V1.UV
                + AlphaBetaGamma.y * V2.UV
                + AlphaBetaGamma.z * V3.UV;
                C = texture(iChannel0, UV).xyz;
            }

            Col.rgb = C; Col.a = 1.;
        }
    }

    return Col; 
}

void mainImage(out vec4 fragColor, in vec2 fragCrood)
{
    vec2 UV = FixUV2(fragCrood);

    // anti-aliasing
    vec4 Col = vec4(0.);
    for (int S = 0; S < AA; S++)
    {
        for (int T = 0; T < AA; T++)
        {
            vec2 Offset = vec2(2. * vec2(float(S), float(T)) / float(AA) - 1.);
            Col += Render(FixUV(fragCrood + Offset));
        }
    }

    Col /= float(AA2);

    vec3 GridColor = vec3(0.3, 0.4, 0.5);//Grid(UV, 5);
    
    vec3 Color = mix(GridColor, Col.rgb, Col.a);

    fragColor = vec4(Color, 1.0);
}