function eqtn = myeqtn2symb(eqtn)
% mysymb2eqtn  Replace references to a variable array with sydney representation of variables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Replace x(10,t) with x10.
eqtn = regexprep(eqtn, '\<([xL])\((\d+),t\)', '$1$2');

% Replace x(10,t+0) with x10.
eqtn = regexprep(eqtn, '\<([xL])\((\d+),t\+0\)', '$1$2');

% Replace x(10,t+1) with x10p1.
eqtn = regexprep(eqtn, '\<([xL])\((\d+),t\+(\d+)\)', '$1$2p$3');

% Replace x(10,t-1) with x10m1.
eqtn = regexprep(eqtn, '\<([xL])\((\d+),t-(\d+)\)', '$1$2m$3');

% Replace g(10,:) with g10.
eqtn = regexprep(eqtn, '\<g\((\d+),:\)', 'g$1');

end
