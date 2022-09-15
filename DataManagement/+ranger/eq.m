% dater.eq  Compare IrisT date ranges
%{
% Syntax
%--------------------------------------------------------------------------
%
%     output = ranger.eq(lhs, rhs)
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
output = dater.eq(lhs(1), rhs(1)) && dater.eq(lhs(end), rhs(end));

end%


