function outp = cat(n, varargin)
% cat  Concatenation of Series objects in n-th dimension.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin)==1
    % Matlab calls horzcat(x) first for [x; y].
    outp = varargin{1};
    return
end

% Check classes and frequencies.
[inputs, ixSeries, ixNumeric] = catcheck(varargin{:});

% Output will be the same class as first time series.
outp = empty( inputs{find(ixSeries, 1)} );

% Remove inputs with zero size in 2nd and higher dimensions.
% Remove empty numeric arrays.
ixRemove = false(size(inputs));
for i = 1 : length(inputs)
    if ixSeries(i) 
        size_ = size(inputs{i});
        ixRemove(i) = all(size_(2:end)==0);
    elseif ixNumeric(i)
        ixRemove(i) = isempty(inputs{i});
    end
end
inputs(ixRemove) = [ ];
ixSeries(ixRemove) = [ ];
ixNumeric(ixRemove) = [ ]; %#ok<NASGU>

if isempty(inputs)
    return
end
nInp = length(inputs);

% Find min start-date and max end-date.
vecStart = nan(1, nInp);
vecEnd = nan(1, nInp);
for i = find(ixSeries)
    vecStart(i) = startDate(inputs{i});
    vecEnd(i) = endDate(inputs{i});
end
minStart = min( vecStart(~isnan(vecStart)) );
maxEnd = max( vecEnd(~isnan(vecEnd)) );
nPer = rnglen( [minStart, maxEnd] );

if ~isempty(minStart)
    outp.start = minStart;
else
    outp.start = NaN;
end

% Add inputs one by one to output series.
isEmpty = true;
for i = 1 : nInp
    if ixSeries(i)
        addSeries(inputs{i});
    else
        addNumeric(inputs{i});
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
