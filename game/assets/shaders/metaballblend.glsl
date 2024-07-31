vec4 effect( vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    vec4 texColour = Texel(texture, texCoords);
    return texColour * colour;
}