function [lsExog, lsEndog, a] = getAutoexog(p, quantity)
% getAutoexog  Get autoexogenized parameter-variable or shock-parameter pairs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

PTR = @int16;

%--------------------------------------------------------------------------

ixExog = p>PTR(0);
posEndog = p(ixExog);
lsExog = quantity.Name(ixExog);
lsEndog = quantity.Name(posEndog);

if nargout<3
    return
end

a = struct( );
lsExog = lsExog(:).';
lsEndog = lsEndog(:).';
if ~isempty(lsExog)
    a = cell2struct(lsEndog, lsExog, 2);
end

end
