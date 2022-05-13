#define NUMBER 3.
#define PI 3.14156

vec2 FixUv(vec2 coord)
{
    return NUMBER * (2. * coord - iResolution.xy) / min(iResolution.x, iResolution.y);
}

vec3 Grid(vec2 uv)
{
    vec3 col = vec3(0.4);

    vec2 cell = floor(mod(uv, 2.));

    if(cell.x == cell.y) col = vec3(0.6);

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


float Function(float x)
{
    float t = 3. + sin(iTime) * 2.;
    return sin(2. * PI / t * x);
}

float DrawFunction(vec2 uv, float w)
{
    float y = Function(uv.x);
    return smoothstep(y - w, y + w, uv.y);
}

#define AA 4
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // -1 ~ 1
    vec2 uv = FixUv(fragCoord);

    vec3 gridColor = Grid(uv);

    float count = 0.;
    for(int u = 0; u < AA; u ++)
    {
        for(int v = 0; v < AA; v++)
        {
            // transform -1 ~ 1
            vec2 offset = (vec2(float(u), float(v)) - .5 * float(AA)) / float(AA) * 2.;
            count += DrawFunction(FixUv(fragCoord + offset), fwidth(uv.x));
        }
    }

    if(count > float(AA * AA) / 2.)
    {
        count = float(AA * AA) - count;
    }

    // normalization
    count = count * 2. / float(AA * AA);

    vec3 col = mix(gridColor, vec3(1., 1., 0.), count);
    //col = vec3(count);
    fragColor = vec4(col, 1.0);
}