function outputDatabank = simulate(this, inputDatabank, range, varargin)
% simulate  Simulate VAR model.
%
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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% Panel VAR
if this.IsPanel
    outputDatabank = runGroups(@simulate, this, inputDatabank, range, varargin{:});
    return
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@VAR/simulate');
    pp.addRequired('VAR', @(x) isa(x, 'VAR'));
    pp.addRequired('InputDatabank', @validate.databank);
    pp.addRequired('Range', @DateWrapper.validateProperRangeInput);
    pp.addParameter('AppendPresample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter('AppendPostsample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter('DbOverlay', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    pp.addParameter({'Deviation', 'Deviations'}, false, @(x) isequal(x, true) || isequal(x, false));
    pp.addParameter('Contributions', false, @(x) isequal(x, true) || isequal(x, false));
end
%)
opt = parse(pp, this, inputDatabank, range, varargin{:});

if ischar(range)
    range = textinp2dat(range);
end
range = double(range);

%--------------------------------------------------------------------------

ny = this.NumEndogenous;
ne = this.NumResiduals;
ng = this.NumExogenous;
nv = countVariants(this);
indexX = [true(ny, 1); false(ng, 1); false(ne, 1)];
indexG = [false(ny, 1);  true(ng, 1); false(ne, 1)];
indexE = [false(ny, 1); false(ng, 1);  true(ne, 1)];
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
databankInfo = checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames);
numOfPages = databankInfo.NumPages;

allNames = [this.EndogenousNames, this.ExogenousNames, this.ResidualNames];
XEG = requestData(this, databankInfo, inputDatabank, extdRange, allNames);

%req = datarequest('y* x* e', this, inputDatabank, extdRange);
%extdRange = req.Range;
%y = req.Y;
%x = req.X;
%e = req.E;
%e(isnan(e)) = 0;

if isBackcast
    XEG = flip(XEG, 2);
%    y = flip(y, 2);
%    e = flip(e, 2);
%    x = flip(x, 2);
end

%e(:, 1:order, :) = NaN;
numExtdPeriods = numel(extdRange);
%numDataY = size(y, 3);
%numDataX = size(x, 3);
%numDataE = size(e, 3);
numOfRuns = max(nv, numOfPages);

if opt.Contributions 
    if numOfRuns~=1
        THIS_ERROR = { 'VAR:CannotSimulateContributions'
                       'Cannot simulate shock contributions in VAR with multiple parameter variants' };
        throw( exception.Base(THIS_ERROR, 'error') );
    end
    numOfRuns = ny + 2;
end

% Expand Y, E, X data in 3rd dimension to match numOfRuns.
if numOfPages<numOfRuns
    numAdd = numOfRuns - numOfPages;
    XEG(:, :, end+1:numOfRuns) = repmat(XEG(:, :, end), 1, 1, numAdd);
end
%if numDataY<numOfRuns
%    y = cat(3, y, repmat(y, 1, 1, numOfRuns-numDataY));
%end
%if numDataE<numOfRuns
%    e = cat(3, e, repmat(e, 1, 1, numOfRuns-numDataE));
%end
%if ng>0 && numDataX<numOfRuns
%    x = cat(3, x, repmat(x, 1, 1, numOfRuns-numDataX));
%elseif ng==0
%    x = zeros(0, numExtdPeriods, numOfRuns);
%end

%if opt.Contributions
%    y(:, :, [1:end-2, end]) = 0;
%    x(:, :, 1:end-1) = 0;
%end

%if ~opt.Contributions
%    outp1 = hdataobj(this, extdRange, numOfRuns);
%else
%    outp1 = hdataobj(this, extdRange, numOfRuns, 'Contributions=', @shock);
%end

% __Main Loop__
for iLoop = 1 : numOfRuns
    if iLoop<=nv
        [A, B, K, J] = mysystem(this, iLoop);
    end

    ithX = XEG(indexX, :, iLoop);
    ithG = XEG(indexG, :, iLoop);
    ithE = XEG(indexE, :, iLoop);
    ithE(isnan(ithE)) = 0;
    ithE(:, 1:order-1) = NaN;

    includeConstant = ~opt.Deviation;
    if opt.Contributions
        if iLoop<=ny
            % Contributions of shock i
            inx = true(1, ny);
            inx(iLoop) = false;
            %e(inx, :, iLoop) = 0;
            ithE(inx, :) = 0;
            ithX(:, :) = 0;
            ithG(:, :) = 0;
            includeConstant = false;
        elseif iLoop==ny+1
            % Contributions of init and const
            %e(:, :, iLoop) = 0;
            ithE(:, :) = 0;
            ithG(:, :) = 0;
            includeConstant = true;
        elseif iLoop==ny+2
            % Contributions of exogenous variables
            %e(:, :, iLoop) = 0;
            ithE(:, :) = 0;
            ithX(:, :) = 0;
            includeConstant = false;
        end
    end
    
    %iE = e(:, :, iLoop);
    if isempty(B)
        %iBe = iE;
        ithBE = ithE;
    else
        %iBe = B*iE;
        ithBE = B*ithE;
    end
    
    %iY = y(:, :, iLoop);
    %iX = [ ];
    %if ng>0
    %    iX = x(:, :, iLoop);
    %end

    % Collect deterministic terms (constant, exogenous inputs).
    %iKJ = zeros(ny, numExtdPeriods);
    ithDeterministic = zeros(ny, numExtdPeriods);
    if includeConstant
        %iKJ = iKJ + K(:, ones(1, numExtdPeriods));
        ithDeterministic = ithDeterministic + K(:, ones(1, numExtdPeriods));
    end
    if ng>0
        %iKJ = iKJ + J*iX;
        ithDeterministic = ithDeterministic + J*ithG;
    end
    
    for t = order + 1 : numExtdPeriods
        %iXLags = iY(:, t-(1:order));
        %iY(:, t) = A*iXLags(:) + iKJ(:, t) + iBe(:, t);
        stackLags = ithX(:, t-(1:order));
        ithX(:, t) = A*stackLags(:) + ithDeterministic(:, t) + ithBE(:, t);
    end

    %if isBackcast
    %    iY = flip(iY, 2);
    %    iE = flip(iE, 2);
    %    if ng>0
    %        iX = flip(iX, 2);
    %    end
    %end

    % Assign current results.
    %hdataassign(outp1, iLoop, {iY, iX, iE, [ ]} );
    XEG(:, :, iLoop) = [ithX; ithE; ithG];
end

if isBackcast
    XEG = flip(XEG, 2);
end

% Create output database
outputDatabank = returnData(this, XEG, extdRange, allNames);
outputDatabank = appendData(this, inputDatabank, outputDatabank, range, opt);

end%

