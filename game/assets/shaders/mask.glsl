vec4 effect(vec4 colour, Image texture, vec2 texCoords, vec2 screenCoords)
{
    if (Texel(texture, texCoords).xyz == vec3(0.0))
    {
        discard;
    }

    return vec4(1.0);
}