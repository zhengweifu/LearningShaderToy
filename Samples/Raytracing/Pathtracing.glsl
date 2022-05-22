//#include "../Common/Camera.glsl"
//#include "Global.glsl"
#include "Intersection.glsl"

struct SCamera
{
    vec3 Up;
    vec3 Position;
    vec3 Target;
    float Fov;
};

void MakeScene()
{
    
}

int FlatIdx;
int Seed;
void EncryptTea(inout uvec2 Arg)
{
	uvec4 Key = uvec4(0xa341316c, 0xc8013ea4, 0xad90777d, 0x7e95761e);
	uint V0 = Arg[0], V1 = Arg[1];
	uint Sum = 0u;
	uint Delta = 0x9e3779b9u;

	for(int Index = 0; Index < 32; Index++) {
		Sum += Delta;
		V0 += ((V1 << 4) + Key[0]) ^ (V1 + Sum) ^ ((V1 >> 5) + Key[1]);
		V1 += ((V0 << 4) + Key[2]) ^ (V0 + Sum) ^ ((V0 >> 5) + Key[3]);
	}
	Arg[0] = V0;
	Arg[1] = V1;
}

vec2 GetRandom()
{
  	uvec2 Arg = uvec2(FlatIdx, Seed++);
  	EncryptTea(Arg);
  	return fract(vec2(Arg) / vec2(0xffffffffu));
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    Seed = 0;
	FlatIdx = int(dot(fragCoord.xy, vec2(1, 4096)));
    vec2 UV = (2. * fragCoord - iResolution.xy) / min(iResolution.x, iResolution.y);
	vec3 CameraPosition = vec3(0., 0., 1.);
    SRay Ray;
    Ray.Origin = CameraPosition;
    vec2 Random = GetRandom();
    Ray.Direction = normalize(vec3(UV + Random.x * dFdx(UV) + Random.y * dFdy(UV), -1));

    //Ray.Direction = normalize(vec3(UV, -1));

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