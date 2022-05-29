% dater.colon  Create vector of dates
%{
% Syntax
%--------------------------------------------------------------------------
%
%     output = dater.colon(from, to)
%     output = dater.colon(from, step, to)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    Description
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __``__ [ ]
%
%>    Description
%
%
% Options
%--------------------------------------------------------------------------
%
%
% __`=`__ [ | ]
%
%>    Description
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function output = colon(from, varargin)

if nargin==2
    to = varargin{1};
    step = 1;
else
    [step, to] = varargin{:};
end
from = double(from);
to = double(to);
step = double(step);

if isequal(from, -Inf) || isequal(to, Inf)
    output = [from, to];
else
    output = (round(100*from) : round(100*step) : round(100*to)) / 100;
end

end%

