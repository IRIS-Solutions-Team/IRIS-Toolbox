function Dates = find(X,Func)
% find  Find dates at which tseries observations are non-zero or true.
%
% Syntax
% =======
%
%     Dates = find(X)
%     Dates = find(X,Func)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `Func` [ @all | @any ] - Controls whether the output `Dates` will
% contain periods where all observations are non-zero, or where at least
% one observation is non-zero. If not specified, `@all` is
% assumed.
%
% Output arguments
% =================
%
% * `Dates` [ numeric | cell ] - Vector of dates at which all or any
% (depending on `Func`) of the observations are non-zero.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

try
    Func; %#ok<VUNUS>
catch
    Func = @all;
end

pp = inputParser( );
pp.addRequired('X',@(x) isa(x,'tseries'));
pp.addRequired('Func',@(x) isequal(x,@all) || isequal(x,@any));
pp.parse(X,Func);

%--------------------------------------------------------------------------

ix = Func(X.data(:,:),2);
Dates = X.start + find(ix) - 1;

end