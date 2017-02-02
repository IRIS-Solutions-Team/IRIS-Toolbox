function [This,D,CC,F,U,E] = filter(This,Inp,Range,varargin)
% filter  Re-estimate the factors by Kalman filtering the data taking FAVAR coefficients as given.
%
% Syntax
% =======
%
%     [A,D,CC,F,U,E] = filter(A,D,Range,...)
%
% Input arguments
% ================
%
% * `A` [ FAVAR ] - Estimated FAVAR object.
%
% * `D` [ struct | tseries ] - Input database or tseries object with the
% FAVAR observables.
%
% * `Range` [ numeric ] - Filter date range.
%
% Output arguments
% =================
%
% * `A` [ FAVAR ] - FAVAR object.
%
% * `D` [ struct ] - Output database or tseries object with the FAVAR
% observables.
%
% * `CC` [ struct | tseries ] - Re-estimated common components in the
% observables.
%
% * `F` [ tseries ] - Re-estimated common factors.
%
% * `U` [ tseries ] - Re-estimated idiosyncratic residuals.
%
% * `E` [ tseries ] - Re-estimated structural residuals.
%
% Options
% ========
%
% * `'cross='` [ *`true`* | `false` | numeric ] - Run the filter with the
% off-diagonal elements in the covariance matrix of idiosyncratic
% residuals; if false all cross-covariances are reset to zero; if a number
% between zero and one, all cross-covariances are multiplied by that
% number.
%
% * `'invFunc='` [ *`'auto'`* | function_handle ] - Inversion method for
% the FMSE matrices.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return only mean data, i.e. point
% estimates.
%
% * `'persist='` [ `true` | *`false`* ] - If `filter` or `forecast` is used with
% `'persist='` set to true for the first time, the forecast MSE matrices and
% their inverses will be stored; subsequent calls of the `filter` or
% `forecast` functions will re-use these matrices until `filter` or
% `forecast` is called.
%
% * `'output='` [ *`'auto'`* | `'dbase'` | `'tseries'` ] - Format of output
% data.
%
% * `'tolerance='` [ numeric | *`0`* ] - Numerical tolerance under which
% two FMSE matrices computed in two consecutive periods will be treated as
% equal and their inversions will be re-used, not re-computed.
%
% Description
% ============
%
% It is the user's responsibility to make sure that `filter` and `forecast`
% called with `'persist='` set to true are valid, i.e. that the
% previously computed FMSE matrices can be really re-used in the current
% run.
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

% Parse input arguments.
pp = inputParser( );
pp.addRequired('a',@(x) isa(x,'FAVAR'));
pp.addRequired('d',@(x) isstruct(x) || isa(x,'tseries'));
pp.addRequired('range',@isnumeric);
pp.parse(This,Inp,Range);

% Parse options.
opt = passvalopt('FAVAR.filter',varargin{:});

%--------------------------------------------------------------------------

nx = size(This.C,2);
p = size(This.A,2)/nx;
Range = Range(1) : Range(end);

% Retrieve and standardise input data.
req = datarequest('y*',This,Inp,Range);
outpFormat = req.Format;
Range = req.Range;
y = req.Y;

[This,y] = standardise(This,y);
nPer = size(y,2);

% Initialise Kalman filter.
x0 = zeros([p*nx,1]);
R = This.U(1:nx,:)'*This.B;
P0 = covfun.acovf(This.T,R,[ ],[ ],[ ],[ ],This.U,1,[ ],0);

Sgm = This.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.cross = double(opt.cross);
if opt.cross < 1
    inx = logical(eye(size(Sgm)));
    Sgm(~inx) = opt.cross*Sgm(~inx);
end

% Inversion method for the FMSE matrix. It is safe to use `inv` if
% cross-correlations are pulled down because then the idiosyncratic cov
% matrix is non-singular.
if isequal(opt.invfunc,'auto')
    if This.Cross == 1 && opt.cross == 1
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
s.allObs = This.Cross == 1 && opt.cross == 1;
s.tol = opt.tolerance;
s.reuse = opt.persist;
s.ahead = 1;

[x,Px,E,U,y,Py,yInx] = timedom.varsmoother( ...
    This.A,This.B,[ ],This.C,[ ],1,Sgm,y,[ ],x0,P0,s);

if opt.meanonly
    Px = Px(:,:,[ ],[ ]);
    Py = [ ];
end

if nargout > 1
    yNames = get(This,'ynames');
    [y,Py] = FAVAR.destandardise(This.Mean,This.Std,y,Py);
    D = myoutpdata(This,outpFormat,Range,y,Py,yNames);
end

if nargout > 2
    % Common components.
    [CC,Pc] = FAVAR.cc(This.C,x(1:nx,:,:),Px(1:nx,1:nx,:,:));
    [CC,Pc] = FAVAR.destandardise(This.Mean,This.Std,CC,Pc);
    CC = myoutpdata(This,outpFormat,Range,CC,Pc,yNames);
end

if nargout > 3
    % Factors.
    F = myoutpdata(This, ...
        'tseries',Range,x(1:nx,:,:),Px(1:nx,1:nx,:,:));
    if ~opt.meanonly
        % Means and MSEs that can be used as initial condition.
        lastObs = find(any(yInx ~= 0,1),1,'last');
        if isempty(lastObs)
            inx = 1 : nPer;
        else
            inx = lastObs : nPer;
        end
        F.init = {x(:,inx,:),Px(:,:,inx,:),Range(inx)};
    end
end

if nargout > 4
    U = FAVAR.destandardise(0,This.Std,U);
    U = myoutpdata(This,outpFormat,Range,U,NaN,yNames);
end

if nargout > 5
    E = replace(TEMPLATE_SERIES,permute(E,[2,1,3]),Range(1));
    if ~opt.meanonly
        E = struct( ...
            'mean',E, ...
            'std',replace(TEMPLATE_SERIES,zeros([0,size(E,1),size(E,3)]),Range(1)) ...
            );
    end
end

end
