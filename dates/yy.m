function outputDate = yy(year, varargin)
% yy  IrisT yearly date
%
% Syntax
% =======
%
%     d = yy(year)
%
%
% Input arguments
% ================
%
% * `year` [ numeric ] - Calendar year.
%
%
% Output arguments
% =================
%
% * `d` [ dates.date ] - IRIS serial date numbers.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

outputDate = DateWrapper(dater.yy(year, varargin{:}));

end%

