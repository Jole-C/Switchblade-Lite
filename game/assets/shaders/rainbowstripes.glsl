extern vec2 resolution;
extern float time;
extern vec3 colour;
vec4 effect(vec4 screenColour, Image texture, vec2 texCoord, vec2 screenCoord)
{
    vec2 center = vec2(resolution.x, resolution.y) / 2.0;
    vec2 pos = screenCoord / center;
    
    float radius = length(pos);
    float angle = atan(pos.y, pos.x);
    
    vec2 uv = vec2(radius, angle);
    vec3 col = 0.5 + 0.5*cos(time+uv.xyy+vec3(0,2,4));
    
    float intensity = dot(col.xyz, vec3(0.3, 0.3, 0.3));
    float levels = 32.0;
    float quantized = floor(intensity * levels) / levels;
    
    col = col * quantized * 5.0;
    
    float gray = dot(col, vec3(0.3, 0.3, 0.3)) * 1.5;
    
    return vec4(colour * gray, 1.0);
}