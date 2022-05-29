function varargout = dbcol(this, varargin)
% dbcol  Retrieve the specified column or columns from database entries.
%
% __Syntax__
%
%     D = dbpage(D, K)
%
%
% __Input Arguments__
%
% * `D` [ struct ] - Input database with (possibly) multivariate tseries
% objects and numeric arrays.
%
% * `K` [ numeric | logical | `'end'` ] - Column or columns that will be
% retrieved from each tseries object or numeric array in in the input
% database, `D`, and returned in the output database.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Output database with tseries objects and numeric
% arrays reduced to the specified column.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = dbdimretrieve(this, 2, varargin{:});

end%

