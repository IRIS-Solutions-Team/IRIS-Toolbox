function outp = simulate(this, inp, range, varargin)
% simulate  Simulate VAR model.
%
% Syntax
% =======
%
%     Outp = simulate(V,Inp,Range,...)
%
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object that will be simulated.
%
% * `Inp` [ tseries | struct ] - Input data from which the initial
% condtions and residuals will be taken.
%
% * `Range` [ numeric ] - Simulation range; must not refer to `Inf`.
%
% Output arguments
% =================
%
% * `Outp` [ tseries ] - Simulated output data.
%
% Options
% ========
%
% * `'contributions='` [ `true` | *`false`* ] - Decompose the simulated
% paths into the contributions of individual residuals, initial condition,
% the constant, and exogenous inputs; see Description.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from unconditional mean.
%
% * `'output='` [ *`'auto'`* | `'dbase'` | `'tseries'` ] - Format of output
% data.
%
%
% Description
% ============
%
% Backward simulation (backcast)
% ------------------------------
%
% If the `Range` is a vector of decreasing dates, the simulation is
% performed backward. The VAR object is first converted to its backward
% representation using the function [`backward`](VAR/backward), and then
% the data are simulated from the latest date to the earliest date.
%
% Simulation of contributions
% ----------------------------
%
% With the option `'contributions=' true`, the output database contains
% Ne+2 columns for each variable, where Ne is the number of residuals. The
% first Ne columns are the contributions of the individual shocks, the
% (Ne+1)-th column is the contribution of initial condition and the
% constant, and the last, (Ne+2)-th columns is the contribution of
% exogenous inputs.
%
% Contribution simulations can be only run on VAR objects with one
% parameterization.
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

% Panel VAR.
if ispanel(this)
    outp = mygroupmethod(@simulate, this, inp, range, varargin{:});
    return
end

% Parse input arguments.
pp = inputParser( );
pp.addRequired('V',@(x) isa(x, 'VAR'));
pp.addRequired('Inp',@isstruct);
pp.addRequired('Range',@(x) isnumeric(x) && ~any(isinf(x(:))));
pp.parse(this, inp, range);

% Parse options.
opt = passvalopt('VAR.simulate', varargin{:});

%--------------------------------------------------------------------------

ny = size(this.A,1);
pp = size(this.A,2) / max(ny,1);
nAlt = size(this.A,3);
kx = length(this.XNames);

if isempty(range)
    return
end

isBackcast = range(1)>range(end);
if isBackcast
    this = backward(this);
    range = range(end) : range(1)+pp;
else
    range = range(1)-pp : range(end);
end

% Include pre-sample.
req = datarequest('y* x* e', this, inp, range);
xRange = req.Range;
y = req.Y;
x = req.X;
e = req.E;
e(isnan(e)) = 0;

if isBackcast
    y = flip(y,2);
    e = flip(e,2);
    x = flip(x,2);
end

e(:,1:pp,:) = NaN;
nXPer = length(xRange);
nDataY = size(y, 3);
nDataX = size(x, 3);
nDataE = size(e, 3);
nLoop = max([nAlt, nDataY, nDataX, nDataE]);

if opt.contributions
    if nLoop>1
        % Cannot run contributions for multiple data sets or params.
        utils.error('model:simulate', ...
            '#Cannot_simulate_contributions');
    else
        % Simulation of contributions.
        nLoop = ny + 2;
    end
end

% Expand Y, E, X data in 3rd dimension to match nLoop.
if nDataY<nLoop
    y = cat(3, y, repmat(y, 1, 1, nLoop-nDataY));
end
if nDataE<nLoop
    e = cat(3, e, repmat(e, 1, 1, nLoop-nDataE));
end
if kx>0 && nDataX<nLoop
    x = cat(3, x, repmat(x, 1, 1, nLoop-nDataX));
elseif kx==0
    x = zeros(0, nXPer, nLoop);
end

if opt.contributions
    y(:, :, [1:end-2,end]) = 0;
    x(:, :, 1:end-1) = 0;
end

if ~opt.contributions
    outp = hdataobj(this, xRange, nLoop);
else
    outp = hdataobj(this, xRange, nLoop, 'Contributions=', @shock);
end

% Main loop
%-----------

for iLoop = 1 : nLoop
    if iLoop<=nAlt
        [A, B, K, J] = mysystem(this, iLoop);
    end

    isConst = ~opt.deviation;
    if opt.contributions
        if iLoop<=ny
            % Contributions of shocks.
            inx = true(1, ny);
            inx(iLoop) = false;
            e(inx, :, iLoop) = 0;
            isConst = false;
        elseif iLoop==ny+1
            % Contributions of init and const.
            e(:, :, iLoop) = 0;
            isConst = true;
        elseif iLoop==ny+2
            % Contributions of exogenous inputs.
            e(:, :, iLoop) = 0;
            isConst = false;
        end
    end
    
    iE = e(:,:,iLoop);
    if isempty(B)
        iBe = iE;
    else
        iBe = B*iE;
    end
    
    iY = y(:, :, iLoop);
    iX = [ ];
    if kx>0
        iX = x(:, :, iLoop);
    end

    % Collect deterministic terms (constant, exogenous inputs).
    iKJ = zeros(ny, nXPer);
    if isConst
        iKJ = iKJ + K(:, ones(1,nXPer));
    end
    if kx>0
        iKJ = iKJ + J*iX;
    end
    
    for t = pp + 1 : nXPer
        iXLags = iY(:, t-(1:pp));
        iY(:,t) = A*iXLags(:) + iKJ(:,t) + iBe(:,t);
    end
    
    if isBackcast
        iY = flip(iY, 2);
        iE = flip(iE, 2);
        if kx>0
            iX = flip(iX, 2);
        end
    end

    % Assign current results.
    hdataassign(outp, iLoop, {iY, iX, iE, [ ]} );
end

% Create output database.
outp = hdata2tseries(outp);

end
