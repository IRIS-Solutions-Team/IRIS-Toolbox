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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Panel VAR.
if ispanel(this)
    outputDatabank = mygroupmethod(@simulate, this, inputDatabank, range, varargin{:});
    return
end

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('VAR.simulate');
    inputParser.addRequired('VAR', @(x) isa(x, 'VAR'));
    inputParser.addRequired('InputDatabank', @isstruct);
    inputParser.addRequired('Range', @DateWrapper.validateProperRangeInput);
    inputParser.addParameter('AppendPresample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    inputParser.addParameter('AppendPostsample', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    inputParser.addParameter('DbOverlay', false, @(x) isequal(x, true) || isequal(x, false) || isstruct(x));
    inputParser.addParameter({'Deviation', 'Deviations'}, false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Contributions', false, @(x) isequal(x, true) || isequal(x, false));
    inputParser.addParameter('Reporting', true, @(x) isequal(x, true) || isequal(x, false));
end
inputParser.parse(this, inputDatabank, range, varargin{:});
opt = inputParser.Options;
if ischar(range)
    range = textinp2dat(range);
end

%--------------------------------------------------------------------------

ny = this.NumEndogenous;
ne = this.NumErrors;
ng = this.NumExogenous;
nv = this.NumOfVariants;
indexX = [ true(ny, 1); false(ng, 1); false(ne, 1)];
indexG = [false(ny, 1);  true(ng, 1); false(ne, 1)];
indexE = [false(ny, 1); false(ng, 1);  true(ne, 1)];

pp = size(this.A, 2) / max(ny, 1);

if isempty(range)
    return
end
numPeriods = length(range);

isBackcast = range(1)>range(end);
if isBackcast
    this = backward(this);
    extendedRange = range(end) : range(1)+pp;
    indeextendedRange = [true(1, numPeriods), false(1, pp)];
else
    extendedRange = range(1)-pp : range(end);
    indeextendedRange = [false(1, pp), true(1, numPeriods)];
end

% Check availability of input data in input databank
requiredNames = [this.NamesEndogenous, this.NamesExogenous];
optionalNames = this.NamesErrors;
check = checkInputDatabank(this, inputDatabank, range, requiredNames, optionalNames);
numDataSets = check.NumDataSets;

allNames = [this.NamesEndogenous, this.NamesExogenous, this.NamesErrors];
XEG = requestData(this, check, inputDatabank, extendedRange, allNames);

%req = datarequest('y* x* e', this, inputDatabank, extendedRange);
%extendedRange = req.Range;
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

%e(:, 1:pp, :) = NaN;
numExtendedPeriods = length(extendedRange);
%numDataY = size(y, 3);
%numDataX = size(x, 3);
%numDataE = size(e, 3);
numRuns = max(nv, numDataSets);

if opt.Contributions
    assert( ...
        numRuns==1, ...
        'VAR:simulate', ...
        'Cannot Contributions= simulation on VAR with multiple parameter variants.' ...
    );
    numRuns = ny + 2;
end

% Expand Y, E, X data in 3rd dimension to match numRuns.
if numDataSets<numRuns
    numAdd = numRuns - numDataSets;
    XEG(:, :, end+1:numRuns) = repmat(XEG(:, :, end), 1, 1, numAdd);
end
%if numDataY<numRuns
%    y = cat(3, y, repmat(y, 1, 1, numRuns-numDataY));
%end
%if numDataE<numRuns
%    e = cat(3, e, repmat(e, 1, 1, numRuns-numDataE));
%end
%if ng>0 && numDataX<numRuns
%    x = cat(3, x, repmat(x, 1, 1, numRuns-numDataX));
%elseif ng==0
%    x = zeros(0, numExtendedPeriods, numRuns);
%end

%if opt.Contributions
%    y(:, :, [1:end-2, end]) = 0;
%    x(:, :, 1:end-1) = 0;
%end

%if ~opt.Contributions
%    outp1 = hdataobj(this, extendedRange, numRuns);
%else
%    outp1 = hdataobj(this, extendedRange, numRuns, 'Contributions=', @shock);
%end

% __Main Loop__
for iLoop = 1 : numRuns
    if iLoop<=nv
        [A, B, K, J] = mysystem(this, iLoop);
    end

    ithX = XEG(indexX, :, iLoop);
    ithG = XEG(indexG, :, iLoop);
    ithE = XEG(indexE, :, iLoop);
    ithE(isnan(ithE)) = 0;
    ithE(:, 1:pp-1) = NaN;

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
    %iKJ = zeros(ny, numExtendedPeriods);
    ithDeterministic = zeros(ny, numExtendedPeriods);
    if includeConstant
        %iKJ = iKJ + K(:, ones(1, numExtendedPeriods));
        ithDeterministic = ithDeterministic + K(:, ones(1, numExtendedPeriods));
    end
    if ng>0
        %iKJ = iKJ + J*iX;
        ithDeterministic = ithDeterministic + J*ithG;
    end
    
    for t = pp + 1 : numExtendedPeriods
        %iXLags = iY(:, t-(1:pp));
        %iY(:, t) = A*iXLags(:) + iKJ(:, t) + iBe(:, t);
        stackLags = ithX(:, t-(1:pp));
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

% Create output database.
%outp1 = hdata2tseries(outp1);
outputDatabank = returnData(this, XEG, extendedRange, allNames);

outputDatabank = appendData(this, inputDatabank, outputDatabank, range, opt);
%outp1 = appendData(this, inputDatabank, outp1, range, opt);

if opt.Reporting && ~isempty(this.Reporting)
    for i = 1 : numel(allNames)
        ithName = allNames{i};
        inputDatabank.(ithName) = outputDatabank.(ithName);
    end
    for i = 1 : numel(this.Reporting)
        inputDatabank = run(this.Reporting(i), inputDatabank, range, ...
            'AppendPresample=', opt.AppendPresample);
    end
    namesReporting = this.NamesReporting;
    for i = 1 : numel(namesReporting)
        ithName = namesReporting{i};
        outputDatabank.(ithName) = inputDatabank.(ithName);
    end
end

end
