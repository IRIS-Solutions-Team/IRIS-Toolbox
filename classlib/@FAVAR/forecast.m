function [D,CC,F,U,E] = forecast(This,Inp,Range,J,varargin)
% forecast  Forecast FAVAR factors and observables.
%
% Syntax
% =======
%
%     [D,CC,F,U,E] = forecast(A,D,RANGE,J,...)
%
% Input arguments
% ================
%
% * `A` [ FAVAR ] - FAVAR object.
%
% * `D` [ struct | tseries ] - Input data with initial condition for the
% FAVAR factors.
%
% * `RANGE` [ numeric ] - Forecast range.
%
% * `J` [ struct | tseries] - Conditioning data with hard tunes on the
% FAVAR observables.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database or tseries object with the FAVAR
% observables.
%
% * `CC` [ struct | tseries ] - Projection of common components in the
% observables.
%
% * `F` [ tseries ] - Projection of common factors.
%
% * `U` [ tseries ] - Conditional idiosyncratic residuals.
%
% * `E` [ tseries ] - Conditional structural residuals.
%
% Options
% ========
%
% See help on [`FAVAR/filter`](FAVAR/filter) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

% Parse required input arguments.
pp = inputParser( );
pp.addRequired('A',@isFAVAR);
pp.addRequired('D',@(x) istseries(x) || isstruct(x));
pp.addRequired('Range',@isnumeric);
pp.addRequired('J',@(x) isempty(x) || istseries(x) || isstruct(x));
pp.parse(This,Inp,Range,J);

% Parse options.
opt = passvalopt('FAVAR.forecast',varargin{:});

%--------------------------------------------------------------------------

ny = size(This.C,1);
nx = size(This.C,2);
pp = size(This.A,2)/nx;
Range = Range(1) : Range(end);

if isstruct(Inp) ...
      && ~isfield(Inp,'init') ...
      && isfield(Inp,'mean') ...
      && istseries(Inp.mean)
   Inp = Inp.mean;
end

if istseries(Inp)
   % Only mean tseries supplied; no uncertainty in initial condition.
   reqRange = Range(1)-pp : Range(1)-1;
   req = datarequest('y*',This,Inp,reqRange);
   x0 = req.Y(:,end:-1:1,:,:);
   x0 = x0(:);
   P0 = 0;
else
   % Complete description of initial conditions.
   inx = abs(Range(1)-1 - Inp.init{3}) <= 0.01;
   if isempty(inx) || ~any(inx)
      % Initial condition not available.
      utils.error('FAVAR', ...
         'Initial condition for factors not available from input data.');
   end
   x0 = Inp.init{1}(:,inx,:,:);
   P0 = Inp.init{2}(:,:,inx,:,:);
end
nPer = length(Range);
nData = size(x0,3);

if ~isempty(J)
   if isstruct(J) && isfield(J,'mean')
      J = J.mean;
   end
   req = datarequest('y*',This,J,Range);
   outpFmt = req.Format;
   Range = req.Range;
   y = req.Y;
   [This,y] = standardise(This,y);
else
   y = nan(ny,nPer,nData);
   outpFmt = opt.output;
   if strcmpi(outpFmt,'auto')
      if isempty(This.YNames)
         outpFmt = 'tseries';
      else
         outpFmt = 'dbase';
      end
   end   
end

Sgm = This.Sigma;
% Reduce or zero off-diagonal elements in the cov matrix of idiosyncratic
% residuals if requested.
opt.cross = double(opt.cross);
if opt.cross < 1
   inx = logical(eye(size(Sgm)));
   Sgm(~inx) = opt.cross*Sgm(~inx);
end

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

[y,Py] = FAVAR.destandardise(This.Mean,This.Std,y,Py);

yNames = get(This,'ynames');
D = myoutpdata(This,outpFmt,Range,y,Py,yNames);

if nargout > 1
   % Common components.
   [CC,Pc] = FAVAR.cc(This.C,x(1:nx,:,:),Px(1:nx,1:nx,:,:));
   [CC,Pc] = FAVAR.destandardise(This.Mean,This.Std,CC,Pc);
   CC = myoutpdata(This,outpFmt,Range,CC,Pc,yNames);   
end

if nargout > 2
   F = myoutpdata(This, ...
       'tseries',Range,x(1:nx,:,:),Px(1:nx,1:nx,:,:));
   if ~opt.meanonly
      % Means and MSEs that can be used as initial condition.
      lastobs = find(any(yInx ~= 0,1),1,'last');
      if isempty(lastobs)
         inx = 1 : nPer;
      else
         inx = lastobs : nPer;
      end
      F.init = {x(:,inx,:),Px(:,:,inx,:),Range(inx)};
   end
end

if nargout > 3
   U = FAVAR.destandardise(0,This.Std,U);
   U = myoutpdata(This,outpFmt,Range,U,NaN,yNames);
end

if nargout > 5
   E = replace(TEMPLATE_SERIES,permute(E,[2,1,3]),Range(1));
   if ~opt.meanonly
   E = struct( ...
      'mean',E, ...
      'std',replace(TEMPLATE_SERIES,zeros(0,size(E,1),size(E,3)),Range(1)) ...
      );
   end
end

end
