function d = reporting(this, inp, range, varargin)
% reporting  Evaluate reporting equations from within model object.
%
% Syntax
% =======
%
%     D = reporting(M,D,Range,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object with reporting equations.
%
% * `D` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Range` [ numeric | char ] - Date range on which the reporting
% equations will be evaluated.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with reporting variables.
%
%
% Options
% ========
%
% See [`rpteq/run`](rpteq/run) for options available.
%
%
% Description
% ============
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

d = run(this.Reporting, inp, range, this, varargin{:});

end%

