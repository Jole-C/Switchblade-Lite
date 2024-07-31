extern vec4 drawColour = vec4(1, 0, 0, 1);

vec4 effect( vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    vec4 col = Texel(texture, texCoords);

    if (col.a > 0.5)
    {
        return col;
    }

    return vec4(0, 0, 0, 0);
}