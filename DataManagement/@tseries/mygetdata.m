function [data, dates, this] = mygetdata(this, dates, varargin)
% mygetdata  Get time series data for specific dates
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

% References to 2nd and higher dimensions
if ~isempty(varargin)
    this.Data = this.Data(:, varargin{:});
    if nargout>2
        this.Comment = this.Comment(1, varargin{:});
    end
end

% References to time dimension
start = this.Start;
sizeOfData = size(this.Data);
this.Data = this.Data(:, :);
inxToRemove = true(1, sizeOfData(1));
if ~isa(dates, 'DateWrapper') && ~isequal(dates, Inf) && ~ischar(dates)
    dates = DateWrapper(dates);
end
if isa(dates, 'DateWrapper') 
    dates = dates(:);
    numOfDates = numel(dates);
    data = repmat(this.MissingValue, [numOfDates, sizeOfData(2:end)]);
    if ~isempty(this.Data)
        posOfDates = round(dates) - round(start) + 1;
        ixTest = posOfDates>=1 & posOfDates<=sizeOfData(1) & freqcmp(start, dates);
        data(ixTest, :) = this.Data(posOfDates(ixTest), :);
        if nargout>2
            inxToRemove(posOfDates(ixTest)) = false;
        end
    end
elseif isequal(dates, Inf) || isequal(dates, ':') || isequal(dates, 'max')
    dates = start + (0 : sizeOfData(1)-1);
    data = this.Data;
    if nargout>2
        inxToRemove(:) = false;
    end
elseif isequal(dates, 'min')
    dates = start + (0 : sizeOfData(1)-1);
    sample = all(~isnan(this.Data), 2);
    data = this.Data(sample, :);
    if nargout>2
        inxToRemove(sample) = false;
    end
else
    data = this.Data([ ], :);
end

data = reshape(data, [size(data, 1), sizeOfData(2:end)]);

if nargout>2
    missingValue = this.MissingValue;
    if ~isnumeric(missingValue) || isreal(this.Data)
        this.Data(inxToRemove, :) = missingValue;
    else
        this.Data(inxToRemove, :) = missingValue + 1i*missingValue;
    end
    this.Data = reshape(this.Data, [size(this.Data, 1), sizeOfData(2:end)]);
    this = trim(this);
end

end%
