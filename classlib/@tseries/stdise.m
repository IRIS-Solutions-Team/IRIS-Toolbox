function [This,XMean,XStd] = stdise(This,Flag)
% stdise  Standardise tseries data by subtracting mean and dividing by std deviation.
%
% Syntax
% =======
%
%     [X,M,S] = stdise(X)
%     [X,M,S] = stdise(X,Flag)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose data will be normalised.
%
% * `Flag` [ 0 | 1 ] - `flag==0` normalises by N-1, `flag==1`
% normalises by `N`, where `N` is the sample length.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with standardised data.
%
% * `XMeam` [ numeric ] - Estimated mean subtracted from the input tseries
% observations.
%
% * `XStd` [ numeric ] - Estimated std deviation by which the input tseries
% observations have been divided.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if nargin < 2
   Flag = 0;
end

pp = inputParser( );
pp.addRequired('Flag',@(x) isequal(x,0) || isequal(x,1) );
pp.parse(Flag);

%--------------------------------------------------------------------------

[This.data,XMean,XStd] = tseries.mystdize(This.data,Flag);

end
