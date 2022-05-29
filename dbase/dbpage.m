function varargout = dbpage(This,varargin)
% dbpage  Retrieve the specified page or pages from database entries.
%
% Syntax
% =======
%
%     D = dbpage(D,K)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with (possibly) multivariate tseries
% objects and numeric arrays.
%
% * `K` [ numeric | logical | `'end'` ] - Page or pages that will be
% retrieved from each tseries object or numeric array in in the input
% database, `D`, and returned in the output database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with tseries objects and numeric
% arrays reduced to the specified page.
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

[varargout{1:nargout}] = dbdimretrieve(This,3,varargin{:});

end
