function varargout = dbcol(This,varargin)
% dbcol  Retrieve the specified column or columns from database entries.
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
% * `K` [ numeric | logical | `'end'` ] - Column or columns that will be
% retrieved from each tseries object or numeric array in in the input
% database, `D`, and returned in the output database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with tseries objects and numeric
% arrays reduced to the specified column.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = dbdimretrieve(This,2,varargin{:});

end
