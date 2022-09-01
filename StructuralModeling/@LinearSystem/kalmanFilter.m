
function [outputData, this, info] = kalmanFilter(this, inputData, range, varargin)

    range = double(range);
    startRange = range(1);
    endRange = range(end);
    range = dater.colon(startRange, endRange);
    extRange = [dater.plus(startRange, -1), range];
    numPeriods = round(endRange - startRange + 1);
    numExtPeriods = numPeriods + 1;

    opt = prepareKalmanOptions2(this, range, varargin{:});
    inputArray = prepareKalmanData(this, inputData, range, opt.WhenMissing);


    %=========================================================================
    argin = struct();
    argin.InputData = inputArray;
    argin.OutputData = local_createOutputDataRequest(this, numExtPeriods, opt);
    argin.InternalAssignFunc = @local_assignOutputData;
    argin.Options = opt;
    argin.FilterRange = range;

    [minusLogLik, regOutput, outputData] = implementKalmanFilter(this, argin);
    %=========================================================================


    %
    % Postprocess regular (non-hdata) output arguments; update the std
    % parameters in the model object if `Relative=' true`
    %
    [info, this] = postprocessKalmanOutput(this, minusLogLik, regOutput, extRange, opt);


    %
    % Finalize output data
    %
    outputData = local_finalizeOutputData(this, outputData, extRange);

end%


%
% Local Functions
%

function outputData = local_createOutputDataRequest(this, numExtPeriods, opt)
    ny = this.NumY;
    nxi = this.NumXi;
    nv = this.NumV;
    nw = this.NumW;
    ne = nv + nw;
    
    template = struct( );
    template.Y  = nan(ny,  numExtPeriods);
    template.Xi = nan(nxi, numExtPeriods);
    template.E  = nan(ne,  numExtPeriods);

    outputData = struct( );
    outputData.M0 = template;
    outputData.M1 = template;
    outputData.M2 = template;
end%


function field = local_assignOutputData(field, position, newData)
    field.Y(:, :, position)  = newData{1};
    field.Xi(:, :, position) = newData{2};
    field.E(:, :, position)  = newData{3};
end%


function outputData = local_finalizeOutputData(this, outputData, extRange)
    nv = this.NumV;
    template = Series(extRange(1), 0);
    list = {{'M0', 'PredictMean'}, {'M1', 'FilterMean'}, {'M2', 'SmoothMean'}};
    convert = @(x) fill(template, permute(x, [2, 1, 3]));
    for i = 1 : numel(list)
        originalName = list{i}{1};
        newName = list{i}{2};
        sub = outputData.(originalName);
        sub0 = sub;
        sub.Y = convert(sub.Y);
        sub.Xi = convert(sub.Xi);
        sub.V = convert(sub.E(1:nv, :, :));
        sub.W = convert(sub.E(nv+1:end, :, :));
        outputData.(newName) = sub;
        outputData = rmfield(outputData, originalName);
    end
end% 

