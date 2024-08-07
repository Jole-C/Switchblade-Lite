#pragma language glsl3
extern vec2 resolution;
extern float time;
extern sampler2D paletteTexture;
extern vec2 paletteResolution;
extern int paletteIndex;

float luma(vec3 color) {
  return dot(color, vec3(0.299, 0.587, 0.114));
}

float luma(vec4 color) {
  return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}
float dither4x4(vec2 position, float brightness) {
  int x = int(mod(position.x, 4.0));
  int y = int(mod(position.y, 4.0));
  int index = x + y * 4;
  float limit = 0.0;

  if (x < 8) {
    if (index == 0) limit = 0.0625;
    if (index == 1) limit = 0.5625;
    if (index == 2) limit = 0.1875;
    if (index == 3) limit = 0.6875;
    if (index == 4) limit = 0.8125;
    if (index == 5) limit = 0.3125;
    if (index == 6) limit = 0.9375;
    if (index == 7) limit = 0.4375;
    if (index == 8) limit = 0.25;
    if (index == 9) limit = 0.75;
    if (index == 10) limit = 0.125;
    if (index == 11) limit = 0.625;
    if (index == 12) limit = 1.0;
    if (index == 13) limit = 0.5;
    if (index == 14) limit = 0.875;
    if (index == 15) limit = 0.375;
  }

  return brightness < limit ? 0.0 : 1.0;
}

vec3 dither4x4(vec2 position, vec3 color) {
  return color * dither4x4(position, luma(color));
}

vec4 dither4x4(vec2 position, vec4 color) {
  return vec4(color.rgb * dither4x4(position, luma(color)), 1.0);
}

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
    col = dither4x4(screenCoord, col);
    
    float gray = dot(col, vec3(0.3, 0.3, 0.3));

    return colourFromGreyscale(gray);
}