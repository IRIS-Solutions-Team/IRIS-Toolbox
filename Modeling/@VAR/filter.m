function [this, outputDatabank] = filter(this, inputDatabank, range, varargin)
% filter  Filter data using VAR model
%{
% ## Syntax ##
%
%     [v, outputDatabank] = filter(v, inputDatabank, range, ...)
%
% 
% ## Input Arguments ##
%
% __`v`__ [ VAR ] -
% Input VAR object.
%
% __`inputDatabank`__ [ struct ] - 
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
% -Copyright (c) 2007-2020 IRIS Solutions Team

persistent parser
if isempty(parser)
    parser = extend.InputParser('VAR.filter');
    % Required arguments
    addRequired(parser, 'VAR', @(x) isa(x, 'VAR'));
    addRequired(parser, 'inputDatabank', @validate.databank);
    addRequired(parser, 'range', @DateWrapper.validateProperRangeInput);
    % Name-value options
    addParameter(parser, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    addParameter(parser, 'Cross', true, @(x) validate.logicalScalar(x) || (validate.numericScalar(x) && x>=0 && x<=1));
    addParameter(parser, {'Deviation', 'Deviations'}, false, @(x) islogical(x) && isscalar(x));
    addParameter(parser, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(parser, 'Omega', [ ], @isnumeric);
    addParameter(parser, 'Output', 'smooth', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
end
parse(parser, this, inputDatabank, range, varargin{:});
opt = parser.Options;

[isPred, isFilter, isSmooth] = hereProcessOptionOutput( );

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);
nx = length(this.NamesExogenous);
isX = nx>0;
isConst = ~opt.Deviation;

range = range(1) : range(end);
extendedRange = range(1)-p : range(end);

if length(range)<2
    utils.error('iris:VAR:filter', 'Invalid range specification.') ;
end

% Include pre-sample
req = datarequest('y*, x*', this, inputDatabank, extendedRange);
extendedRange = req.Range;
y = req.Y;
x = req.X;

numPeriods = length(range);
yInit = y(:, 1:p, :);
y = y(:, p+1:end, :);
x = x(:, p+1:end, :);

numPagesY = size(yInit, 3);
numPagesX = size(x, 3);
nOmg = size(opt.Omega, 3);

numRuns = max([nv, numPagesY, numPagesX, nOmg]);
hereCheckOptions( );

% Stack initial conditions.
yInit = yInit(:, p:-1:1, :);
yInit = reshape(yInit(:), ny*p, numRuns);

YY = [ ];
hereRequestOutput( );

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
    [iA, iB, iK, iJ, iOmg] = mysystem(this, i);
    
    % User-supplied covariance matrix.
    if ~isempty(opt.Omega)
        iOmg(:, :) = opt.Omega(:, :, min(i, end));
    end
    
    % Reduce or zero off-diagonal elements in the cov matrix of residuals
    % if requested. this only matters in VARs, not SVARs.
    if double(opt.Cross)<1
        inx = logical(eye(size(iOmg)));
        iOmg(~inx) = double(opt.Cross)*iOmg(~inx);
    end

    % Use the `allobserved` option in `varsmoother` only if the cov matrix is
    % full rank. Otherwise, there is singularity.
    s.allObs = rank(iOmg)==ny;
    
    iY = y(:, :, min(i, end));
    iX = x(:, :, min(i, end));

    if i<=numPagesY
        iYInit = yInit(:, :, min(i, end));
        temp = reshape(iYInit, ny, p);
        missingInit(:, i) = any(isnan(temp), 2);
    end
    
    % Collect all deterministic terms: constant and exogenous inputs
    iKJ = zeros(ny, numPeriods);
    if isConst
        iKJ = iKJ + iK(:, ones(1, numPeriods));
    end    
    if isX
        iKJ = iKJ + iJ*iX;
    end
    
    % Run Kalman filter and smoother
    [~, ~, iE2, ~, iY2, iPy2, ~, iY0, iPy0, iY1, iPy1] = timedom.varsmoother( ...
        iA, iB, iKJ, Z, [ ], iOmg, [ ], iY, [ ], iYInit, 0, s);
    
    % Add pre-sample periods and assign hdata
    hereAssignOutput( );
end

hereReportMissingInit( );

% Final output databank
outputDatabank = hdataobj.hdatafinal(YY);

return


    function [isPred, isFilter, isSmooth] = hereProcessOptionOutput( )
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



    
    function hereCheckOptions( )
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



    
    function hereRequestOutput( )
        if isSmooth
            YY.M2 = hdataobj(this, extendedRange, numRuns);
            if ~opt.MeanOnly
                YY.S2 = hdataobj(this, extendedRange, numRuns, ...
                    'IsVar2Std=', true);
            end
        end
        if isPred
            nPred = max(numRuns, opt.Ahead);
            YY.M0 = hdataobj(this, extendedRange, nPred);
            if ~opt.MeanOnly
                YY.S0 = hdataobj(this, extendedRange, nPred, ...
                    'IsVar2Std=', true);
            end
        end
        if isFilter
            YY.M1 = hdataobj(this, extendedRange, numRuns);
            if ~opt.MeanOnly
                YY.S1 = hdataobj(this, extendedRange, numRuns, ...
                    'IsVar2Std=', true);
            end
        end
    end%




    function hereAssignOutput( )
        if isSmooth
            iY2 = [nan(ny, p), iY2];
            iY2(:, p:-1:1) = reshape(iYInit, ny, p);
            iX2 = [nan(nx, p), iX];
            iE2 = [nan(ny, p), iE2];
            hdataassign(YY.M2, i, { iY2, iX2, iE2, [ ] } );
            if ~opt.MeanOnly
                iD2 = covfun.cov2var(iPy2);
                iD2 = [zeros(ny, p), iD2];
                hdataassign(YY.S2, i, { iD2, [ ], [ ], [ ] } );
            end
        end
        if isPred
            iY0 = [nan(ny, p, opt.Ahead), iY0];
            iE0 = [nan(ny, p, opt.Ahead), zeros(ny, numPeriods, opt.Ahead)];
            if opt.Ahead>1
                pos = 1 : opt.Ahead;
            else
                pos = i;
            end
            hdataassign(YY.M0, pos, { iY0, [ ], iE0, [ ] } );
            if ~opt.MeanOnly
                iD0 = covfun.cov2var(iPy0);
                iD0 = [zeros(ny, p), iD0];
                hdataassign(YY.S0, i, { iD0, [ ], [ ], [ ] } );
            end
        end
        if isFilter
            iY1 = [nan(ny, p), iY1];
            iX1 = [nan(nx, p), iX];
            iE1 = [nan(ny, p), zeros(ny, numPeriods)];
            hdataassign(YY.M1, pos, { iY1, iX1, iE1, [ ] } );
            if ~opt.MeanOnly
                iD1 = covfun.cov2var(iPy1);
                iD1 = [zeros(ny, p), iD1];
                hdataassign(YY.S1, i, { iD1, [ ], [ ], [ ] } );
            end
        end
    end%




    function hereReportMissingInit( )
        inxMissingNames = any(missingInit, 2);
        if  ~any(inxMissingNames)
            return
        end
        endogenousNames = this.NamesEndogenous;
        thisWarning = { 'VAR:MissingInitial'
                        'Some initial conditions are missing from input databank for this variable: %s' };
        throw( exception.Base(thisWarning, 'warning'), ...
               endogenousNames{inxMissingNames} );
    end%
end%

