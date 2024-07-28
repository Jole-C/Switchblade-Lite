vec4 effect( vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    vec4 col = Texel(texture, texCoords);

    if (col.a * colour.a == 0)
    {
        return col;
    }

    if (col.a > 0.5)
    {
        return vec4(1, 0, 0, 1);
    }
    else
    {
        return col;
    }
}