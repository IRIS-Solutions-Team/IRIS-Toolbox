% getAutoswap  Get autoexogenized parameter-variable or shock-parameter pairs
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [namesExogenized, namesEndogenized, autoswaps] = getAutoswaps(p, quantity)

PTR = @int16;

inxExogenized = p>PTR(0);
posEndogenized = p(inxExogenized);
namesExogenized = quantity.Name(inxExogenized);
namesEndogenized = quantity.Name(posEndogenized);

if nargout<3
    return
end

autoswaps = struct( );
namesExogenized = reshape(namesExogenized, 1, []);
namesEndogenized = reshape(namesEndogenized, 1, []);
if ~isempty(namesExogenized)
    autoswaps = cell2struct(namesEndogenized, namesExogenized, 2);
end

end%

