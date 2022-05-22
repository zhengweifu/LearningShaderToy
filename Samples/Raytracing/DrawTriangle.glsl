
#include "Common/Intersection.glsl"


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 UV = (2. * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);
    SRay Ray;
    Ray.Origin = vec3(0., 0., 1.);;
    Ray.Direction = normalize(vec3(UV, -1));

    vec3 Triangle[3];
    Triangle[0] = vec3(-0.5, 0., -1.);
    Triangle[1] = vec3(.5, 0., -1.);
    Triangle[2] = vec3(0., 1., -1.);

    vec3 TriColors[3];
    TriColors[0] = vec3(1., 0., 0.);
    TriColors[1] = vec3(1., 1., 0.);
    TriColors[2] = vec3(1., 0., 1.);

    vec3 Col = vec3(0.);

    float T, U, V;
    if(TriangleIntersection(Triangle[0], Triangle[1], Triangle[2], Ray, T, U, V))
    {
        Col = TriColors[0] * (1. - U - V) + TriColors[1] * U + TriColors[2] * V;
    }

    fragColor = vec4(Col, 1.);
}