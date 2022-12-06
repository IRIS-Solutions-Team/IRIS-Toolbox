
% getAutoswap  Get autoexogenized parameter-variable or shock-parameter pairs

function [namesExogenized, namesEndogenized, autoswaps] = getAutoswaps(p, quantity, namesFunc)

    PTR = @int16;

    inxExogenized = p>PTR(0);
    posEndogenized = p(inxExogenized);
    namesExogenized = quantity.Name(inxExogenized);
    namesEndogenized = quantity.Name(posEndogenized);

    if nargout<3
        return
    end

    autoswaps = struct();
    namesExogenized = reshape(namesExogenized, 1, []);
    namesEndogenized = reshape(namesEndogenized, 1, []);
    if ~isempty(namesExogenized)
        if nargin>=3
            namesEndogenized = cellfun(namesFunc, namesEndogenized, "uniformOutput", false);
        end
        autoswaps = cell2struct(cellstr(namesEndogenized), cellstr(namesExogenized), 2);
    end

end%

