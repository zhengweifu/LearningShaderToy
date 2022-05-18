#include "../Common/Triangle.glsl"

void MakeCubeMesh(out SPoint[8] Points, out int[36] Indices, float Width, float Height, float Depth)
{
    float HWidth = Width * 0.5, HDepth = Depth * 0.5;
    Points[0].Position = vec3(-HWidth, 0., HDepth);
    Points[0].Color = vec3(1., 0., 0.);

    Points[1].Position = vec3(HWidth, 0., HDepth);
    Points[1].Color = vec3(0., 1., 0.);

    Points[2].Position = vec3(HWidth, Height, HDepth);
    Points[2].Color = vec3(0., 0., 1.);

    Points[3].Position = vec3(-HWidth, Height, HDepth);
    Points[3].Color = vec3(1., 0., 1.);

    Points[4].Position = vec3(-HWidth, 0., -HDepth);
    Points[4].Color = vec3(1., 0., 0.);

    Points[5].Position = vec3(HWidth, 0., -HDepth);
    Points[5].Color = vec3(0., 1., 0.);

    Points[6].Position = vec3(HWidth, Height, -HDepth);
    Points[6].Color = vec3(0., 0., 1.);

    Points[7].Position = vec3(-HWidth, Height, -HDepth);
    Points[7].Color = vec3(1., 0., 1.);

    // front
    Indices[0] = 0; Indices[1] = 1; Indices[2] = 2;
    Indices[3] = 0; Indices[4] = 2; Indices[5] = 3;

    // back
    Indices[6] = 4; Indices[7] = 6; Indices[8] = 5;
    Indices[9] = 4; Indices[10] = 7; Indices[11] = 6;

    // top
    Indices[12] = 2; Indices[13] = 6; Indices[14] = 7;
    Indices[15] = 2; Indices[16] = 7; Indices[17] = 3;

    // bottom
    Indices[18] = 0; Indices[19] = 4; Indices[20] = 5;
    Indices[21] = 0; Indices[22] = 5; Indices[23] = 1;

    // left
    Indices[24] = 0; Indices[25] = 3; Indices[26] = 7;
    Indices[27] = 0; Indices[28] = 7; Indices[29] = 4;

    // right
    Indices[30] = 1; Indices[31] = 5; Indices[32] = 6;
    Indices[33] = 1; Indices[34] = 6; Indices[35] = 2;
}

void MakePlaneMesh(out SPoint[4] Points, out int[6] Indices, float Width, float Height)
{
    Points[0].Position = vec3(-Width, 0., Height);
    Points[0].Color = vec3(1., 0., 0.);
    Points[0].UV = vec2(0.);

    Points[1].Position = vec3(Width, 0., Height);
    Points[1].Color = vec3(0., 1., 0.);
    Points[1].UV = vec2(1., 0.);

    Points[2].Position = vec3(Width, 0., -Height);
    Points[2].Color = vec3(0., 0., 1.);
    Points[2].UV = vec2(1.);

    Points[3].Position = vec3(-Width, 0., -Height);
    Points[3].Color = vec3(1.0, 0.0, 0.9843);
    Points[3].UV = vec2(0., 1.);

    Indices[0] = 0; Indices[1] = 1; Indices[2] = 2;
    Indices[3] = 0; Indices[4] = 2; Indices[5] = 3;
}