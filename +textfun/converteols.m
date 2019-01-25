function x = converteols(x)
% converteols  [Not a public function] Convert Win and Mac EOLs to \n.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

% `strrep(...)` is much faster than `regexp(...)` here.
% Windows:
x = strrep(x,sprintf('\r\n'),sprintf('\n'));
% Apple:
x = strrep(x,sprintf('\r'),sprintf('\n'));

end
