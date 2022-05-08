
%{
---
title: prepareLinearSystem
---

# `prepareLinearSystem`

{== Prepare LinearSystem object from Model object ==}


## Syntax

    ls = prepareLinearSystem(model, filterRange, override, multiply, ___)


## Input arguments

__`model`__ [ Model ]
>
> Model from which a time-varying linear system, `ls`, will be created for
> the time-varying parameters and stdcorrs.
> 

__`filterRange`__ [ Dater ]
> 
> Date range for which the time-varying linear system `ls` will be created.
> 

__`override`__ [ struct | empty ]
> 
> Databank with time-varying parameters and stdcorrs.
> 

__`multiply`__ [ struct | empty ]
>
> Databank with time-varying mutlipliers that will be applied to stdcorrs.
> 

## Output arguments

__`ls`__ [ LinearSystem ]
>
> A time-varying linear system object that can be used to run a time-varying
> Kalman filter.
>


## Options

__`Variant=1`__ [ numeric ]
>
> Select this parameter variant if the input `model` has multiple variants.
>

__`ReturnEarly=false`__ [ `true` | `false` ]
>
> Return early with `ls = []` whenever no time-varying parameters or
> stdcorrs are specified in `override` or `multiply`
>

## Description


## Examples

%}

%---8<---


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team


% >=R2019b
%(
function [obj, initCond] = prepareLinearSystem(this, filterRange, override, multiply, opt)

    arguments
        this Model

        filterRange (1, :) double {validate.mustBeProperRange}
        override = []
        multiply = []

        opt.Variant (1, 1) double = 1
        opt.ReturnEarly (1, 1) logical = false
    end
%)
% >=R2019b


% <=R2019a
%{
function [obj, initCond] = prepareLinearSystem(this, filterRange, override, multiply, varargin)

    persistent ip
    if isempty(ip)
        ip = inputParser(); 
        addParameter(ip, 'Variant', 1);
        addParameter(ip, 'ReturnEarly', false);
    end
    parse(ip, varargin{:});
    opt = ip.Results;
%}
% <=R2019a


    inxP = getIndexByType(this.Quantity, 4);
    numP = nnz(inxP);
    filterRange = double(filterRange);
    baseStart = filterRange(1);
    baseEnd = filterRange(end);
    numBasePeriods = round(baseEnd - baseStart + 1);
    v = opt.Variant;

    here_checkNumVariants( )

    %
    % If no parameters are time varying, do not create LinearSystem and return
    % immediately
    %
    overrideParams = varyParams(this, filterRange, override);
    if isempty(overrideParams) && opt.ReturnEarly
        obj = [ ];
        initCond = { };
        return
    end

    %
    % Initialize LinearSystem
    %
    [numY, numXi, numXib, numXif, numE, ~, ~, numV, numW] = sizeSolution(this);
    inxV = [true(1, numV), false(1, numW)];
    inxW = [false(1, numV), true(1, numW)];

    defaultParams = this.Variant.Values(1, inxP, v);
    if ~isempty(overrideParams) && size(overrideParams, 2)<numBasePeriods
        overrideParams(:, end+1) = defaultParams;
    end
    [overrideParams, equalsDefaultParams, equalsPreviousParams] = ...
        local_overrideAndMultiply(overrideParams, [], defaultParams);

    optionsHere = struct('Clip', true, 'Presample', false);
    [overrideStdCorr, ~, multiplyStdCorr] = varyStdCorr(this, filterRange, override, multiply, optionsHere);
    defaultStdCorr = this.Variant.StdCorr(1, :, v);
    if ~isempty(overrideStdCorr) && size(overrideStdCorr, 2)<numBasePeriods
        overrideStdCorr(:, end+1) = defaultStdCorr;
    end
    [overrideStdCorr, equalsDefaultStdCorr, equalsPreviousStdCorr] ...
        = local_overrideAndMultiply(overrideStdCorr, multiplyStdCorr, defaultStdCorr);

    numSystemPeriods = max(size(overrideParams, 2), size(overrideStdCorr, 2));
    obj = LinearSystem([numXi, numXib, numV, numY, numW], numSystemPeriods);

    %
    % Assign state space matrices
    %
    here_assignSspaceMatrices( )

    %
    % Assign covariance matrices
    %
    here_assignCovarianceMatrices( )

    %
    % Initial condition
    %
    initCond = { };
    if nargout>=2
        initCond = here_initialize( );
    end

    obj.Tolerance = this.Tolerance;

return


    function here_checkNumVariants( )
        if countVariants(this)~=1
            thisError = [
                "Model:SingleVariantOnly"
                "LinearSystem object can be prepared only from Model object "
                "with a single parameter variant."
            ];
            throw(exception.Base(thisError, 'error'));
        end
    end%




    function here_assignSspaceMatrices( )
        keepExpansion = false;
        keepTriangular = false;

        tempModel = this;
        tempModel.Update = here_createUpdateStruct( );

        [defaultMatrices{1:6}] = getSolutionMatrices(this, v, keepExpansion, keepTriangular);
        defaultMatrices{2} = defaultMatrices{2}(:, inxV);
        defaultMatrices{5} = defaultMatrices{5}(:, inxW);
        previousMatrices = NaN;

        obj = assign(obj, 0, defaultMatrices, missing);

        for t = 1 : size(overrideParams, 2)
            if equalsPreviousParams(t)
                matrices__ = previousMatrices;
            elseif equalsDefaultParams(t)
                matrices__ = defaultMatrices;
            else
                tempModel = update(tempModel, overrideParams(:, t), v);
                [matrices__{1:6}] = getSolutionMatrices(tempModel, v, keepExpansion, keepTriangular);
                matrices__{2} = matrices__{2}(:, inxV);
                matrices__{5} = matrices__{5}(:, inxW);
            end
            obj = assign(obj, t, matrices__, missing);
            previousMatrices = matrices__;
        end

        return

            function update = here_createUpdateStruct( )
                update = struct( );
                update.PosOfValues = find(inxP);
                update.PosOfStdCorr = double.empty(1, 0);
                update.Values = this.Variant.Values(1, :, v);
                update.StdCorr = this.Variant.StdCorr(1, :, v);
                update.Steady = prepareSteady(this, "run", false);
                update.CheckSteady = prepareCheckSteady(this, "run", false);
                update.Solve = prepareSolve(this, "silent", true);
            end%
    end%




    function here_assignCovarianceMatrices( )
        Omega = covfun.stdcorr2cov(defaultStdCorr, numE);
        defaultMatrices = { Omega(inxV, inxV), Omega(inxW, inxW) };
        previousMatrices = NaN;

        obj = assign(obj, 0, missing, defaultMatrices);

        for t = 1 : size(overrideStdCorr, 2)
            if equalsPreviousStdCorr(t)
                matrices__ = previousMatrices;
            elseif equalsDefaultStdCorr(t)
                matrices__ = defaultMatrices;
            else
                Omega__ = covfun.stdcorr2cov(overrideStdCorr(:, t), numE);
                matrices__ = { Omega__(inxV, inxV), Omega__(inxW, inxW) };
            end
            obj = assign(obj, t, missing, matrices__);
            previousMatrices = matrices__;
        end
    end%




    function initCond = here_initialize( )
        s = struct();
        s.MEASUREMENT_MATRIX_TOLERANCE = this.MEASUREMENT_MATRIX_TOLERANCE;
        s.DIFFUSE_SCALE = this.DIFFUSE_SCALE;
        s.OBJ_FUNC_PENALTY = this.OBJ_FUNC_PENALTY;
        requiredForward = 0;
        [T, R, k, Z, H, d, s.U, Zb, s.InxV, s.InxW, s.NumUnitRoots, s.InxInit] = getIthKalmanSystem(this, v, requiredForward);
        [numXi, numXiB] = size(T);
        numXiF = numXi - numXiB;
        inxXiB = [false(1, numXiF), true(1, numXiB)];
        s.NumE = numE;
        s.Ta = T(inxXiB, :);
        s.ka = k(inxXiB, :);
        s.Ra = R(inxXiB, :);
        s.Omg = getIthOmega(this, v);

        init = 'Steady';
        unitRootInitials = 'ApproxDiffuse';
        s = iris.mixin.Kalman.initialize(s, init, unitRootInitials);
        initCond = {s.InitMean, s.InitMseReg, s.InitMseInf};
    end%
end%


%
% Local Functions
%


function [override, equalsDefault, equalsPrevious] = local_overrideAndMultiply(override, multiply, default)
    numPeriods = max(size(override, 2), size(multiply, 2));
    addPeriods = numPeriods - size(override, 2);
    if addPeriods>0
        override = [override, nan(size(override, 1), addPeriods)];
    end
    equalsDefault = true(1, numPeriods);
    for t = 1 : size(override, 2)
        inxNaN = isnan(override(:, t));
        if any(inxNaN)
            override(inxNaN, t) = default(inxNaN);
        end
        if any(~inxNaN)
            equalsDefault(t) = false;
        end
        if t<=size(multiply, 2)
            inxMultiply = ~isnan(multiply(:, t));
            if any(inxMultiply)
                override(inxMultiply, t) = multiply(inxMultiply, t) .* override(inxMultiply, t);
                equalsDefault(t) = false;
            end
        end
    end
    equalsPrevious = [false, all(diff(override, 1, 2)==0, 1)];
    lastNotEqual = find(~equalsPrevious, 1, 'Last');
    if ~isempty(lastNotEqual)
        override(:, lastNotEqual+1:end) = [ ];
        equalsPrevious(:, lastNotEqual+1:end) = [ ];
    end
end%

