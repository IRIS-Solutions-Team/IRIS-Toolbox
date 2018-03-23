function len = rnglen(r)

if isnan(r(1)) && isnan(r(end))
    len = 0;
    return
end

len = round(r(end) - r(1) + 1);

end
