% simulateResidualModels  Project residuals using ResidualModels

function [runningDb, innovations] = simulateResidualModel(this, runningDb, range, opt)

arguments
    this Explanatory
    runningDb {validate.databank(runningDb)}
    range {validate.properRange}

    opt.BlackoutBefore {Explanatory.validateBlackout(opt.BlackoutBefore, this)} = -Inf
    opt.SkipWhenData (1, 1) {mustBeA(opt.SkipWhenData, "logical")} = false
    opt.Journal = false
end

if isempty(range)
    return
end

journal = Journal(opt.Journal, "@Explanatory/simulateResidualModel");

%--------------------------------------------------------------------------

opt.BlackoutBefore = Explanatory.resolveBlackout(opt.BlackoutBefore);

range = double(range);
numSimulationPeriods = round(range(end) - range(1) + 1);
endHistory = dater.plus(range(1), -1);
numEquations = numel(this);

for q = 1 : numEquations
    this__ = this(q);
    indent(journal, this__.InputString);
    if this__.IsIdentity
        write(journal, "Identity");
        deindent(journal);
        continue
    end

    %
    % Retrieve history/estimation data from the input time series
    %
    residualName = this__.ResidualName;
    if isfield(runningDb, residualName)
        if isa(runningDb, "Dictionary")
            series = retrieve(runningDb, residualName);
        else
            series = runningDb.(residualName);
        end
        blackoutBefore = opt.BlackoutBefore(min(q,end));
        [data, startData] = getDataFromTo(series, blackoutBefore, range(end));
        data = data(:, :);
        if ~opt.SkipWhenData
            data(end-numSimulationPeriods+1:end, :) = NaN;
        end
    else
        data = zeros(numSimulationPeriods, 1);
    end


    %
    % Determine the total number of runs, and expand data if needed
    %
    numPages = size(data, 2);
    nv = countVariants(this__);
    numRuns = max(nv, numPages);
    if numPages==1 && numRuns>1
        data = repmat(data, 1, numRuns);
    end

    residualModel = this__.ResidualModel;
    inxMissing = isnan(data);
    if ~isempty(this__.ResidualModel) && nnz(inxMissing)>0
        numPeriods = size(data, 1);
        for v = 1 : numRuns
            indent(journal, "Variant|Page:" + string(v));
            residualModel = update(residualModel, residualModel.Parameters(:, :, v));
            if residualModel.IsIdentity
                write(journal, "Identity");
            else
                if journal.IsActive
                    ar = "AR=[" + join(string(residualModel.AR), ",") + "]";
                    ma = "MA=[" + join(string(residualModel.MA), ",") + "]";
                    write(journal, ar + " " + ma);
                end

                %
                % Remove leading missing observations, find the last
                % available observation
                %
                first = find(~inxMissing(:, v), 1, "first");
                last = find(~inxMissing(:, v), 1, "last");
                if journal.IsActive
                    startData__ = dater.toDefaultString(dater.plus(startData, first-1));
                    endData__ = dater.toDefaultString(dater.plus(startData, last-1));
                    write(journal, "Data " + startData__ + ":" + endData__);
                end
                if last==numPeriods
                    continue
                end

                %
                % Convert residuals to ARMA innovations
                %
                innovations = filter(inv(residualModel), data(first:last, v));

                %
                % Add zeros on the projection horizon and convert
                % innovations back to residuals
                %
                innovations = [innovations; zeros(numPeriods-last, 1)];
                data(first:end, v) = filter(residualModel, innovations);
                if journal.IsActive
                    startSimulation__ = dater.toDefaultString(dater.plus(startData, last));
                    endSimulation__ = dater.toDefaultString(range(end));
                    write(journal, "Simulation " + startSimulation__ + ":" + endSimulation__);
                end
            end
            deindent(journal);
        end
    end


    %
    % Update the residual series in the databank
    %
    series = setData(series, startData:range(end), data);
    if isa(runningDb, "Dictionary")
        store(runningDb, residualName, series);
    else
        runningDb.(residualName) = series;
    end
    deindent(journal);
end

end%

%
% Local Functions
%

function blackout = locallyResolveBlackout(blackout, this)
    %(
    if iscell(blackout)
        blackout = [blackout{:}];
    end
    blackout = double(blackout);
    %)
end%


%
% Local Validators
%

function locallyValidateBlackout(input, this)
end%

