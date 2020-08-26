function outputData = appendData(this, inputData, outputData, range, varargin)
% appendData  Append presample or postsample data
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team


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
startRange = range(1);
endRange = range(end);
freq = dater.getFrequency(startRange);
serialRangeStart = dater.getSerial(startRange);
serialRangeEnd = dater.getSerial(endRange);

previousSerialXStart = [ ];
previousXStart = [ ];

listAppendables = nameAppendables(this);
numAppendables = numel(listAppendables);
for i = 1 : numAppendables
    name__ = listAppendables{i};

    if ~isfield(outputData, name__)
        continue
    end

    preSeries = [ ];
    postSeries = [ ];
    if validate.databank(preDatabank)
        if isfield(preDatabank, name__) ...
           && isa(preDatabank.(name__), 'TimeSubscriptable') ...
           && getFrequencyAsNumeric(preDatabank.(name__))==freq
            preSeries = preDatabank.(name__);
        end
    end
    if validate.databank(postDatabank)
        if isfield(postDatabank, name__) ...
            && isa(postDatabank.(name__), 'TimeSubscriptable') ...
            && getFrequencyAsNumeric(postDatabank.(name__))==freq
            postSeries = postDatabank.(name__);
        end
    end

    if isempty(preSeries) && isempty(postSeries)
        continue
    end

    x = outputData.(name__);
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
    outputData.(name__) = x;
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

