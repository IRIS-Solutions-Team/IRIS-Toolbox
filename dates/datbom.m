function dateCode = datbom(dateCode)
% datbom  Beginning of month for the specified daily or monthly date
%
% Syntax
% =======
%
%     bom = datbom(dateCode)
%
%
% Input arguments
% ================
%
% * `dateCode` [ numeric ] - Daily or monthly date.
%
%
% Output arguments
% =================
%
% * `bom` [ numeric ] - Daily date for the first day of the same month as
% `dateCode`.
%
%
% Description
%============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

dateCode = datxom(dateCode, 'beginning');

end%

