function outp = cat(n, varargin)
% cat  Concatenation of Series objects in n-th dimension.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin)==1
    % Matlab calls horzcat(x) first for [x; y].
    outp = varargin{1};
    return
end

% Check classes and frequencies.
[inputs, indexOfSeries, indexOfNumeric] = catcheck(varargin{:});

% Output will be the same class as first time series.
posOfFirstSeries = find(indexOfSeries, 1);
firstSeries = inputs{posOfFirstSeries};
outp = firstSeries.empty(firstSeries);

% Remove inputs with zero size in 2nd and higher dimensions.
% Remove empty numeric arrays.
indexToRemove = false(size(inputs));
for ithInput = 1 : length(inputs)
    if indexOfSeries(ithInput) 
        size_ = size(inputs{ithInput});
        indexToRemove(ithInput) = all(size_(2:end)==0);
    elseif indexOfNumeric(ithInput)
        indexToRemove(ithInput) = isempty(inputs{ithInput});
    end
end
inputs(indexToRemove) = [ ];
indexOfSeries(indexToRemove) = [ ];
indexOfNumeric(indexToRemove) = [ ]; %#ok<NASGU>

if isempty(inputs)
    return
end

numOfInputs = length(inputs);

% Find min start-date and max end-date.
vecStart = DateWrapper.empty(1, 0);
vecEnd = DateWrapper.empty(1, 0);
for i = find(indexOfSeries)
    startDate = inputs{i}.Start;
    if ~isnan(startDate)
        vecStart(1, end+1) = startDate;
        vecEnd(1, end+1) = inputs{i}.End;
    end
end
if ~isempty(vecStart)
    minStart = min(vecStart);
    maxEnd = max(vecEnd);
    nPer = rnglen(minStart, maxEnd);
else
    minStart = DateWrapper(NaN);
    maxEnd = DateWrapper(NaN);
    nPer = 0;
end
outp.Start = minStart;

% Add inputs one by one to output series.
isEmpty = true;
for ithInput = 1 : numOfInputs
    if indexOfSeries(ithInput)
        addSeries( inputs{ithInput} );
    else
        addNumeric( inputs{ithInput} );
    end
end

return


    function addSeries(x)
        data_ = rangedata(x, [minStart, maxEnd]);
        if isEmpty
            outp.data = data_;
            outp.Comment = x.Comment;
            isEmpty = false;
        else
            outp.data = cat(n, outp.data, data_);
            outp.Comment = cat(n, outp.Comment, x.Comment);
        end
    end


    function addNumeric(x)
        size_ = size(x);
        x = x(:, :);
        if size_(1)>1 && size_(1)<nPer
            x(end+1:nPer, :) = NaN;
        elseif size_(1)>1 && size_(1)>nPer
            x(nPer+1:end,:) = [ ];
        elseif size_(1)==1 && nPer>1
            x = repmat(x, nPer, 1);
        end
        x = reshape(x, [nPer, size_(2:end)]);
        comment = repmat({''}, [1, size_(2:end)]);                                                                               
        if isEmpty
            outp.data = x;
            outp.Comment = comment;
            isEmpty = false;
        else
            outp.data = cat(n, outp.data, x);
            outp.Comment = cat(n, outp.Comment, comment);
        end        
    end
end
