function [d, cc, ff, u, e] = forecast(this, inp, range, j, varargin)
% forecast  Forecast FAVAR factors and observables.
%
% __Syntax__
%
%     [D, CC, F, U, E] = forecast(A, Inp, Range, J, ...)
%
%
% __Input arguments__
%
% * `A` [ FAVAR ] - Estimated FAVAR object.
%
% * `Inp` [ struct | cell | Series | tseries ] - Input data with initial
% condition for the FAVAR factors.
%
% * `Range` [ numeric ] - Forecast range.
%
% * `J` [ struct | Series | tseries] - Conditioning data with hard tunes on the
% FAVAR observables.
%
%
% __Output arguments__
%
% * `D` [ struct ] - Output database or tseries object with the FAVAR
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
% See help on [`FAVAR/filter`](FAVAR/filter) for options available.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TEMPLATE_SERIES = TIME_SERIES_CONSTRUCTOR( );

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('a', @(x) isa(x, 'FAVAR'));
pp.addRequired('inp', @(x) isa(x, 'tseries') || isstruct(x));
pp.addRequired('range', @isnumeric);
pp.addRequired('j', @(x) isempty(x) || isa(x, 'tseries') || isstruct(x));
pp.parse(this, inp, range, j);

% Parse options.
opt = passvalopt('FAVAR.forecast', varargin{:});

%--------------------------------------------------------------------------

ny = size(this.C, 1);
nx = size(this.C, 2);
pp = size(this.A, 2)/nx;
range = range(1) : range(end);

if isstruct(inp) ...
      && ~isfield(inp, 'init') ...
      && isfield(inp, 'mean') ...
      && isa(inp.mean, 'tseries')
   inp = inp.mean;
end

if isa(inp, 'tseries')
   % Only mean tseries supplied; no uncertainty in initial condition.
   reqRange = range(1)-pp : range(1)-1;
   req = datarequest('y*', this, inp, reqRange);
   x0 = req.Y(:, end:-1:1, :, :);
   x0 = x0(:);
   P0 = 0;
else
   % Complete description of initial conditions.
   ix = abs(range(1)-1 - inp.init{3}) <= 0.01;
   if isempty(ix) || ~any(ix)
      % Initial condition not available.
      utils.error('FAVAR', ...
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
   [this, y] = standardise(this, y);
else
   y = nan(ny, nPer, nData);
   outpFmt = opt.output;
   if strcmpi(outpFmt, 'auto')
   end   
end

Sgm = this.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.cross = double(opt.cross);
if opt.cross<1
   ix = logical(eye(size(Sgm)));
   Sgm(~ix) = opt.cross*Sgm(~ix);
end

if isequal(opt.invfunc, 'auto')
   if this.Cross==1 && opt.cross==1
      invFunc = @pinv;
   else
      invFunc = @inv;
   end
else
   invFunc = opt.invfunc;
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
s.allObs = this.Cross==1 && opt.cross==1;
s.tol = opt.tolerance;
s.reuse = opt.persist;
s.ahead = 1;

[x, Px, e, u, y, Py, ixy] = timedom.varsmoother( ...
   this.A, this.B, [ ], this.C, [ ], 1, Sgm, y, [ ], x0, P0, s);

if opt.meanonly
   Px = Px(:, :, [ ], [ ]);
   Py = [ ];
end

[y, Py] = FAVAR.destandardise(this.Mean, this.Std, y, Py);

yNames = get(this, 'YNames');
d = myoutpdata(this, range, y, Py, yNames);

if nargout>1
   % Common components.
   [cc, Pc] = FAVAR.cc(this.C, x(1:nx, :, :), Px(1:nx, 1:nx, :, :));
   [cc, Pc] = FAVAR.destandardise(this.Mean, this.Std, cc, Pc);
   cc = myoutpdata(this, range, cc, Pc, yNames);   
end

if nargout>2
    ff = outputFactorData(this, x, Px, range, ixy, opt);
end

if nargout>3
   u = FAVAR.destandardise(0, this.Std, u);
   u = myoutpdata(this, range, u, NaN, yNames);
end

if nargout>5
   e = replace(TEMPLATE_SERIES, permute(e, [2, 1, 3]), range(1));
   if ~opt.meanonly
   e = struct( ...
      'mean', e, ...
      'std', replace(TEMPLATE_SERIES, zeros(0, size(e, 1), size(e, 3)), range(1)) ...
      );
   end
end

end
