#define AA 8
#define AA2 (AA * AA)

//#include "../../InverseMatrix.glsl"

struct SVertex3D
{
    vec3 Position;
    vec3 Normal;
    vec3 Color;
    vec2 UV;
};

// Create a geometry data
#define VECTICES_COUNT 12
#define INDICES_COUNT 42

SVertex3D GVectices[VECTICES_COUNT];
int GIndices[INDICES_COUNT];

void CreateCube()
{
    GVectices[0].Position = vec3(-.5, 0., .5);
    GVectices[0].Color = vec3(1., 0., 0.);

    GVectices[1].Position = vec3(.5, 0., .5);
    GVectices[1].Color = vec3(0., 1., 0.);

    GVectices[2].Position = vec3(.5, 1., .5);
    GVectices[2].Color = vec3(0., 0., 1.);

    GVectices[3].Position = vec3(-.5, 1., .5);
    GVectices[3].Color = vec3(1., 0., 1.);

    GVectices[4].Position = vec3(-.5, 0., -.5);
    GVectices[4].Color = vec3(1., 0., 0.);

    GVectices[5].Position = vec3(.5, 0., -.5);
    GVectices[5].Color = vec3(0., 1., 0.);

    GVectices[6].Position = vec3(.5, 1., -.5);
    GVectices[6].Color = vec3(0., 0., 1.);

    GVectices[7].Position = vec3(-.5, 1., -.5);
    GVectices[7].Color = vec3(1., 0., 1.);

    // front
    GIndices[0] = 0; GIndices[1] = 1; GIndices[2] = 2;
    GIndices[3] = 0; GIndices[4] = 2; GIndices[5] = 3;

    // back
    GIndices[6] = 4; GIndices[7] = 6; GIndices[8] = 5;
    GIndices[9] = 4; GIndices[10] = 7; GIndices[11] = 6;

    // top
    GIndices[12] = 2; GIndices[13] = 6; GIndices[14] = 7;
    GIndices[15] = 2; GIndices[16] = 7; GIndices[17] = 3;

    // bottom
    GIndices[18] = 0; GIndices[19] = 4; GIndices[20] = 5;
    GIndices[21] = 0; GIndices[22] = 5; GIndices[23] = 1;

    // left
    GIndices[24] = 0; GIndices[25] = 3; GIndices[26] = 7;
    GIndices[27] = 0; GIndices[28] = 7; GIndices[29] = 4;

    // right
    GIndices[30] = 1; GIndices[31] = 5; GIndices[32] = 6;
    GIndices[33] = 1; GIndices[34] = 6; GIndices[35] = 2;
}

void CreatePlane()
{
    GVectices[8].Position = vec3(-2., 0., 2.);
    GVectices[8].Color = vec3(1., 0., 0.);

    GVectices[9].Position = vec3(2., 0., 2.);
    GVectices[9].Color = vec3(0., 1., 0.);

    GVectices[10].Position = vec3(2., 0., -2.);
    GVectices[10].Color = vec3(0., 0., 1.);

    GVectices[11].Position = vec3(-2., 0., -2.);
    GVectices[11].Color = vec3(1.0, 0.0, 0.9843);

    GIndices[36] = 8; GIndices[37] = 9; GIndices[38] = 10;
    GIndices[39] = 8; GIndices[40] = 10; GIndices[41] = 11;
}

vec2 FixUV(in vec2 fragCrood)
{
    return (2. * fragCrood - iResolution.xy) / min(iResolution.x, iResolution.y);
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

mat4 IdentityMatrix4()
{
    return mat4(1., 0., 0., 0.,
                0., 1., 0., 0.,
                0., 0., 1., 0.,
                0., 0., 0., 1.);
}

mat4 MakeOrthographic(float Left, float Right, float Top, float Bottom, float Near, float Far)
{
    vec3 Scale = vec3(2. / (Right - Left), 2. / (Top - Bottom), 2. / (-Far + Near));
    vec3 Move = vec3(
        -(Right + Left) / (Right - Left), 
        -(Top + Bottom) / (Top - Bottom),
        -(Near + Far) / (-Far + Near));
    
    return mat4(
        Scale.x, 0.,      0.,      0.,
        0.,      Scale.y, 0.,      0.,
        0.,      0.,      Scale.z, 0.,
        Move.x,  Move.y,  Move.z,  1.
    );
}

mat4 MakePerspective()
{
    mat4 re;
    return re;
}

vec3 UP = vec3(0., 1., 0.);
mat4 MakeCameraMatrix(vec3 Eye, vec3 Target)
{
    vec3 Z = normalize(Eye - Target),
        X = normalize(cross(UP, Z)),
        Y = cross(Z, X);
    
    return mat4(
           X.x,    Y.x,    Z.x, 0.,
           X.y,    Y.y,    Z.y, 0.,
           X.z,    Y.z,    Z.z, 0.,
        -dot(X, Eye), -dot(Y, Eye), -dot(Z, Eye), 1. 
    );
}

void VertexFromWorldToNDCSpace(mat4 MVP, in SVertex3D InVertex, out SVertex3D OutVertex)
{
    vec4 Position = MVP * vec4(InVertex.Position, 1.0);
    vec4 Normal = MVP * vec4(InVertex.Normal, 1.0);
    OutVertex.Position = Position.xyz;// / Position.w;
    OutVertex.Normal = Normal.xyz;/// Position.w;
    OutVertex.Color = InVertex.Color;
    OutVertex.UV = InVertex.UV;
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

void Rasterizer(vec2 V1, vec2 V2, vec2 V3)
{
    //vec3
}



vec4 Render(vec2 P)
{
    mat4 ProjectMatrix = MakeOrthographic(- 5., 5., 5., -5., .1, 1000.);
    mat4 ViewMatrix = MakeCameraMatrix(vec3(2.,2., 2.), vec3(0.));
    
    vec4 Col = vec4(0.);

    CreateCube();
    CreatePlane();
    float Depth = 99999999.;
    for(int i = 0; i < INDICES_COUNT; i += 3)
    {
        vec3 D;
        SVertex3D V1 = GVectices[GIndices[i]], V2 = GVectices[GIndices[i+1]], V3 = GVectices[GIndices[i+2]];
        mat4 MVP = ProjectMatrix * ViewMatrix;
        SVertex3D VV1, VV2, VV3;
        VertexFromWorldToNDCSpace(MVP, V1, VV1);
        VertexFromWorldToNDCSpace(MVP, V2, VV2);
        VertexFromWorldToNDCSpace(MVP, V3, VV3);
        bool bRenderVV1 = VV1.Position.z <= 1. && VV1.Position.z >= -1.;
        bool bRenderVV2 = VV2.Position.z <= 1. && VV2.Position.z >= -1.;
        bool bRenderVV3 = VV3.Position.z <= 1. && VV3.Position.z >= -1.;
        //if(!bRenderVV1 && !bRenderVV2 && !bRenderVV3) continue;
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
            float CDepth = AlphaBetaGamma.x * VV1.Position.z
                + AlphaBetaGamma.y * VV2.Position.z
                + AlphaBetaGamma.z * VV3.Position.z;
            
            if(CDepth >= Depth) continue;
            Depth = CDepth;

            vec3 C = AlphaBetaGamma.x * V1.Color 
                + AlphaBetaGamma.y * V2.Color 
                + AlphaBetaGamma.z * V3.Color;

            Col.rgb = C; Col.a = 1.;
        }
    }

    return Col; 
}

void mainImage(out vec4 fragColor, in vec2 fragCrood)
{
    vec2 UV = FixUV(fragCrood);

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

    vec3 GridColor = Grid(UV, 5);
    
    vec3 Color = mix(GridColor, Col.rgb, Col.a);

    fragColor = vec4(Color, 1.0);
}