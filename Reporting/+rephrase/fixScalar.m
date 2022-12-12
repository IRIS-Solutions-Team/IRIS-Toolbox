
function x = fixScalar(x)

    if isscalar(x) && ~iscell(x)
        x = {x};
    end

end%
