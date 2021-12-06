% Type `web Model/kalmanFilter.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [outputDb, this, info] = kalmanFilter(this, inputDb, baseRange, options)

arguments
    this Model
    inputDb {locallyValidateInputDb}
    baseRange (1, :) double {validate.mustBeProperRange}
end

arguments (Repeating)
    options
end


baseRange = double(baseRange);
numBasePeriods = round(baseRange(end) - baseRange(1) + 1);
nv = countVariants(this);
[ny, ~, nb, nf, ~, ng] = sizeSolution(this.Vector);
info = struct();


%
% Resolve Kalman filter options and create a time-varying LinearSystem if
% necessary
%
[options, timeVarying] ...
    = prepareKalmanOptions2(this, baseRange, options{:});


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
hereCheckConflicts( );

% Set up data sets for Rolling=
if ~isequal(options.Rolling, false)
    hereSetupRolling( );
end

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

options = locallyResolveReturnOptions(options);

%
% Pre-allocate requested output data
%
outputData = struct( );
[returnsPredict, returnsUpdate, returnsSmooth] = herePreallocOutputData( );



%=========================================================================
argin = struct( ...
    'InputData', inputArray, ...
    'OutputData', outputData, ...
    'OutputDataAssignFunc', @hdataassign, ...
    'Options', options ...
);
if isempty(timeVarying)
    [minusLogLik, regOutp, outputData] = implementKalmanFilter(this, argin); %#ok<ASGLU>
else
    [minusLogLik, regOutp, outputData] = implementKalmanFilter(timeVarying, argin); %#ok<ASGLU>
end
%=========================================================================



% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nv<regOutp.NLoop && (options.Relative || ~isempty(regOutp.Delta))
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
] = postprocessFilterOutput(this, regOutp, extRange, options);

info.TriangularInitials = regOutp.Init;
info.MinusLogLik = minusLogLik;

%
% Post-process hdata output arguments
%
outputDb = hdataobj.finalize(outputData, options);
if options.FlattenOutput
    outputDb = locallyFlattenOutput(outputDb);
end

return

    function hereCheckConflicts( )
        %(
        multiple = numPages>1 || nv>1;
        if options.Ahead>1 && multiple
            error( ...
                'Kalman:IllegalAhead', ...
                'Cannot use option Ahead= with multiple data sets or parameter variants.' ...
            );
        end
        if ~isequal(options.Rolling, false) && multiple
            error( ...
                'Kalman:IllegalRolling', ...
                'Cannot use option Rolling= with multiple data sets or parameter variants.' ...
            );
        end
        if options.ReturnBreakdown && any(options.Condition)
            error( ...
                'Kalman:IllegalCondition', ...
                'Cannot combine options ReturnBreakdown= and Condition=.' ...
            );
        end
        %)
    end%


    function hereSetupRolling( )
        %(
        % No multiple data sets or parameter variants guaranteed here.
        numRolling = numel(options.RollingColumns);
        inputArray = repmat(inputArray, 1, 1, numRolling);
        for i = 1 : numRolling
            inputArray(:, options.RollingColumns(i)+1:end, i) = NaN;
        end
        numPages = size(inputArray, 3);
        %)
    end%


    function [isPred, isUpdate, isSmooth] = herePreallocOutputData( )
        %(
        isPred = any(contains(options.OutputData, "pred", "ignoreCase", true));
        isUpdate = any(contains(options.OutputData, ["update", "filter"], "ignoreCase", true));
        isSmooth = any(contains(options.OutputData, "smooth", "ignoreCase", true));
        numRuns = max(numPages, nv);
        numPredictions = max(numRuns, options.Ahead);
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
            if options.ReturnMedian
                outputData.N0 = [];
            end
            if options.ReturnStd
                outputData.S0 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IncludeLag', false ...
                    , 'IsVar2Std', true ...
                );
            end
            if options.ReturnMSE
                outputData.Mse0 = hdataobj( );
                outputData.Mse0.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse0.Range = extRange;
                outputData.Mse0.XbVector = xbVector;
            end
            if options.ReturnBreakdown
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
            if options.ReturnMedian
                outputData.N1 = [];
            end
            if options.ReturnStd
                outputData.S1 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IncludeLag', false ...
                    , 'IsVar2Std', true ...
                );
            end
            if options.ReturnMSE
                outputData.Mse1 = hdataobj( );
                outputData.Mse1.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse1.Range = extRange;
                outputData.Mse1.XbVector = xbVector;
            end
            if options.ReturnBreakdown
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
            if options.ReturnMedian
                outputData.N2 = [];
            end
            if options.ReturnStd
                outputData.S2 = hdataobj( ...
                    this, extRange, numRuns ...
                    , 'IsVar2Std', true ...
                );
            end
            if options.ReturnMSE
                outputData.Mse2 = hdataobj( );
                outputData.Mse2.Data = nan(nb, nb, numExtPeriods, numRuns);
                outputData.Mse2.Range = extRange;
                outputData.Mse2.XbVector = xbVector;
            end
            if options.ReturnBreakdown
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

function options = locallyResolveReturnOptions(options)
    %(
    options.ReturnStd = options.ReturnStd && ~options.MeanOnly && ~options.MedianOnly;
    options.ReturnMSE = options.ReturnMSE && ~options.MeanOnly && ~options.MedianOnly;
    options.ReturnBreakdown = options.ReturnBreakdown && ~options.MeanOnly && ~options.MedianOnly;
    options.ReturnMedian = options.ReturnMedian && ~options.MeanOnly;
    %)
end%


function outputDb = locallyFlattenOutput(outputDb)
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

function locallyValidateInputDb(x)
    %(
    if isempty(x) || validate.databank(x)
        return
    end
    error("Input value must be a databank or empty.");
    %)
end%

