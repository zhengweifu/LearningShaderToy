// reference https://www.shadertoy.com/view/XdlGzn

#iChannel0 "../../Assets/Textures/Abstract1.jpg"

struct SVertex2D
{
    vec2 Position;
    vec3 Color;
    vec2 UV;
};

vec2 FixUV(in vec2 fragCrood)
{
    return (2. * fragCrood - iResolution.xy) / min(iResolution.x, iResolution.y);
}

// > 0 B is the left of A
// = 0 B and A coincide
// < 0 B is the right of A
float Cross2d(vec2 A, vec2 B)
{
    return A.x * B.y - A.y * B.x;
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

SVertex2D Points[4];
int Indice[6];
void CreateQuad()
{
    Points[0].Position = vec2(-.5, -.5);
    Points[0].Color = vec3(1., 0., 0.);
    Points[0].UV = vec2(0., 0.);
    
    Points[1].Position = vec2(.5, -.5);
    Points[1].Color = vec3(0., 1., 0.);
    Points[1].UV = vec2(1., 0.);

    Points[2].Position = vec2(.5, .5);
    Points[2].Color = vec3(0., 0., 1.);
    Points[2].UV = vec2(1., 1.);

    Points[3].Position = vec2(-.5, .5);
    Points[3].Color = vec3(1., 0., 1.);
    Points[3].UV = vec2(0., 1.);
    
    Indice[0] = 0; Indice[1] = 1; Indice[2] = 2;
    Indice[3] = 0; Indice[4] = 2; Indice[5] = 3;
}

vec3 Render(vec2 P)
{
    vec3 Col = vec3(0.);

    CreateQuad();
    for(int i = 0; i < 6; i += 3)
    {
        vec3 D;
        SVertex2D V1 = Points[Indice[i]], V2 = Points[Indice[i+1]], V3 = Points[Indice[i+2]];
        bool bInside = InsideTriangle(P, V1.Position, V2.Position, V3.Position, D);
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
            vec3 C = AlphaBetaGamma.x * V1.Color 
                + AlphaBetaGamma.y * V2.Color 
                + AlphaBetaGamma.z * V3.Color;
            vec2 UV = AlphaBetaGamma.x * V1.UV 
                    + AlphaBetaGamma.y * V2.UV 
                    + AlphaBetaGamma.z * V3.UV;

            Col = texture(iChannel0, UV).xyz * C;
        }
    }

    return Col; 
}

void mainImage(out vec4 fragColor, in vec2 fragCrood)
{
    vec2 UV = FixUV(fragCrood);

    vec3 Col = Render(UV);

    fragColor = vec4(Col, 1.0);
}