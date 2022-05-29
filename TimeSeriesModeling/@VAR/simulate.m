% simulate  Simulate VAR model
%{
% __Syntax__
%
%     Outp = simulate(V, Inp, Range, ...)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - VAR object that will be simulated.
%
% * `Inp` [ struct ] - Input databank from which the initial condtions and
% residuals will be taken.
%
% * `Range` [ DateWrapper ] - Simulation range; must not be `Inf`.
%
%
% __Output Arguments__
%
% * `Outp` [ tseries ] - Output databank with simulated time series.
%
%
% __Options__
%
% * `AppendPresample=false` [ `true` | `false` | struct ] - Append
% presample data from input databank.
%
% * `Contributions=false` [ `true` | `false` ] - Decompose the simulated
% paths into the contributions of individual residuals, initial condition,
% the constant, and exogenous inputs; see Description.
%
% * `Deviation=false` [ `true` | `false` ] - Treat input and output data as
% deviations from unconditional mean.
%
%
% __Description__
%
% _Backward Simulation_
%
% If the `Range` is a vector of decreasing dates, the simulation is
% performed backward. The VAR object is first converted to its backward
% representation using the function [`backward`](VAR/backward), and then
% the data are simulated from the latest date to the earliest date.
%
%
% _Simulation of Contributions__
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
% __Example__
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = simulate(this, inputDb, range, varargin)

% Panel VAR model
if this.IsPanel
    outputDb = runGroups(@simulate, this, inputDb, range, varargin{:});
    return
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@VAR/simulate');
    pp.addRequired('VAR', @(x) isa(x, 'VAR'));
    pp.addRequired('InputDatabank', @validate.databank);
    pp.addRequired('Range', @validate.properRange);
    pp.addParameter('AppendPresample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter('AppendPostsample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter('DbOverlay', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter({'Deviation', 'Deviations'}, false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Contributions', false, @(x) isequal(x, true) || isequal(x, false));
end
%)
opt = parse(pp, this, inputDb, range, varargin{:});

range = double(range);

%--------------------------------------------------------------------------

numY = this.NumEndogenous;
numE = this.NumResiduals;
numG = this.NumExogenous;
nv = countVariants(this);
inxX = [true(numY, 1); false(numG, 1); false(numE, 1)];
inxG = [false(numY, 1);  true(numG, 1); false(numE, 1)];
inxE = [false(numY, 1); false(numG, 1);  true(numE, 1)];
order = this.Order;

if isempty(range)
    return
end
numPeriods = numel(range);

isBackcast = range(1)>range(end);
if isBackcast
    this = backward(this);
    extdRange = dater.colon(range(end), dater.plus(range(1), order));
    indeextRange = [true(1, numPeriods), false(1, order)];
else
    extdRange = dater.colon(dater.plus(range(1), -order), range(end));
    indeextRange = [false(1, order), true(1, numPeriods)];
end

% Check availability of input data in input databank
requiredNames = [this.EndogenousNames, this.ExogenousNames];
optionalNames = this.ResidualNames;
allowedNumeric = string.empty(1, 0);
allowedLog = string.empty(1, 0);
context = "";
dbInfo = checkInputDatabank( ...
    this, inputDb, extdRange ...
    , requiredNames, optionalNames ...
    , allowedNumeric, allowedLog ...
    , context ...
);

% Retrieve a YEG data array from the input databank
YEG = requestData( ...
    this, dbInfo, inputDb ...
    , [requiredNames, optionalNames], extdRange ...
);


if isBackcast
    YEG = flip(YEG, 2);
%    y = flip(y, 2);
%    e = flip(e, 2);
%    x = flip(x, 2);
end

%e(:, 1:order, :) = NaN;
numExtdPeriods = numel(extdRange);
%numDataY = size(y, 3);
%numDataX = size(x, 3);
%numDataE = size(e, 3);
numRuns = max(nv, dbInfo.NumPages);

if opt.Contributions 
    if numRuns~=1
        exception.error([
            "VAR:CannotSimulateContributions"
            "Cannot simulate shock contributions in VAR with multiple parameter variants"
        ]);
    end
    numRuns = numY + 2;
end

% Expand Y, E, X data in 3rd dimension to match numRuns.
if dbInfo.NumPages<numRuns
    numAdd = numRuns - dbInfo.NumPages;
    YEG(:, :, end+1:numRuns) = repmat(YEG(:, :, end), 1, 1, numAdd);
end
%if numDataY<numRuns
%    y = cat(3, y, repmat(y, 1, 1, numRuns-numDataY));
%end
%if numDataE<numRuns
%    e = cat(3, e, repmat(e, 1, 1, numRuns-numDataE));
%end
%if numG>0 && numDataX<numRuns
%    x = cat(3, x, repmat(x, 1, 1, numRuns-numDataX));
%elseif numG==0
%    x = zeros(0, numExtdPeriods, numRuns);
%end

%if opt.Contributions
%    y(:, :, [1:end-2, end]) = 0;
%    x(:, :, 1:end-1) = 0;
%end

%if ~opt.Contributions
%    outp1 = hdataobj(this, extdRange, numRuns);
%else
%    outp1 = hdataobj(this, extdRange, numRuns, 'Contributions=', @shock);
%end


% /////////////////////////////////////////////////////////////////////////
for run = 1 : numRuns
    if run<=nv
        [A, B, K, J] = getIthSystem(this, run);
    end

    Y__ = YEG(inxX, :, run);
    G__ = YEG(inxG, :, run);
    E__ = YEG(inxE, :, run);
    E__(isnan(E__)) = 0;
    E__(:, 1:order-1) = NaN;

    includeConstant = ~opt.Deviation;
    if opt.Contributions
        if run<=numY
            % Contributions of shock i
            inx = true(1, numY);
            inx(run) = false;
            %e(inx, :, run) = 0;
            E__(inx, :) = 0;
            Y__(:, :) = 0;
            G__(:, :) = 0;
            includeConstant = false;
        elseif run==numY+1
            % Contributions of init and const
            %e(:, :, run) = 0;
            E__(:, :) = 0;
            G__(:, :) = 0;
            includeConstant = true;
        elseif run==numY+2
            % Contributions of exogenous variables
            %e(:, :, run) = 0;
            E__(:, :) = 0;
            Y__(:, :) = 0;
            includeConstant = false;
        end
    end
    
    %iE = e(:, :, run);
    if isempty(B)
        %iBe = iE;
        ithBE = E__;
    else
        %iBe = B*iE;
        ithBE = B*E__;
    end
    
    %iY = y(:, :, run);
    %iX = [ ];
    %if numG>0
    %    iX = x(:, :, run);
    %end

    % Collect deterministic terms (constant, exogenous inputs).
    %iKJ = zeros(numY, numExtdPeriods);
    ithDeterministic = zeros(numY, numExtdPeriods);
    if includeConstant
        %iKJ = iKJ + K(:, ones(1, numExtdPeriods));
        ithDeterministic = ithDeterministic + K(:, ones(1, numExtdPeriods));
    end
    if numG>0
        %iKJ = iKJ + J*iX;
        ithDeterministic = ithDeterministic + J*G__;
    end
    
    for t = order + 1 : numExtdPeriods
        %iXLags = iY(:, t-(1:order));
        %iY(:, t) = A*iXLags(:) + iKJ(:, t) + iBe(:, t);
        stackLags = Y__(:, t-(1:order));
        Y__(:, t) = A*stackLags(:) + ithDeterministic(:, t) + ithBE(:, t);
    end

    %if isBackcast
    %    iY = flip(iY, 2);
    %    iE = flip(iE, 2);
    %    if numG>0
    %        iX = flip(iX, 2);
    %    end
    %end

    % Assign current results.
    YEG(:, :, run) = [Y__; E__; G__];
end

if isBackcast
    YEG = flip(YEG, 2);
end

% Create output database
outputDb = returnData(this, YEG, extdRange, dbInfo.AllNames);
outputDb = appendData(this, inputDb, outputDb, range, opt);

end%

