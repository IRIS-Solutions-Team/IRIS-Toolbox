function outputData = appendData(this, inputData, outputData, range, varargin)
% appendData  Append presample or postsample data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if numel(varargin)==2
    presample = varargin{1};
    postsample = varargin{2};
elseif numel(varargin)==1 && isstruct(varargin{1})
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
elseif isstruct(presample)
    pre = true;
    preDatabank = presample;
else
    pre = false;
end

postDatabank = [ ];
if isequal(postsample, true)
    post = true;
    postDatabank = inputData;
elseif isstruct(postsample)
    post = true;
    postDatabank = postsample;
else
    post = false;
end

freq = round(getFrequency(range(1)));
serialRangeStart = round(range(1));
serialRangeEnd = round(range(end));

list = this.NamesAppendable;
for i = 1 : numel(list)
    ithName = list{i};
    preSeries = [ ];
    postSeries = [ ];
    if isstruct(preDatabank)
        if isfield(preDatabank, ithName) ...
            && isa(preDatabank.(ithName), 'TimeSubscriptable') ...
            && round(preDatabank.(ithName).Frequency)==freq
            preSeries = preDatabank.(ithName);
        end
    end
    if isstruct(postDatabank)
        if isfield(postDatabank, ithName) ...
            && isa(postDatabank.(ithName), 'TimeSubscriptable') ...
            && round(postDatabank.(ithName).Frequency)==freq
            postSeries = postDatabank.(ithName);
        end
    end

    if isempty(preSeries) && isempty(postSeries)
        continue
    end

    x = outputData.(ithName);
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

    if serialXStart~=serialXStart0
        x.Start = DateWrapper.fromSerial(freq, serialXStart);
    end
    x.Data = xData;
    x = trim(x);
    outputData.(ithName) = x;
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

