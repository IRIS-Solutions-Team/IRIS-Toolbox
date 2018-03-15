function outputData = appendData(this, inputData, outputData, range, opt)
% appendData  Execute DbOverlay= or AppendPresample= options
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(opt.DbOverlay, false) && isequal(opt.AppendPresample, false)
    return
end

% Append only names already included in outputDataut databank
inpFields = fieldnames(inputData);
outputDataFields = fieldnames(outputData);
inputData = rmfield(inputData, setdiff(inpFields, outputDataFields));

% Overlay the input (or user-supplied) database with the simulation
% database.
if isequal(opt.DbOverlay, true)
    outputData = dboverlay(inputData, outputData);
    return
elseif isstruct(opt.DbOverlay)
    outputData = dboverlay(opt.DbOverlay, outputData);
    return
elseif isequal(opt.AppendPresample, true)
    outputData = appendPresample(this, inputData, outputData, range);
    return
elseif isstruct(opt.AppendPresample)
    outputData = appendPresample(this, opt.AppendPresample, outputData, range);
    return
end

end%


function outputData = appendPresample(this, inputData, outputData, range)
    TYPE = @int8;
    freq = round(getFrequency(range(1)));
    indexYXEG = this.Quantity.Type==TYPE(1) ...
        | this.Quantity.Type==TYPE(2) ...
        | this.Quantity.Type==TYPE(31) ...
        | this.Quantity.Type==TYPE(32) ...
        | this.Quantity.Type==TYPE(5);
    list = this.Quantity.Name(indexYXEG);
    for i = 1 : numel(list)
        ithName = list{i};
        if ~isfield(inputData, ithName) ...
            || ~isa(inputData.(ithName), 'TimeSubscriptable') ...
            || double(inputData.(ithName).Frequency)~=freq
            continue
        end
        x = outputData.(ithName);
        serialXStart = round(x.Start);
        appendData = getDataFromTo(inputData.(ithName), -Inf, serialXStart-1);
        if isempty(appendData)
            continue
        end
        serialNewStart = serialXStart - size(appendData, 1);
        sizeXData = size(x.Data);
        sizeAppendData = size(appendData);
        ncolXData = prod(sizeXData(2:end));
        ncolAppendData = prod(sizeAppendData(2:end));
        if ncolAppendData==1 && ncolXData>1
            appendData = repmat(appendData, [1, sizeXData(2:end)]);
        elseif ~isequal(sizeAppendData(2:end), sizeXData(2:end))
            continue
        end
        x.Data = [appendData; x.Data];
        x.Start = DateWrapper.fromSerial(freq, serialNewStart);
        outputData.(ithName) = x;
    end
end%

