% filter  Filter data using VAR model
%{
% ## Syntax ##
%
%     [v, outputDatabank] = filter(v, inputDb, range, ...)
%
%
% ## Input Arguments ##
%
% __`v`__ [ VAR ] -
% Input VAR object.
%
% __`inputDb`__ [ struct ] -
% Input databank from which initial condition will be read.
%
% __`range`__ [ numeric ] -
% Filtering range.
%
%
% ## Output Arguments ##
%
% __`V`__ [ VAR ] -
% Output VAR object.
%
% __`outputDatabank`__ [ struct ] -
% Output databank with prediction and/or smoothed data.
%
%
% ## Options ##
%
% __`Cross=1`__ [ numeric | `1` ] -
% Multiplier applied to the off-diagonal elements of the covariance matrix
% (cross-covariances); `Cross=` must be between `0` and `1` (inclusive).
%
% __`Deviation=false`__ [ `true` | `false` ] -
% Both input and output data are deviations from the unconditional mean.
%
% __`MeanOnly=false`__ [ `true` | `false` ] -
% Return a plain databank with mean forecasts only.
%
% __`Omega=[ ]`__ [ numeric | empty ] -
% Modify the covariance matrix of residuals for this run of the filter.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function [this, outputDatabank] = filter(this, inputDb, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    % Required arguments
    addRequired(ip, 'this', @(x) isa(x, 'VAR'));
    addRequired(ip, 'inputDb', @validate.databank);
    addRequired(ip, 'range', @validate.properRange);
    % Name-value options
    addParameter(ip, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    addParameter(ip, 'Cross', true, @(x) validate.logicalScalar(x) || (validate.numericScalar(x) && x>=0 && x<=1));
    addParameter(ip, 'Deviation', false, @(x) islogical(x) && isscalar(x));
    addParameter(ip, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(ip, 'Omega', [], @isnumeric);
    addParameter(ip, 'Output', 'smooth', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(ip, 'Initials', 'fixedFromData', @(x) ismember(lower(string(x)), ["fixedFromData", "asymptotic"]));
end
parse(ip, this, inputDb, range, varargin{:});
opt = rmfield(ip.Results, ["this", "inputDb", "range"]);

[isPred, isFilter, isSmooth] = here_processOptionOutput( );

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);
nx = length(this.ExogenousNames);
isX = nx>0;
isConst = ~opt.Deviation;

range = range(1) : range(end);
extendedRange = range(1)-p : range(end);

% Include pre-sample
req = datarequest('y*, x*', this, inputDb, extendedRange);
extendedRange = req.Range;
y = req.Y;
x = req.X;

numPeriods = numel(range);
yInit = y(:, 1:p, :);
y = y(:, p+1:end, :);
x = x(:, p+1:end, :);

numPagesY = size(yInit, 3);
numPagesX = size(x, 3);
nOmg = size(opt.Omega, 3);

numRuns = max([nv, numPagesY, numPagesX, nOmg]);
here_checkOptions( );

% Stack initial conditions
yInit = yInit(:, p:-1:1, :);
yInit = reshape(yInit(:), ny*p, numRuns);

YY = [ ];
here_requestOutput( );

s = struct( );
s.invFunc = @inv;
s.allObs = NaN;
s.tol = 0;
s.reuse = 0;
s.ahead = opt.Ahead;

% Missing initial conditions
missingInit = false(ny, numPagesY);

Z = eye(ny);
for i = 1 : numRuns
    % Get system matrices for ith parameter variant
    [A__, B__, K__, J__, ~, Omega__] = getIthSystem(this, i);

    % User-supplied covariance matrix.
    if ~isempty(opt.Omega)
        Omega__(:, :) = opt.Omega(:, :, min(i, end));
    end

    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. this only matters in VARs, not SVARs.
    if double(opt.Cross)<1
        inx = logical(eye(size(Omega__)));
        Omega__(~inx) = double(opt.Cross)*Omega__(~inx);
    end

    % Use the `allobserved` option in `@iris.mixin.Kalman/smootherForVAR` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(Omega__)==ny;

    Y__ = y(:, :, min(i, end));
    X__ = x(:, :, min(i, end));

    % Get initials from data
    [yInit__, missingInit__] = here_getInitials();
    missingInit(:, i) = missingInit__;

    % Collect all deterministic terms: constant and exogenous inputs
    KJ__ = zeros(ny, numPeriods);
    if isConst
        KJ__ = KJ__ + repmat(K__, 1, numPeriods);
    end
    if isX
        KJ__ = KJ__ + J__*X__;
    end

    % Run Kalman filter and smoother
    [~, ~, E2__, ~, Y2__, iPy2, ~, Y0__, Py0__, Y1__, iPy1] ...
        = iris.mixin.Kalman.smootherForVAR(this, A__, B__, KJ__, Z, [ ], Omega__, [ ], Y__, [ ], yInit__, 0, s);

    % Add pre-sample periods and assign hdata
    here_assignOutput( );
end

here_reportMissingInit( );

% Final output databank
outputDatabank = hdataobj.hdatafinal(YY);

return

    function [isPred, isFilter, isSmooth] = here_processOptionOutput( )
        temp = opt.Output;
        if ischar(temp) || (isa(temp, 'string') && isscalar(temp))
            temp = char(temp);
            temp = regexp(temp, '\w+', 'match');
        else
            temp = cellstr(temp);
        end
        temp = strtrim(temp);
        isSmooth = any(strncmpi(temp, 'smooth', 6));
        isPred = any(strncmpi(temp, 'pred', 4));
        % TODO: Filter.
        isFilter = false;
    end%


    function here_checkOptions( )
        if numRuns>1 && opt.Ahead>1
            thisError = { 'VAR:CannotCombineAheadWithMultiple'
                          [ 'Cannot run filter(~) with option `Ahead=` greater than 1 ', ...
                            'on multiple parameter variants or multiple data pages'] };
            throw( exception.Base(thisError, 'error') );
        end
        if ~isPred
            opt.Ahead = 1;
        end
    end%


    function here_requestOutput( )
        if isSmooth
            YY.M2 = hdataobj(this, extendedRange, numRuns);
            if ~opt.MeanOnly
                YY.S2 = hdataobj(this, extendedRange, numRuns, ...
                    'IsVar2Std', true);
            end
        end
        if isPred
            nPred = max(numRuns, opt.Ahead);
            YY.M0 = hdataobj(this, extendedRange, nPred);
            if ~opt.MeanOnly
                YY.S0 = hdataobj(this, extendedRange, nPred, ...
                    'IsVar2Std', true);
            end
        end
        if isFilter
            YY.M1 = hdataobj(this, extendedRange, numRuns);
            if ~opt.MeanOnly
                YY.S1 = hdataobj(this, extendedRange, numRuns, ...
                    'IsVar2Std', true);
            end
        end
    end%


    function here_assignOutput( )
        if isSmooth
            Y2__ = [nan(ny, p), Y2__];
            Y2__(:, p:-1:1) = reshape(yInit__, ny, p);
            X2__ = [nan(nx, p), X__];
            E2__ = [nan(ny, p), E2__];
            hdataassign(YY.M2, i, { Y2__, X2__, E2__, [ ] } );
            if ~opt.MeanOnly
                D2__ = covfun.cov2var(iPy2);
                D2__ = [zeros(ny, p), D2__];
                hdataassign(YY.S2, i, { D2__, [ ], [ ], [ ] } );
            end
        end
        if isPred
            Y0__ = [nan(ny, p, opt.Ahead), Y0__];
            E0__ = [nan(ny, p, opt.Ahead), zeros(ny, numPeriods, opt.Ahead)];
            if opt.Ahead>1
                pos = 1 : opt.Ahead;
            else
                pos = i;
            end
            hdataassign(YY.M0, pos, { Y0__, [ ], E0__, [ ] } );
            if ~opt.MeanOnly
                D0__ = covfun.cov2var(Py0__);
                D0__ = [zeros(ny, p), D0__];
                hdataassign(YY.S0, i, { D0__, [ ], [ ], [ ] } );
            end
        end
        if isFilter
            Y1__ = [nan(ny, p), Y1__];
            X1__ = [nan(nx, p), X__];
            E1__ = [nan(ny, p), zeros(ny, numPeriods)];
            hdataassign(YY.M1, pos, { Y1__, X1__, E1__, [ ] } );
            if ~opt.MeanOnly
                D1__ = covfun.cov2var(iPy1);
                D1__ = [zeros(ny, p), D1__];
                hdataassign(YY.S1, i, { D1__, [ ], [ ], [ ] } );
            end
        end
    end%


    function here_reportMissingInit( )
        inxMissingNames = any(missingInit, 2);
        if  ~any(inxMissingNames)
            return
        end
        endogenousNames = this.EndogenousNames;
        thisWarning = { 'VAR:MissingInitial'
                        'Some initial conditions are missing from input databank for this variable: %s' };
        throw( exception.Base(thisWarning, 'warning'), ...
               endogenousNames{inxMissingNames} );
    end%


    function [yInit__, missingInit__] = here_getInitials()
        yInit__ = yInit(:, :, min(i, end));
        missingInit__ = any(isnan(reshape(yInit__, ny, p)), 2);
    end%
end%

