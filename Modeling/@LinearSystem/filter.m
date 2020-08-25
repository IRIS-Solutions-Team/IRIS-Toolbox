function [outputData, regOutput] = filter(this, inputData, range, varargin)
% filter  Run Kalman filter
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

range = double(range);
startRange = range(1);
endRange = range(end);
range = dater.colon(startRange, endRange);
extRange = [dater.plus(startRange, -1), range];
numPeriods = round(endRange - startRange + 1);
numExtPeriods = numPeriods + 1;

if isa(inputData, 'NumericTimeSubscriptable')
    inputArray = getDataFromTo(inputData, startRange, endRange);
    inputArray = permute(inputArray, [2, 1, 3]);
else
    inputArray = inputData;
end

kalmanOpt = prepareKalmanOptions(this, range, varargin{:});


% /////////////////////////////////////////////////////////////////////////
%
% Call Kalman filter
%
argin = struct( ...
    'InputData', inputArray, ...
    'OutputData', hereCreateOutputDataRequest(this, numExtPeriods, kalmanOpt), ...
    'OutputDataAssignFunc', @hereAssignOutputData, ...
    'Options', kalmanOpt ...
);
[~, regOutput, outputData] = kalmanFilter(this, argin);
% /////////////////////////////////////////////////////////////////////////


%
% Finalize output data
%
outputData = hereFinalizeOutputData(this, outputData, extRange);

end%


%
% Local Functions
%


function outputData = hereCreateOutputDataRequest(this, numExtPeriods, opt)
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




function field = hereAssignOutputData(field, position, newData)
    field.Y(:, :, position)  = newData{1};
    field.Xi(:, :, position) = newData{2};
    field.E(:, :, position)  = newData{3};
end%




function outputData = hereFinalizeOutputData(this, outputData, extRange)
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

