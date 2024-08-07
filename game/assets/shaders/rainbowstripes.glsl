#pragma language glsl3
extern vec2 resolution;
extern float time;
extern sampler2D paletteTexture;
extern vec2 paletteResolution;
extern int paletteIndex;

vec4 colourFromGreyscale(float colour)
{
    colour = clamp(0, 1, colour);
    float sizeY = paletteResolution.y;
    float uvX = 1.0 / paletteResolution.x;
    float halfTexel = uvX * 0.5;
    float minColour = (uvX * 2.0) + halfTexel;
    float maxColour = (uvX * 6.0) + halfTexel;
    float clampedX = mix(minColour, maxColour, colour);

    return texture(paletteTexture, vec2(clampedX, (float(paletteIndex) - 0.5) / sizeY));
}

vec4 effect(vec4 screenColour, Image texture, vec2 texCoord, vec2 screenCoord)
{
    vec2 center = vec2(resolution.x, resolution.y) / (8.0 + (time * 2));
    vec2 pos = screenCoord / center;
    
    float radius = length(pos);
    float angle = atan(pos.y, pos.x);
    
    vec2 uv = vec2(radius, angle);
    vec3 col = 0.5 + 0.5*cos(time+uv.xyy+vec3(0,2,4));
    
    float intensity = dot(col.xyz, vec3(0.3, 0.3, 0.3));
    float levels = 128;
    float quantized = floor(intensity * levels) / levels;
    
    col = col * quantized * 5.0;
    float gray = dot(col, vec3(0.3, 0.3, 0.3));

    return colourFromGreyscale(gray);
}