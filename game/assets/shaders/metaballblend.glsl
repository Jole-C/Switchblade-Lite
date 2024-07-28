vec4 effect( vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    vec4 col = Texel(texture, texCoords);
    vec4 a = mix(colour, col, 0.5);

    if(col.a > 0.5)
    {
        return a;
    }
    else
    {
        return col;
    }
}