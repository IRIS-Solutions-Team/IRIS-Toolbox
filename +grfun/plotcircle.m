function H = plotcircle(x,y,radius,varargin)
% plotcircle  Draw a circle or disc.
%
% Syntax
% =======
%
%     H = grfun.plotcircle(X,Y,RAD,...)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - X-axis location of the centre of the circle.
%
% * `Y` [ numeric ] - Y-axis location of the centre of the circle.
%
% * `RAD` [ numeric ] - Radius of the circle.
%
% Output arguments
% =================
%
% * `H` [ numeric] - Handle to the line or the filled area.
%
% Options
% ========
%
% * `'fill='` [ `true` | *`false`* ] - Switch between a circle (`'fill='
% false`) and a disc (`'fill=' true`).
%
% Any property name-value pair valid for line graphs.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.


defaults = { 
    'fill', false, @(x) isequal(x, true) || isequal(x, false)
};

[opt,varargin] = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

n = 128;
th = 2*pi*(0:n)/n;

if opt.fill
    % Display disc.
    H = fill(x+radius*cos(th),y+radius*sin(th),[0,0,1],varargin{:});
else
    % Display circle.
    H = plot(x+radius*cos(th),y+radius*sin(th),varargin{:});
end

end
