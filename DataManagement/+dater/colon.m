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
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function output = colon(from, varargin)

if nargin==2
    to = varargin{1};
    step = 1;
else
    [step, to] = varargin{:};
end
from = double(from);
to = double(to);

output = ( round(100*from) : 100*step : round(100*to) )/100;

end%


