function H = ucircle(varargin)
% ucircle  Plot a unit circle with equal axes.
%
% Syntax
% =======
%
%     H = ucircle(...)
%
% Output arguments
% =================
%
% * `H` [ numeric ] - Handle to the unit circle line.
%
% Options
% ========
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

%--------------------------------------------------------------------------

H = grfun.plotcircle(0,0,1,varargin{:});
label = cellstr(get(gca,'yTickLabel'));
label = regexprep(label,'\s*([\+-\.\d]+).*','$1 i');
set(gca,'yTickLabel',label,'yTickMode','manual');
axis('equal');

end
