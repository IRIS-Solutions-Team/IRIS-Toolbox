function x = horzcat(varargin)
% horzcat  Horizontal concatenation of tseries objects.
%
% Syntax
% =======
%
%     Z = horzcat(X1,X2,...)
%     Z = [X1,X2,...]
%
% Input arguments
% ================
%
% * `XX1` [ tseries ] - Tseries object that will be concatenated column by
% column with other input tseries objects or numeric scalars.
%
% * `X2` [ tseries ] - Tseries object that will be concatenated column by
% column with other input tseries objects or numeric scalars.
%
% Output arguments
% =================
%
% * `Z` [ tseries ] - Tseries object created by concatenating the columns
% of the input tseries objects, `X1`, `X2`, etc.
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

x = cat(2, varargin{:});

end%

