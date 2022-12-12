% filter  Filter data using VAR model
%{
% ## Syntax ##
%
%     [v, outputDb] = filter(v, inputDb, range, ...)
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
% __`outputDb`__ [ struct ] -
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
% __`Omega=[]`__ [ numeric | empty ] -
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

function [this, outputDb] = filter(this, inputDb, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Ahead', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
    addParameter(ip, 'Cross', true, @(x) validate.logicalScalar(x) || (validate.numericScalar(x) && x>=0 && x<=1));
    addParameter(ip, 'Deviation', false, @(x) islogical(x) && isscalar(x));
    addParameter(ip, 'MeanOnly', false, @validate.logicalScalar);
    addParameter(ip, 'Omega', [], @isnumeric);
    addParameter(ip, 'Output', 'smooth', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addParameter(ip, 'Initials', 'fixedFromData', @(x) ismember(lower(string(x)), ["fixedFromData", "asymptotic"]));
end
parse(ip, varargin{:});
opt = ip.Results;


    range = double(range);
    numPeriods = dater.rangeLength(range);
    [extdStart, extdEnd] = getExtendedRange(this, range);
    extdRange = dater.colon(extdStart, extdEnd);
    if isempty(extdRange)
        return
    end


    [isPred, isFilter, isSmooth] = here_processOptionOutput();
    nv = size(this.A, 3);
    p = this.Order;


    numG = this.NumExogenous;
    numY = this.NumEndogenous;
    numE = this.NumResiduals;
    numC = this.NumConditioning;
    inxG = [true(numG, 1); false(numY, 1); false(numE, 1); false(numC, 1)];
    inxY = [false(numG, 1); true(numY, 1); false(numE, 1); false(numC, 1)];
    inxE = [false(numG, 1); false(numY, 1); true(numE, 1); false(numC, 1)];
    inxC = [false(numG, 1); false(numY, 1); false(numE, 1); true(numC, 1)];


    GYEC = here_requestData();
    initY = GYEC(inxY, 1:p, :);
    GYEC = GYEC(:, p+1:end, :);
    numPages = size(GYEC, 3);
    numOmega = size(opt.Omega, 3);
    numRuns = max([nv, numPages, numOmega]);
    here_checkOptions();

    dataContainer = here_requestOutput();

    s = struct();
    s.invFunc = @inv;
    s.allObs = NaN;
    s.tol = 0;
    s.reuse = 0;
    s.ahead = opt.Ahead;

    % Missing initial conditions
    missingInit = false(numY, numRuns);


    %
    % Measurement equations including conditioning instrument
    %
    [Z, D] = here_getMeasurementMatrices();


    for run = 1 : numRuns
        % Get system matrices for ith parameter variant
        [A__, B__, K__, J__, ~, Omega__] = getIthSystem(this, run);

        % User-supplied covariance matrix.
        if ~isempty(opt.Omega)
            Omega__(:, :) = opt.Omega(:, :, min(run, end));
        end

        % Reduce or zero off-diagonal elements in the cov matrix of residuals
        % if requested. this only matters in VARs, not SVARs.
        if double(opt.Cross)<1
            inx = logical(eye(size(Omega__)));
            Omega__(~inx) = double(opt.Cross)*Omega__(~inx);
        end


        % Use the `allobserved` option in `@iris.mixin.Kalman/smootherForVAR` only if the cov matrix is
        % full rank. Otherwise, there is singularity.
        s.allObs = rank(Omega__)==numY;


        G__ = GYEC(inxG, :, min(run, end));
        Y__ = GYEC(inxY, :, min(run, end));
        C__ = GYEC(inxC, :, min(run, end));


        % Get initials from data
        [initY__, missingInit__] = here_getInitials();
        missingInit(:, run) = missingInit__;


        % Collect all deterministic terms: constant and exogenous inputs
        KJ__ = zeros(numY, numPeriods);
        if ~opt.Deviation
            KJ__ = KJ__ + repmat(K__, 1, numPeriods);
        end
        if numG>0
            KJ__ = KJ__ + J__*G__;
        end


        %==========================================================================
        % Run Kalman filter and smoother
        [~, ~, E2__, ~, Y2__, Py2__, ~, Y0__, Py0__, Y1__, Py1__] = iris.mixin.Kalman.smootherForVAR( ...
            this, A__, B__, KJ__, Z, D, Omega__, [], [Y__; C__], [], initY__, 0, s ...
        );
        % TODO
        E1__ = nan(numE, numPeriods);
        %==========================================================================


        % Add pre-sample periods and assign hdata
        here_assignOutput();
    end

    here_reportMissingInit();

    % Final output databank
    outputDb = hdataobj.hdatafinal(dataContainer);

return

    function [isPred, isFilter, isSmooth] = here_processOptionOutput()
        opt.Output = string(opt.Output);
        isSmooth = any(contains(opt.Output, "smooth", "ignoreCase", true));
        isPred = any(contains(opt.Output, "pred", "ignoreCase", true));
        % TODO
        isFilter = false;
    end%


    function here_checkOptions()
        if numRuns>1 && opt.Ahead>1
            exception.error([
                "VAR"
                "Cannot combine option Ahead= with multiple parameter variants or multiple data pages"
            ]);
        end
        if ~isPred
            opt.Ahead = 1;
        end
    end%


    function dataContainer = here_requestOutput()
        dataContainer = [];
        if isSmooth
            dataContainer.M2 = hdataobj(this, extdRange, numRuns);
            if ~opt.MeanOnly
                dataContainer.S2 = hdataobj( ...
                    this, extdRange, numRuns ...
                    , "isVar2Std", true ...
                );
            end
        end
        if isPred
            nPred = max(numRuns, opt.Ahead);
            dataContainer.M0 = hdataobj(this, extdRange, nPred);
            if ~opt.MeanOnly
                dataContainer.S0 = hdataobj( ...
                    this, extdRange, nPred ...
                    , "isVar2Std", true ...
                );
            end
        end
        if isFilter
            dataContainer.M1 = hdataobj(this, extdRange, numRuns);
            if ~opt.MeanOnly
                dataContainer.S1 = hdataobj( ...
                    this, extdRange, numRuns ...
                    , "isVar2Std", true ...
                );
            end
        end
    end%


    function here_assignOutput()
        if isSmooth
            Y2__ = [nan(numY, p), Y2__];
            Y2__(:, p:-1:1) = reshape(initY__, numY, p);
            X2__ = [nan(numG, p), G__];
            E2__ = [nan(numY, p), E2__];
            hdataassign(dataContainer.M2, run, {Y2__, X2__, E2__, []} );
            if ~opt.MeanOnly
                D2__ = covfun.cov2var(Py2__);
                D2__ = [zeros(numY, p), D2__];
                hdataassign(dataContainer.S2, run, {D2__, [], [], []} );
            end
        end
        if isPred
            Y0__ = [nan(numY, p, opt.Ahead), Y0__];
            E0__ = [nan(numY, p, opt.Ahead), zeros(numY, numPeriods, opt.Ahead)];
            if opt.Ahead>1
                pos = 1 : opt.Ahead;
            else
                pos = run;
            end
            hdataassign(dataContainer.M0, pos, {Y0__, [], E0__, []} );
            if ~opt.MeanOnly
                D0__ = covfun.cov2var(Py0__);
                D0__ = [zeros(numY, p), D0__];
                hdataassign(dataContainer.S0, run, {D0__, [], [], []} );
            end
        end
        if isFilter
            Y1__ = [nan(numY, p), Y1__];
            G1__ = [nan(numG, p), G__];
            E1__ = [nan(numY, p), E1__];
            hdataassign(dataContainer.M1, pos, {Y1__, G1__, E1__, []} );
            if ~opt.MeanOnly
                D1__ = covfun.cov2var(Py1__);
                D1__ = [zeros(numY, p), D1__];
                hdataassign(dataContainer.S1, run, {D1__, [], [], []} );
            end
        end
    end%


    function here_reportMissingInit()
        %(
        inxMissingNames = any(missingInit, 2);
        if  ~any(inxMissingNames)
            return
        end
        exception.warning([
            "VAR", "Some initial conditions are missing for this variable: %s"
        ], this.EndogenousNames(inxMissingNames));
        %)
    end%


    function [initY__, missingInit__] = here_getInitials()
        initY__ = initY(:, :, min(run, end));
        initY__ = reshape(fliplr(initY__), [], 1);
        missingInit__ = any(isnan(reshape(initY__, numY, p)), 2);
    end%


    function GYEC = here_requestData()
        %(
        requiredNames = this.ExogenousNames;
        optionalNames = string.empty(1, 0);
        if strcmpi(opt.Initials, 'fixedFromData')
            requiredNames = [requiredNames, this.EndogenousNames];
        else
            optionalNames = [optionalNames, this.EndogenousNames];
        end
        optionalNames = [this.ResidualNames, this.ConditioningNames];

        allowedNumeric = string.empty(1, 0);
        allowedLog = string.empty(1, 0);
        context = "";
        dbInfo = checkInputDatabank( ...
            this, inputDb, extdRange ...
            , requiredNames, optionalNames ...
            , allowedNumeric, allowedLog ...
            , context ...
        );

        GYEC = requestData( ...
            this, dbInfo, inputDb ...
            , [requiredNames, optionalNames], extdRange ...
        );
        %)
    end%


    function [Z, D] = here_getMeasurementMatrices()
        %(
        if isempty(this.Zi)
            Z = eye(numY);
            D = [];
        else
            Z = [eye(numY, numY*p); this.Zi(:, 2:end)];
            D = [];
            if ~opt.Deviation && any(this.Zi(:, 1)~=0)
                D = [zeros(numY, 1); this.Zi(:, 1)];
            end
        end
        %)
    end%
end%

