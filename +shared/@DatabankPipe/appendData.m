function outputData = appendData(this, inputData, outputData, range, varargin)
% appendData  Append presample or postsample data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


if numel(varargin)==2
    presample = varargin{1};
    postsample = varargin{2};
elseif numel(varargin)==1 && validate.databank(varargin{1})
    opt = varargin{1};
    if isfield(opt, 'DbOverlay') && ~isequal(opt.DbOverlay, false)
        presample = opt.DbOverlay;
        postsample = opt.DbOverlay;
    else
        presample = opt.AppendPresample;
        postsample = opt.AppendPostsample;
    end
end

%--------------------------------------------------------------------------

if isequal(presample, false) && isequal(postsample, false)
    return
end

preDatabank = [ ];
if isequal(presample, true)
    pre = true;
    preDatabank = inputData;
elseif validate.databank(presample)
    pre = true;
    preDatabank = presample;
else
    pre = false;
end

postDatabank = [ ];
if isequal(postsample, true)
    post = true;
    postDatabank = inputData;
elseif validate.databank(postsample)
    post = true;
    postDatabank = postsample;
else
    post = false;
end

range = double(range);
startOfRange = range(1);
endOfRange = range(end);
freq = DateWrapper.getFrequencyAsNumeric(startOfRange);
serialRangeStart = DateWrapper.getSerial(startOfRange);
serialRangeEnd = DateWrapper.getSerial(endOfRange);

previousSerialXStart = [ ];
previousXStart = [ ];

for i = 1 : this.NumOfAppendables
    ithName = this.NamesOfAppendables{i};

    if ~isfield(outputData, ithName)
        continue
    end

    preSeries = [ ];
    postSeries = [ ];
    if validate.databank(preDatabank)
        if isfield(preDatabank, ithName) ...
           && isa(preDatabank.(ithName), 'TimeSubscriptable') ...
           && getFrequencyAsNumeric(preDatabank.(ithName))==freq
            preSeries = getfield(preDatabank, ithName);
        end
    end
    if validate.databank(postDatabank)
        if isfield(postDatabank, ithName) ...
            && isa(postDatabank.(ithName), 'TimeSubscriptable') ...
            && getFrequencyAsNumeric(postDatabank.(ithName))==freq
            postSeries = getfield(postDatabank, ithName);
        end
    end

    if isempty(preSeries) && isempty(postSeries)
        continue
    end

    x = getfield(outputData, ithName);
    serialXStart = round(x.Start);
    serialXStart0 = serialXStart;
    if isnan(serialXStart)
        serialXStart = serialRangeStart;
    elseif serialXStart>serialRangeStart
        serialXStart = serialRangeStart;
    end
    xData = getDataFromTo(x, serialXStart, serialRangeEnd);
    sizeXData2 = size(xData);
    sizeXData2 = sizeXData2(2:end);
    ncolXData = prod(sizeXData2);

    if ~isempty(preSeries)
        appendPresample( );
    end
    if ~isempty(postSeries)
        appendPostsample( );
    end

    if ~isempty(previousSerialXStart) && serialXStart==previousSerialXStart
        x.Start = previousXStart;
    elseif serialXStart~=serialXStart0
        newStart = DateWrapper.fromSerial(freq, serialXStart);
        x.Start = newStart;
        previousSerialXStart = serialXStart;
        previousXStart = newStart;
    end
    x.Data = xData;
    x = trim(x);
    outputData = setfield(outputData, ithName, x);
end

return




    function appendPresample( )
        preData = getDataFromTo(preSeries, -Inf, serialXStart-1);
        if isempty(preData)
            return
        end
        sizePreData = size(preData);
        ncolPreData = prod(sizePreData(2:end));
        if ncolPreData==1 && ncolXData>1
            preData = repmat(preData, [1, sizeXData2]);
        elseif ~isequal(sizePreData(2:end), sizeXData2)
            return
        end
        xData = [preData; xData];
        serialXStart = serialXStart - sizePreData(1);
    end%




    function appendPostsample( )
        postData = getDataFromTo(postSeries, serialRangeEnd+1, Inf);
        if isempty(postData)
            return
        end
        sizePostData = size(postData);
        ncolPostData = prod(sizePostData(2:end));
        if ncolPostData==1 && ncolXData>1
            postData = repmat(postData, [1, sizeXData2]);
        elseif ~isequal(sizePostData(2:end), sizeXData2)
            return
        end
        xData = [xData; postData];
    end%
end%

