extern number angle;
extern number warpScale;
extern number warpTiling;
extern number tiling;
extern vec2 position;
extern vec2 resolution;

vec4 effect(vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    const float PI = 3.14159;
    
    vec2 uv = (screenCoords - position) / resolution;
    
    vec2 pos = vec2(0, 0);
    pos.x = mix(uv.x, uv.y, angle);
    pos.y = mix(uv.y, 1.0 - uv.x, angle);
    pos.x += sin(pos.y * warpTiling * PI * 2.0) * warpScale;
    pos.x *= tiling;

    vec3 col1 = vec3(0.1, 0.1, 0.1);
    vec3 col2 = vec3(0.13, 0.13, 0.13);
    
    float val = floor(fract(pos.x) + 0.5);
    vec4 fragColour = vec4(mix(col1, col2, val), 1);

    return fragColour;
}