% appendData  Append presample or postsample data
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = appendData(this, inputDb, outputDb, range, varargin)

if numel(varargin)==2
    presample = varargin{1};
    postsample = varargin{2};
elseif numel(varargin)==1 && validate.databank(varargin{1})
    opt = varargin{1};
    if isfield(opt, "DbOverlay") && ~isequal(opt.DbOverlay, false)
        presample = opt.DbOverlay;
        postsample = opt.DbOverlay;
    else
        try
            presample = opt.PrependInput;
        catch
            presample = opt.AppendPresample;
        end
        try
            postsample = opt.AppendInput;
        catch
            postsample = opt.AppendPostsample;
        end
    end
end

%--------------------------------------------------------------------------

if isequal(presample, false) && isequal(postsample, false)
    return
end

preDatabank = [ ];
if isequal(presample, true)
    preDatabank = inputDb;
elseif validate.databank(presample)
    preDatabank = presample;
end

postDatabank = [ ];
if isequal(postsample, true)
    postDatabank = inputDb;
elseif validate.databank(postsample)
    postDatabank = postsample;
end

range = double(range);
startRange = range(1);
endRange = range(end);
freq = dater.getFrequency(startRange);
serialRangeStart = dater.getSerial(startRange);
serialRangeEnd = dater.getSerial(endRange);

previousSerialXStart = [ ];
previousXStart = [ ];

for name__ = textual.stringify(nameAppendables(this))
    if ~isfield(outputDb, name__)
        continue
    end

    preSeries = [ ];
    postSeries = [ ];
    if validate.databank(preDatabank)
        if isfield(preDatabank, name__) ...
           && isa(preDatabank.(name__), 'Series') ...
           && getFrequencyAsNumeric(preDatabank.(name__))==freq
            preSeries = preDatabank.(name__);
        end
    end
    if validate.databank(postDatabank)
        if isfield(postDatabank, name__) ...
            && isa(postDatabank.(name__), 'Series') ...
            && getFrequencyAsNumeric(postDatabank.(name__))==freq
            postSeries = postDatabank.(name__);
        end
    end

    if isempty(preSeries) && isempty(postSeries)
        continue
    end

    x = outputDb.(name__);
    serialXStart = round(double(x.Start));
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
        newStart = Dater.fromSerial(freq, serialXStart);
        x.Start = newStart;
        previousSerialXStart = serialXStart;
        previousXStart = newStart;
    end
    x.Data = xData;
    x = trim(x);
    outputDb.(name__) = x;
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

