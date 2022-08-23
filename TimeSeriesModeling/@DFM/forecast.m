function [d, cc, ff, u, e] = forecast(this, inp, range, varargin)
% forecast  Forecast DFM factors and observables
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     [D, CC, F, U, E] = forecast(A, Inp, Range, ~J, ...)
%
%
% __Input arguments__
%
% * `A` [ DFM ] - Estimated DFM object.
%
% * `Inp` [ struct | cell | Series | tseries ] - Input data with initial
% condition for the DFM factors.
%
% * `Range` [ numeric ] - Forecast range.
%
% * `~J` [ struct | Series | tseries] - Conditioning data with hard tunes
% on the DFM observables.
%
%
% __Output arguments__
%
% * `D` [ struct ] - Output database or tseries object with the DFM
% observables.
%
% * `CC` [ Series | tseries ] - Projection of common components in the
% observables.
%
% * `F` [ Series | tseries ] - Projection of common factors.
%
% * `U` [ Series | tseries ] - Conditional idiosyncratic residuals.
%
% * `E` [ Series | tseries ] - Conditional structural residuals.
%
%
% __Options__
%
% See help on [`DFM/filter`](DFM/filter) for options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

TEMPLATE_SERIES = Series();

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('DFM.forecast');
    inputParser.addRequired('a', @(x) isa(x, 'DFM'));
    inputParser.addRequired('InputData', @validate.databank);
    inputParser.addRequired('Range', @isnumeric);
    inputParser.addRequired('Condition', @(x) isempty(x) || isa(x, 'Series') || isstruct(x));
    inputParser.addParameter('Cross', true, ...
        @(x) isequal(x, true) || isequal(x, false) || (isnumeric(x) && isscalar(x) && x>=0 && x<=1));
    inputParser.addParameter('InvFunc', 'auto', @(x) all(strcmpi(x, 'auto')) || isa(x, 'function_handle'));
    inputParser.addParameter('MeanOnly', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Persist', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Tolerance', 0, @(x) isnumeric(x) && isscalar(x));
end
inputParser.parse(this, inp, range, varargin{:});
j = inputParser.Results.Condition;
opt = inputParser.Options;

%--------------------------------------------------------------------------

ny = size(this.C, 1);
nx = size(this.C, 2);
pp = size(this.A, 2)/nx;
range = range(1) : range(end);
range = double(range);

if isstruct(inp) ...
      && ~isfield(inp, 'init') ...
      && isfield(inp, 'mean') ...
      && isa(inp.mean, 'Series')
   inp = inp.mean;
end

if isa(inp, 'Series')
   % Only mean tseries supplied; no uncertainty in initial condition.
   reqRange = range(1)-pp : range(1)-1;
   req = datarequest('y*', this, inp, reqRange);
   x0 = req.Y(:, end:-1:1, :, :);
   x0 = x0(:);
   P0 = 0;
else
   % Complete description of initial conditions.
   ix = abs((range(1)-1) - inp.init{3}) <= 0.01;
   if isempty(ix) || ~any(ix)
      % Initial condition not available
      utils.error('DFM', ...
         'Initial condition for factors not available from input data.');
   end
   x0 = inp.init{1}(:, ix, :, :);
   P0 = inp.init{2}(:, :, ix, :, :);
end
nPer = length(range);
nData = size(x0, 3);

if ~isempty(j)
   if isstruct(j) && isfield(j, 'mean')
      j = j.mean;
   end
   req = datarequest('y*', this, j, range);
   range = req.Range;
   y = req.Y;
   [this, y] = stdize(this, y);
else
   y = nan(ny, nPer, nData);
end

Sgm = this.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.Cross = double(opt.Cross);
if opt.Cross<1
   ix = logical(eye(size(Sgm)));
   Sgm(~ix) = opt.Cross*Sgm(~ix);
end

if all(strcmpi(opt.InvFunc, 'auto'))
   if this.Cross==1 && opt.Cross==1
      invFunc = @pinv;
   else
      invFunc = @inv;
   end
else
   invFunc = opt.InvFunc;
end

% Run VAR Kalman smoother
%-------------------------
% Run Kalman smoother to re-estimate the common factors taking the
% coefficient matrices as given. If `allobserved` is true then the VAR
% smoother makes an assumption that the factors are uniquely determined
% whenever all observables are available; this is only true if the
% idiosyncratic covariance matrix is not scaled down.

s = struct( );
s.invFunc = invFunc;
s.allObs = this.Cross==1 && opt.Cross==1;
s.tol = opt.Tolerance;
s.reuse = opt.Persist;
s.ahead = 1;

[x, Px, e, u, y, Py, ixy] = iris.mixin.Kalman.smootherForVAR( ...
   this, this.A, this.B, [ ], this.C, [ ], 1, Sgm, y, [ ], x0, P0, s ...
);

if opt.MeanOnly
   Px = Px(:, :, [ ], [ ]);
   Py = [ ];
end

[y, Py] = DFM.destdize(y, this.Mean, this.Std, Py);

endogenousNames = this.EndogenousNames;
d = myoutpdata(this, range, y, Py, endogenousNames);

if nargout>1
   % Common components.
   [cc, Pc] = DFM.cc(this.C, x(1:nx, :, :), Px(1:nx, 1:nx, :, :));
   [cc, Pc] = DFM.destdize(cc, this.Mean, this.Std, Pc);
   cc = myoutpdata(this, range, cc, Pc, endogenousNames);   
end

if nargout>2
    ff = outputFactorData(this, x, Px, range, ixy, opt);
end

if nargout>3
   u = DFM.destdize(u, 0, this.Std);
   u = myoutpdata(this, range, u, NaN, endogenousNames);
end

if nargout>5
   e = replace(TEMPLATE_SERIES, permute(e, [2, 1, 3]), range(1));
   if ~opt.MeanOnly
   e = struct( ...
      'mean', e, ...
      'std', replace(TEMPLATE_SERIES, zeros(0, size(e, 1), size(e, 3)), range(1)) ...
      );
   end
end

end
