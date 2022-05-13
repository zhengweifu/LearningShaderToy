#define NUMBER 3.
#define PI 3.14156

vec2 FixUv(vec2 coord)
{
    return NUMBER * (2. * coord - iResolution.xy) / min(iResolution.x, iResolution.y);
}

vec3 Grid(vec2 uv)
{
    vec3 col = vec3(0.0);

    vec2 cell = fract(uv);

    if(cell.y < fwidth(uv.y) || cell.x < fwidth(uv.x))
    {
        col = vec3(0.5);
    }

    if(abs(uv.y) < fwidth(uv.y))
    {
        col = vec3(1., 0., 0.);
    }

    if(abs(uv.x) < fwidth(uv.x))
    {
        col = vec3(0., 1., 0.);
    }

    return col;
}

// p is uv
float DrawLine(vec2 p, vec2 a, vec2 b, float w)
{
    float re = 0.;

    vec2 ab = b - a;
    vec2 ap = p - a;

    float proj = clamp(dot(ab, ap) / dot(ab, ab), 0., 1.);

    // if c is project point
    vec2 ac = ab * proj;
    float d = length(ac - ap);

    re = smoothstep(w, 0.95 * w, d);

    return re;
}

float Function(float x)
{
    float t = 3. + sin(iTime) * 2.;
    return sin(2. * PI / t * x);
}

float DrawFunction(vec2 uv, float w)
{
    float re = 0.;
    float step = 1.;
    for(float x = 0.; x < iResolution.x; x += step)
    {
        float fx = FixUv(vec2(x, 0.)).x;
        float fy = Function(fx);
        float nfx = FixUv(vec2(x + step, 0.)).x;
        float nfy = Function(nfx);
        re += DrawLine(uv, vec2(fx, fy), vec2(nfx, nfy), w);
    }
    re = clamp(re, 0., 1.);
    return re;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // -1 ~ 1
    vec2 uv = FixUv(fragCoord);

    vec3 gridColor = Grid(uv);

    //float a = DrawLine(uv, vec2(-1., -1.), vec2(1., 1.), fwidth(uv.y));
    float a = DrawFunction(uv, fwidth(uv.y));
    vec3 col = mix(gridColor, vec3(1., 1., 0.), a);

    fragColor = vec4(col, 1.0);
}