function [data, dates, this] = mygetdata(this, dates, varargin)
% mygetdata  Get time series data for specific dates.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% References to 2nd and higher dimensions.
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    if nargout>2
        this.Comment = this.Comment(1, varargin{:});
    end
end

% References to time dimension.
start = this.Start;
sizeOfData = size(this.Data);
this.Data = this.Data(:, :);
indexToRemove = true(1, sizeOfData(1));
if ~isa(dates, 'DateWrapper') && ~isequal(dates, Inf) && ~ischar(dates)
    dates = DateWrapper(dates);
end
if isa(dates, 'DateWrapper') 
    dates = dates(:);
    data = nan([length(dates), sizeOfData(2:end)]);
    if ~isempty(this.Data)
        pos = round(dates - start + 1);
        ixTest = pos>=1 & pos<=sizeOfData(1) & freqcmp(start, dates);
        data(ixTest, :) = this.Data(pos(ixTest), :);
        if nargout>2
            indexToRemove(pos(ixTest)) = false;
        end
    end
elseif isequal(dates, Inf) || isequal(dates, ':') || isequal(dates, 'max')
    dates = start + (0 : sizeOfData(1)-1);
    data = this.Data;
    if nargout>2
        indexToRemove(:) = false;
    end
elseif isequal(dates, 'min')
    dates = start + (0 : sizeOfData(1)-1);
    sample = all(~isnan(this.Data), 2);
    data = this.Data(sample, :);
    if nargout>2
        indexToRemove(sample) = false;
    end
else
    data = this.Data([ ], :);
end

data = reshape(data, [size(data, 1), sizeOfData(2:end)]);

if nargout>2
    if isreal(this.Data)
        this.Data(indexToRemove, :) = NaN;
    else
        this.Data(indexToRemove, :) = NaN+1i*NaN;
    end
    this.Data = reshape(this.Data, [size(this.Data, 1), sizeOfData(2:end)]);
    this = trim(this);
end

end
