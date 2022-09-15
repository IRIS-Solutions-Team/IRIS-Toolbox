% dater.eq  Compare IrisT datesk
%{
% Syntax
%--------------------------------------------------------------------------
%
%     output = dater.eq(lhs, rhs)
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

function output = eq(lhs, rhs)

lhs = double(lhs);
rhs = double(rhs);
output = round(100*lhs)==round(100*rhs) | (isinf(lhs) & isinf(rhs) & sign(lhs)==sign(rhs));

end%


