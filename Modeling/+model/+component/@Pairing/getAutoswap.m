function [namesOfExogenized, namesOfEndogenized, autoswap] = getAutoswap(p, quantity)
% getAutoswap  Get autoexogenized parameter-variable or shock-parameter pairs
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

PTR = @int16;

%--------------------------------------------------------------------------

inxOfExogenized = p>PTR(0);
posOfEndogenized = p(inxOfExogenized);
namesOfExogenized = quantity.Name(inxOfExogenized);
namesOfEndogenized = quantity.Name(posOfEndogenized);

if nargout<3
    return
end

autoswap = struct( );
namesOfExogenized = namesOfExogenized(:).';
namesOfEndogenized = namesOfEndogenized(:).';
if ~isempty(namesOfExogenized)
    autoswap = cell2struct(namesOfEndogenized, namesOfExogenized, 2);
end

end%

