function [this, outp, V, Delta, Pe, SCov, init, F] = filter(this, inputDb, filterRange, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('model.filter');
    pp.KeepUnmatched = true;

    addRequired(pp, 'solvedModel', @(x) isa(x, 'model') && ~isempty(x) && all(beenSolved(x)));
    addRequired(pp, 'inputDb', @(x) isempty(x) || validate.databank(x));
    addRequired(pp, 'filterRange', @validate.properRange);
end
parse(pp, this, inputDb, filterRange, varargin{:});

filterRange = double(filterRange);
numBasePeriods = round(filterRange(end) - filterRange(1) + 1);
needsOutputData = nargout>1;
nv = countVariants(this);
[ny, ~, nb, ~, ~, ng] = sizeSolution(this.Vector);

%--------------------------------------------------------------------------

%
% Resolve Kalman filter options and create a time-varying LinearSystem if
% necessary
%
[opt, timeVarying] = prepareKalmanOptions( ...
    this, filterRange ...
    , pp.UnmatchedInCell{:} ...
);


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
    'FilterRange', filterRange, ...
    'InputData', inputArray, ...
    'OutputData', outputData, ...
    'InternalAssignFunc', @hdataassign, ...
    'Options', opt ...
);
if isempty(timeVarying)
    [obj, regOutp, outputData] = implementKalmanFilter(this, argin); %#ok<ASGLU>
else
    [obj, regOutp, outputData] = implementKalmanFilter(timeVarying, argin); %#ok<ASGLU>
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
[F, Pe, V, Delta, ~, SCov, this] = kalmanFilterRegOutp(this, regOutp, extRange, opt, opt);
init = regOutp.Initials;


%
% Post-process hdata output arguments
%
outp = hdataobj.hdatafinal(outputData);

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
        if opt.Contributions && any(opt.Condition)
            error( ...
                'Model:Filter:IllegalCondition', ...
                'Cannot combine options ReturnCont and Condition.' ...
            );
        end
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
        if needsOutputData

            %
            % Prediction
            %
            if isPred
                outputData.M0 = hdataobj( this, extRange, numPredictions, ...
                                     'IncludeLag', false );
                if ~opt.MeanOnly
                    if opt.ReturnStd
                        outputData.S0 = hdataobj( this, extRange, numRuns, ...
                                             'IncludeLag', false, ...
                                             'IsVar2Std', true );
                    end
                    if opt.ReturnMse
                        outputData.Mse0 = hdataobj( );
                        outputData.Mse0.Data = nan(nb, nb, numExtPeriods, numRuns);
                        outputData.Mse0.Range = extRange;
                    end
                    if opt.Contributions
                        outputData.predcont = hdataobj( this, extRange, numContributions, ....
                                                   'IncludeLag', false, ...
                                                   'Contributions', @measurement );
                    end
                end
            end

            %
            % Filter
            %
            if isFilter
                outputData.M1 = hdataobj( this, extRange, numRuns, ...
                                     'IncludeLag', false );
                if ~opt.MeanOnly
                    if opt.ReturnStd
                        outputData.S1 = hdataobj( this, extRange, numRuns, ...
                                             'IncludeLag', false, ...
                                             'IsVar2Std', true);
                    end
                    if opt.ReturnMse
                        outputData.Mse1 = hdataobj( );
                        outputData.Mse1.Data = nan(nb, nb, numExtPeriods, numRuns);
                        outputData.Mse1.Range = extRange;
                    end
                    if opt.Contributions
                        outputData.filtercont = hdataobj( this, extRange, numContributions, ...
                                                     'IncludeLag', false, ...
                                                     'Contributions', @measurement );
                    end
                end
            end

            %
            % Smoother
            %
            if isSmooth
                outputData.M2 = hdataobj(this, extRange, numRuns);
                if ~opt.MeanOnly
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
                    end
                    if opt.Contributions
                        outputData.C2 = hdataobj( ...
                            this, extRange, numContributions ...
                            , 'Contributions', @measurement ...
                        );
                    end
                end
            end
        end
    end%
end%
