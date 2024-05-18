-- https://love2d.org/forums/viewtopic.php?t=1856
function math.clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.lerp(val, pos, perc)
    return (1 - perc) * val + perc * pos
end

function math.round(val)
    return math.floor(val + 0.5)
end