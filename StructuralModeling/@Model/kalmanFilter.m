% Type `web Model/kalmanFilter.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team


function [outputDb, this, info] = kalmanFilter(this, inputDb, baseRange, varargin)

% >=R2019b
%(
arguments
    this Model
    inputDb {local_validateInputDb}
    baseRange (1, :) double {validate.mustBeProperRange}
end

arguments (Repeating)
    varargin
end
%)
% >=R2019b


baseRange = double(baseRange);
numBasePeriods = round(baseRange(end) - baseRange(1) + 1);
nv = countVariants(this);
[ny, ~, nb, nf, ~, ng] = sizeSolution(this.Vector);
info = struct();


%
% Resolve Kalman filter opt and create a time-varying LinearSystem if
% necessary
%
[opt, timeVarying] = prepareKalmanOptions2(this, baseRange, varargin{:});


%
% Get measurement and exogenous variables
%
if ~isempty(inputDb)
    requiredNames = string.empty(1, 0);
    inx = getIndexByType(this.Quantity, 1, 5);
    optionalNames = string(this.Quantity.Name(inx));
    allowedNumeric = @all;
    logNames = optionalNames(this.Quantity.InxLog(inx));
    context = "";
    dbInfo = checkInputDatabank( ...
        this, inputDb, baseRange ...
        , requiredNames, optionalNames ...
        , allowedNumeric, logNames ...
        , context ...
    );
    inputArray = requestData( ...
        this, dbInfo, inputDb ...
        , [requiredNames, optionalNames], baseRange ...
    );
    inputArray = ensureLog(this, dbInfo, inputArray);
else
    inputArray = nan(ny+ng, numBasePeriods);
end
numPages = size(inputArray, 3);

% Check option conflicts
here_checkConflicts( );

nz = nnz(this.Quantity.IxObserved);
extendedStart = dater.plus(baseRange(1), -1);
extendedEnd = baseRange(end);
extRange = dater.colon(extendedStart, extendedEnd);
numExtPeriods = numel(extRange);

% Throw a warning if some of the data sets have no observations.
inxNaData = all(all(isnan(inputArray), 1), 2);
if any(inxNaData)
    raise( ...
        exception.Base('Model:NoMeasurementData', 'warning') ...
        , exception.Base.alt2str(inxNaData, 'Data Set(s) ') ...
    );
end

opt = local_resolveReturnOptions(opt);

%
% Pre-allocate requested output data
%
outputData = struct( );
[returnsPredict, returnsUpdate, returnsSmooth] = here_preallocOutputData( );



%=========================================================================
argin = struct( ...
    'InputData', inputArray, ...
    'OutputData', outputData, ...
    'OutputDataAssignFunc', @hdataassign, ...
    'Options', opt ...
);
if isempty(timeVarying)
    [minusLogLik, regOutp, outputData] = implementKalmanFilter(this, argin); %#ok<ASGLU>
else
    [minusLogLik, regOutp, outputData] = implementKalmanFilter(timeVarying, argin); %#ok<ASGLU>
end
%=========================================================================



% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nv<regOutp.NLoop && (opt.Relative || ~isempty(regOutp.Delta))
    this = alter(this, regOutp.NLoop);
end

%
% Postprocess regular (non-hdata) output arguments; update the std
% parameters in the model object if `Relative=' true`
%
[ ...
    info.MsePredictErrors, info.PredictError, info.VarScale ...
    , info.OutLikParams, info.MseOutLikParams ...
    , info.Initials, this ...
] = postprocessFilterOutput(this, regOutp, extRange, opt);

info.TriangularInitials = regOutp.Initials;
info.MinusLogLik = minusLogLik;

%
% Post-process hdata output arguments
%
outputDb = hdataobj.finalize(outputData, opt);
if opt.FlatOutput
    outputDb = local_flatOutput(outputDb);
end

return

    function here_checkConflicts( )
        %(
        multiple = numPages>1 || nv>1;
        if opt.Ahead>1 && multiple
            error( ...
                'Kalman:IllegalAhead', ...
                'Cannot use option Ahead= with multiple data sets or parameter variants.' ...
            );
        end
        if opt.Contributions && any(opt.Condition)
            error( ...
                'Kalman:IllegalCondition', ...
                'Cannot combine opt Contributions and Condition.' ...
            );
        end
        %)
    end%


    function [isPred, isUpdate, isSmooth] = here_preallocOutputData( )
        %(
        isPred = any(contains(opt.OutputData, "pred", "ignoreCase", true));
        isUpdate = any(contains(opt.OutputData, ["update", "filter"], "ignoreCase", true));
        isSmooth = any(contains(opt.OutputData, "smooth", "ignoreCase", true));
        numRuns = max(numPages, nv);
        numPredictions = max(numRuns, opt.Ahead);
        numContributions = max(ny, nz);
        xbVector = access(this, "transition-vector");
        xbVector = xbVector(nf+1:end);

        %
        % Prediction
        %
        if isPred
            outputData.M0 = hdataobj( ...
                this, extRange, numPredictions ...
                , "IncludeLag", true ...
            );
            if opt.ReturnMedian
                outputData.N0 = [];
            end
            if opt.ReturnStd
                outputData.S0 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IncludeLag', false ...
                    , 'IsVar2Std', true ...
                );
            end
            if opt.ReturnMse
                outputData.Mse0 = hdataobj( );
                outputData.Mse0.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse0.Range = extRange;
                outputData.Mse0.XbVector = xbVector;
            end
            if opt.Contributions
                outputData.C0 = hdataobj( ...
                    this, extRange, numContributions ....
                    , 'IncludeLag', false ...
                    , 'Contributions', @measurement ...
                );
            end
        end

        %
        % Update
        %
        if isUpdate
            outputData.M1 = hdataobj( ...
                this, extRange, numRuns ...
                , 'IncludeLag', true ...
            );
            if opt.ReturnMedian
                outputData.N1 = [];
            end
            if opt.ReturnStd
                outputData.S1 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IncludeLag', false ...
                    , 'IsVar2Std', true ...
                );
            end
            if opt.ReturnMse
                outputData.Mse1 = hdataobj( );
                outputData.Mse1.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse1.Range = extRange;
                outputData.Mse1.XbVector = xbVector;
            end
            if opt.Contributions
                outputData.C1 = hdataobj( ...
                    this, extRange, numContributions ...
                    , 'IncludeLag', false ...
                    , 'Contributions', @measurement  ...
                );
            end
        end

        %
        % Smoother
        %
        if isSmooth
            outputData.M2 = hdataobj(this, extRange, numRuns);
            if opt.ReturnMedian
                outputData.N2 = [];
            end
            if opt.ReturnStd
                outputData.S2 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IsVar2Std', true ...
                );
            end
            if opt.ReturnMse
                outputData.Mse2 = hdataobj( );
                outputData.Mse2.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse2.Range = extRange;
                outputData.Mse2.XbVector = xbVector;
            end
            if opt.Contributions
                outputData.C2 = hdataobj( ...
                    this, extRange, numContributions ...
                    , 'Contributions', @measurement ...
                );
            end
        end
        %)
    end%
end%

%
% Local functions
%

function opt = local_resolveReturnOptions(opt)
    %(
    opt.ReturnStd = opt.ReturnStd && ~opt.MeanOnly && ~opt.MedianOnly;
    opt.ReturnMse = opt.ReturnMse && ~opt.MeanOnly && ~opt.MedianOnly;
    opt.Contributions = opt.Contributions && ~opt.MeanOnly && ~opt.MedianOnly;
    opt.ReturnMedian = opt.ReturnMedian && ~opt.MeanOnly;
    %)
end%


function outputDb = local_flatOutput(outputDb)
    %(
    for p = databank.fieldNames(outputDb)
        fields = databank.fieldNames(outputDb.(p));
        if isempty(fields)
            outputDb = rmfield(outputDb, p);
        elseif numel(fields)==1
            outputDb.(p) = outputDb.(p).(fields);
        end
    end

    fields = databank.fieldNames(outputDb);
    if numel(fields)==1
        outputDb = outputDb.(fields);
    end
    %)
end%

%
% Local validators
%

function local_validateInputDb(x)
    %(
    if isempty(x) || validate.databank(x)
        return
    end
    error("Input value must be a databank or empty.");
    %)
end%

