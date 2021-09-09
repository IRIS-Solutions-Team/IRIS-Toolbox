% Type `web Model/kalmanFilter.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function [outp, this, info] = kalmanFilter(this, inputDb, filterRange, options)

arguments
    this Model
    inputDb {locallyValidateInputDb}
    filterRange (1, :) double {validate.mustBeProperRange}
end

arguments (Repeating)
    options
end


filterRange = double(filterRange);
numBasePeriods = round(filterRange(end) - filterRange(1) + 1);
nv = countVariants(this);
[ny, ~, nb, nf, ~, ng] = sizeSolution(this.Vector);
info = struct();

%
% Resolve Kalman filter options and create a time-varying LinearSystem if
% necessary
%
[opt, timeVarying] = prepareKalmanOptions2( ...
    this, filterRange ...
    , "version", 2 ...
    , options{:} ...
);

%
% Temporarily rename quantities
%
if ~isempty(opt.Rename)
    if ~iscellstr(opt.Rename)
        opt.Rename = cellstr(opt.Rename);
    end
    this.Quantity = rename(this.Quantity, opt.Rename{:});
end

%
% Get measurement and exogenous variables
%
if ~isempty(inputDb)
    inputArray = datarequest('yg*', this, inputDb, filterRange);
else
    inputArray = nan(ny+ng, numBasePeriods);
end
numPages = size(inputArray, 3);

% Check option conflicts
hereCheckConflicts( );

% Set up data sets for Rolling=
if ~isequal(opt.Rolling, false)
    hereSetupRolling( );
end

nz = nnz(this.Quantity.IxObserved);
extendedStart = dater.plus(filterRange(1), -1);
extendedEnd = filterRange(end);
extRange = dater.colon(extendedStart, extendedEnd);
numExtPeriods = numel(extRange);

% Throw a warning if some of the data sets have no observations.
inxNaData = all( all(isnan(inputArray), 1), 2 );
if any(inxNaData)
    raise( ...
        exception.Base('Model:NoMeasurementData', 'warning') ...
        , exception.Base.alt2str(inxNaData, 'Data Set(s) ') ...
    );
end

%
% Pre-allocate requested output data
%
outputData = struct( );
herePreallocOutputData( );



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
[ info.MsePredictErrors, info.PredictErrors, info.VarScale ...
    , info.OutLikParams, info.MseOutLikParams ...
    , info.Initials, this ] ...
    = postprocessFilterOutput(this, regOutp, extRange, opt);

info.TriangularInitials = regOutp.Init;
info.MinusLogLik = minusLogLik;

%
% Post-process hdata output arguments
%
outp = hdataobj.finalize(outputData);

if ~isempty(opt.Rename)
    this.Quantity = resetNames(this.Quantity);
end

return


    function [opt, timeVarying] = hereResolveOverride( )
    end%




    function hereCheckConflicts( )
        multiple = numPages>1 || nv>1;
        if opt.Ahead>1 && multiple
            error( ...
                'Model:Filter:IllegalAhead', ...
                'Cannot use option Ahead= with multiple data sets or parameter variants.' ...
            );
        end
        if ~isequal(opt.Rolling, false) && multiple
            error( ...
                'Model:Filter:IllegalRolling', ...
                'Cannot use option Rolling= with multiple data sets or parameter variants.' ...
            );
        end
        if opt.ReturnCont && any(opt.Condition)
            error( ...
                'Model:Filter:IllegalCondition', ...
                'Cannot combine options ReturnCont= and Condition=.' ...
            );
        end
    end%




    function hereSetupRolling( )
        % No multiple data sets or parameter variants guaranteed here.
        numRolling = numel(opt.RollingColumns);
        inputArray = repmat(inputArray, 1, 1, numRolling);
        for i = 1 : numRolling
            inputArray(:, opt.RollingColumns(i)+1:end, i) = NaN;
        end
        numPages = size(inputArray, 3);
    end%




    function herePreallocOutputData( )
        % TODO Make .Output the primary option, allow for cellstr or string
        % inputs
        isPred = any(contains(opt.OutputData, "pred", "ignoreCase", true));
        isFilter = any(contains(opt.OutputData, "filter", "ignoreCase", true));
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
            outputData.M0 = hdataobj( this, extRange, numPredictions, ...
                                 'IncludeLag=', false );
            if ~opt.MeanOnly
                if opt.ReturnMedian
                    outputData.N0 = [];
                end
                if opt.ReturnStd
                    outputData.S0 = hdataobj( this, extRange, numRuns, ...
                                         'IncludeLag=', false, ...
                                         'IsVar2Std=', true );
                end
                if opt.ReturnMSE
                    outputData.Mse0 = hdataobj( );
                    outputData.Mse0.Data = nan(nb, nb, numExtPeriods, numRuns);
                    outputData.Mse0.Range = extRange;
                    outputData.Mse0.XbVector = xbVector;
                end
                if opt.ReturnCont
                    outputData.predcont = hdataobj( this, extRange, numContributions, ....
                                               'IncludeLag=', false, ...
                                               'Contributions=', @measurement );
                end
            end
        end

        %
        % Filter
        %
        if isFilter
            outputData.M1 = hdataobj( this, extRange, numRuns, ...
                                 'IncludeLag=', false );
            if ~opt.MeanOnly
                if opt.ReturnMedian
                    outputData.N1 = [];
                end
                if opt.ReturnStd
                    outputData.S1 = hdataobj( this, extRange, numRuns, ...
                                         'IncludeLag=', false, ...
                                         'IsVar2Std=', true);
                end
                if opt.ReturnMSE
                    outputData.Mse1 = hdataobj( );
                    outputData.Mse1.Data = nan(nb, nb, numExtPeriods, numRuns);
                    outputData.Mse1.Range = extRange;
                    outputData.Mse1.XbVector = xbVector;
                end
                if opt.ReturnCont
                    outputData.filtercont = hdataobj( this, extRange, numContributions, ...
                                                 'IncludeLag=', false, ...
                                                 'Contributions=', @measurement );
                end
            end
        end

        %
        % Smoother
        %
        if isSmooth
            outputData.M2 = hdataobj(this, extRange, numRuns);
            if ~opt.MeanOnly
                if opt.ReturnMedian
                    outputData.N2 = [];
                end
                if opt.ReturnStd
                    outputData.S2 = hdataobj( ...
                        this, extRange, numRuns ...
                        , 'IsVar2Std=', true ...
                    );
                end
                if opt.ReturnMSE
                    outputData.Mse2 = hdataobj( );
                    outputData.Mse2.Data = nan(nb, nb, numExtPeriods, numRuns);
                    outputData.Mse2.Range = extRange;
                    outputData.Mse2.XbVector = xbVector;
                end
                if opt.ReturnCont
                    outputData.C2 = hdataobj( ...
                        this, extRange, numContributions ...
                        , 'Contributions=', @measurement ...
                    );
                end
            end
        end
    end%
end%

%
% Local functions
%

function locallyValidateInputDb(x)
    %(
    if isempty(x) || validate.databank(x)
        return
    end
    error("Input value must be a databank or empty.");
    %)
end%

