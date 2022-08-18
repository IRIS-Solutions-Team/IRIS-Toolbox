function outputSeries = cat(n, varargin)

if numel(varargin)==1
    % Matlab calls horzcat(x) first for [x; y]
    outputSeries = varargin{1};
    return
end

% Check classes and frequencies
[inputs, inxSeries, inxNumeric] = locallyCheckInputs(varargin{:});

% Output will be the same class as first time series
posFirstSeries = find(inxSeries, 1);
firstSeries = inputs{posFirstSeries};
outputSeries = firstSeries.empty(firstSeries);

% Remove inputs with zero size in 2nd and higher dimensions
% Remove empty numeric arrays
inxToRemove = false(size(inputs));
for i = 1 : numel(inputs)
    if inxSeries(i) 
        size__ = size(inputs{i});
        inxToRemove(i) = all(size__(2:end)==0);
    elseif inxNumeric(i)
        inxToRemove(i) = isempty(inputs{i});
    end
end
inputs(inxToRemove) = [ ];
inxSeries(inxToRemove) = [ ];
inxNumeric(inxToRemove) = [ ]; %#ok<NASGU>

if isempty(inputs)
    return
end


% Find min start-date and max end-date
vecStart = double.empty(1, 0);
vecEnd = double.empty(1, 0);
for i = find(inxSeries)
    startDate = double(inputs{i}.Start);
    if ~isnan(startDate)
        vecStart(1, end+1) = startDate;
        vecEnd(1, end+1) = dater.plus(startDate, size(inputs{i}.Data, 1) - 1);
    end
end
if ~isempty(vecStart)
    minStart = min(vecStart);
    maxEnd = max(vecEnd);
    numPeriods = dater.minus(maxEnd, minStart) + 1;
else
    minStart = NaN;
    maxEnd = NaN;
    numPeriods = 0;
end

outputSeries.Start = minStart;
outputData = outputSeries.Data;
outputComment = outputSeries.Comment;

isEmpty = true;
for i = 1 : numel(inputs)
    if inxSeries(i)
        data__ = getDataFromTo(inputs{i}, minStart, maxEnd);
        comment__ = inputs{i}.Comment;
    else
        [data__, comment__] = locallyCreateDataFromNumeric(inputs{i}, numPeriods);
    end
    if isEmpty
        outputData = data__;
        outputComment = comment__;
        isEmpty = false;
    else
        outputData = cat(n, outputData, data__);
        % Patch for bug in builtin string/cat in pre-R2019b
        outputComment = string(cat(n, cellstr(outputComment), cellstr(comment__)));
    end
end

outputSeries.Data = outputData;
outputSeries.Comment = outputComment;
outputSeries = trim(outputSeries);

return

end%

%
% Local Functions
%

function [data__, comment__] = locallyCreateDataFromNumeric(data__, numPeriods)
    %(
    size__ = size(data__);
    data__ = data__(:, :);
    if size__(1)>1 && size__(1)<numPeriods
        data__(end+1:numPeriods, :) = NaN;
    elseif size__(1)>1 && size__(1)>numPeriods
        data__(numPeriods+1:end,:) = [];
    elseif size__(1)==1
        data__ = repmat(data__, numPeriods, 1);
    end
    if numel(size__)>2
        data__ = reshape(data__, [numPeriods, size__(2:end)]);
    end
    comment__ = repmat({''}, [1, size__(2:end)]);
    %)
end%


function [output, inxSeries, inxNumeric] = locallyCheckInputs(varargin)
    % Time series versus other inputs
    inxSeries = false(1, nargin);
    inxNumeric = false(1, nargin);
    for i = 1 : nargin
        inxSeries(i) = isa(varargin{i}, 'Series');
        inxNumeric(i) = isnumeric(varargin{i});
    end
    inxToRemove = ~inxSeries & ~inxNumeric;

    % Remove non-Series or non-numeric inputs and throw warning
    if any(inxToRemove)
        throw( exception.Base('Series:InputsRemovedFromCat', 'warning') );
        varargin(inxToRemove) = [ ]; %#ok<UNRCH>
        inxSeries(inxToRemove) = [ ];
        inxNumeric(inxToRemove) = [ ];
    end

    % Check frequencies
    freq = zeros(size(varargin));
    freq(~inxSeries) = Inf;
    start = nan(size(inxSeries));
    for i = find(inxSeries)
        start(i) = double(varargin{i}.Start);
    end
    freq(inxSeries) = dater.getFrequency(start(inxSeries));
    indexNaN = isnan(freq);
    if sum(~indexNaN & inxSeries)>1 ...
       && any( diff(freq(~indexNaN & inxSeries))~=0 )
        throw( exception.Base('Series:CannotCatMixedFrequencies', 'error') );
    end
    output = varargin;
end%

