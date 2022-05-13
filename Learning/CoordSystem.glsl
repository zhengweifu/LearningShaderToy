vec3 Grid(vec2 uv, int num)
{
    vec3 col = vec3(0.0);

    vec2 aUv = float(num) * uv;
    vec2 cell = fract(aUv);

    if(cell.y < fwidth(aUv.y) || cell.x < fwidth(aUv.x))
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


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // 0 ~ 1
    vec2 uv = fragCoord / iResolution.xy;

    // -1 ~ 1
    vec2 uv2 = (2.*uv - 1.0) * iResolution.xy / min(iResolution.x, iResolution.y);

    fragColor = vec4(Grid(uv2, 5), 1.0);
}