#include "./Macro.glsl"

mat3 IdentityMatrix3()
{
    return mat3(1., 0., 0.,
                0., 1., 0.,
                0., 0., 1.);
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
    vec3 Scale = vec3(2. / (Right - Left), 2. / (Top - Bottom), 2. / (Near - Far));
    vec3 Move = vec3(
        -(Right + Left) / (Right - Left), 
        -(Top + Bottom) / (Top - Bottom),
        -(Near + Far) / (Near - Far));
    
    return mat4(
        Scale.x, 0.,      0.,      0.,
        0.,      Scale.y, 0.,      0.,
        0.,      0.,      Scale.z, 0.,
        Move.x,  Move.y,  Move.z,  1.
    );
}

// reference https://www.bilibili.com/video/BV1X7411F744?p=4 about 51 minutes
// https://zhuanlan.zhihu.com/p/144329075
// https://zhuanlan.zhihu.com/p/144331875
mat4 MakePerspective(float Fov, float Aspect, float Near, float Far)
{
    float Top = Near * tan(Fov * PI / 360.);
    float Right = Aspect * Top;
    float Bottom = -Top;
    float Left = - Right;
    
    mat4 MPersp2Ortho = mat4(
        -Near, 0.,   0.,         0., // game101上面推导是Near,这取-Near是因为 w=z， 而z的一定是负数，后面做透视除法（x/w）后远处值被放大
        0.,   -Near, 0.,         0.,// game101上面推导是Near,这取-Near是因为 w=z， 而z的一定是负数，后面做透视除法（y/w）后远处值被放大
        0.,   0.,   Near + Far, 1.,
        0.,   0.,  -Far * Near, 0.
    );

    mat4 MOrtho = MakeOrthographic(Left, Right, Top, Bottom, Near, Far);

    return MOrtho * MPersp2Ortho;
}

vec3 UP = vec3(0., 1., 0.);

mat3 MakeCameraMatrix(vec3 Eye, vec3 Target)
{
    vec3 Z = normalize(Eye - Target),
        X = normalize(cross(UP, Z)),
        Y = cross(Z, X);
    
    return mat3(X, Y, Z);
}

mat4 MakeCameraInverseMatrix(vec3 Eye, vec3 Target)
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