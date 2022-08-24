% setData  Assign data to Series object
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

function this = setData(this, s, y)

ERROR_ASSIGNMENT = { 'Series:ErrorAssigning'
                     'Error when assigning to time series\nMatlab says: %s ' };

testColon = @(x) (ischar(x) || isstring(x)) && all(strcmpi(x, ':'));

% Simplified call
if isa(s, 'DateWrapper') || isnumeric(s)
    temp = s;
    s = struct();
    s.type = '()';
    s.subs = {temp};
end

%--------------------------------------------------------------------------

% Pad LHS time series data with MissingValues to comply with references
% Remove the rows from dates that do not pass the frequency test
[this, s, dates, freqTest] = locallyExpand(this, s);

% Get RHS time series object data
if isa(y, 'Series')
    checkFrequency(y, dates);
    y = getData(y, dates);
end

% Convert LHS NaNs to complex if LHS is real and RHS is complex
if isnumeric(this.Data) && isreal(this.Data) && ~isreal(y)
    inxMissing = this.MissingTest(this.Data);
    complexMissing = complex(this.MissingValue, this.MissingValue);
    this.Data(inxMissing) = complexMissing;
end

% If RHS has only one row but multiple cols (or size>1 in other dims), 
% time series is multivariate, and assigned are multiple dates, then expand RHS
% in 1st dimension
xSize = size(this.Data);
sizeRhs = size(y);
if length(y)>1 && size(y, 1)==1 ...
   && length(s.subs{1})>1 ...
   && any(xSize(2:end)>1)
    n = length(s.subs{1});
    y = reshape(y(ones(1, n), :), [n, sizeRhs(2:end)]);
end

% Report frequency mismatch
% Remove the rows from RHS that do not pass the frequency test; LHS dates
% have already been removed and a warning thrown in locallyExpand(~)
sizeRhs = size(y);
if any(~freqTest)
    if sizeRhs(1)==numel(freqTest)
        y = y(freqTest, :);
        y = reshape(y, [size(y, 1), sizeRhs(2:end)]);
    end
end

% Try to assign
try
    this.Data = subsasgn(this.Data, s, y);
catch Error
    message = Error.message;
    if ~isempty(message) && message(end)=='.'
        message(end) = '.';
    end
    throw( exception.Base(ERROR_ASSIGNMENT, 'error'), message );
end

% Make sure empty time series have start date set to NaN no matter what
if isempty(this.Data)
    this.Start = Series.StartDateWhenEmpty;
end

% If RHS is empty and first index is ':', then some of the columns could
% have been deleted, and the comments must be adjusted accordingly
if isempty(y) && testColon(s.subs{1});
    this.Comment = subsasgn(this.Comment, s, y);
end

this = trim(this);

end%

%
% Local Functions
%

function [this, s, dates, freqTest] = locallyExpand(this, s)
    %(
    ERROR_GROW_AMBIGUOUS_DIM = { 'TimeSubscriptale:subsasgn', ...
                                 'Attempt to grow time series data array along ambiguous dimension' };

    testColon = @(x) (ischar(x) || isstring(x)) && all(strcmpi(x, ':'));

    thisStart = double(this.Start);
    thisEnd = this.EndAsNumeric;
    freqThis = dater.getFrequency(thisStart);

    % If LHS data are complex, use NaN+NaNi to pad missing observations
    missingValue = this.MissingValue;

    % Replace x(dates) with x(dates, :, ..., :).
    if numel(s.subs)==1
        s.subs(2:ndims(this.Data)) = {':'};
    end

    % Inf and ':' produce the entire time series range
    % Convert subscripts in 1st dimension from dates to indices
    % We cannot use isequal(s.subs{1}, ':') because isequal(58, ':')
    % Give standartd dot access to properties
    timeRef = s.subs{1};
    if isnumeric(timeRef)
        timeRef = double(timeRef);
    end
    if isnumeric(timeRef) && numel(timeRef)==2 && any(isinf(timeRef))
        if isequal(timeRef(1), -Inf)
            timeRef(1) = thisStart;
        end
        if isequal(timeRef(2), Inf)
            timeRef(2) = thisEnd;
        end
        timeRef = dater.colon(timeRef(1), timeRef(2));
    end
    if testColon(timeRef) || isequal(timeRef, Inf)
        s.subs{1} = ':';
        if isnan(thisStart)
            % LHS is empty
            dates = double.empty(1, 0);
        else
            numRows = size(this.Data, 1);
            dates = dater.plus(thisStart, 0:numRows-1);
        end
        freqTest = true(size(dates));
    elseif isnumeric(timeRef) && ~isempty(timeRef)
        dates = double(timeRef);
        if ~isempty(dates)
            freqDates = dater.getFrequency(dates);
            if isnan(thisStart)
                % If LHS series is empty time series, set start date to the minimum
                % date with the same frequency as the first date
                thisStart = min(dates(freqDates==freqDates(1)));
                freqThis = freqDates(1);
            end
            freqTest = freqThis==freqDates;
            dates(~freqTest) = [];
            s.subs{1} = round(dates - thisStart + 1);
        end
    else
        dates = double.empty(1, 0);
        freqTest = true(1, 0);
    end

    % Reshape time series data to reduce number of dimensions if called with
    % fewer dimensions. Eg x.Data is Nx2x2, and assignment is for x(:, 3).
    % This mimicks standard Matlab behavior.
    numSubs = numel(s.subs);
    needsReshapeBack = false;
    if numSubs<ndims(this.Data)
        tempSubs = cell(1, numSubs);
        tempSubs(:) = {':'};
        tempSize = size(this.Data);
        this.Data = this.Data(tempSubs{:});
        this.Comment = this.Comment(tempSubs{:});
        needsReshapeBack = true;
    end

    % Add MissingValues to data when user indices go beyond the data size.
    % Add MissingValues to 1st dimension when user indices are non-positive.
    % Add empty strings for comments to comply with the new size.
    % This modifies standard Matlab matrix assignment, which produces zeros.
    for i = find(~strcmp(':', s.subs))
        % Non-positive index in 1st dimension
        if i==1 && any(s.subs{1}<1)
            n = 1 - min(s.subs{1});
            currentSize = size(this.Data);
            currentSize(1) = n;
            this.Data = [repmat(missingValue, currentSize); this.Data];
            thisStart = dater.plus(thisStart, -n);
            s.subs{1} = s.subs{1} + n;
        end
        % If index exceeds current size, add NaNs. This is different than
        % standard Matlab behavior: Matlab adds zeros.
        if any(s.subs{i}>size(this.Data, i))
            currentSize = size(this.Data);
            currentSize(end+1:numSubs) = 1;
            addSize = currentSize;
            addSize(i) = max(s.subs{i}) - addSize(i);
            this.Data = cat(i, this.Data, repmat(missingValue, addSize));
            if i>1
                % Add an appropriate empty cellstr to comments if time
                % series data are expanded in 2nd or higher dimensions
                addComment = repmat("", [1, addSize(2:end)]);
                this.Comment = cat(i, this.Comment, addComment);
            end
        end
    end

    % Try to reshape time series data array back
    if needsReshapeBack
        try
            this.Data = reshape(this.Data, tempSize);
            this.Comment = reshape(this.Comment, [1, tempSize(2:end)]);
        catch %#ok<CTCH>
            throw(exception.Base(ERROR_GROW_AMBIGUOUS_DIM, 'error'));
        end
    end

    this.Start = thisStart;

    %
    % Report frequency mismatch as an error
    %
    if any(~freqTest)
        charFreqThis = Frequency.toChar(freqThis);
        freqDates = unique(freqDates(~freqTest), 'stable');
        charFreqDates = arrayfun(@Frequency.toChar, freqDates, 'UniformOutput', false);
        thisError = [ "Series:FrequencyMismatch"
                      "Cannot reference %s dates when assigning to %1 time series " ];
        %throw( exception.Base('Series:FrequencyMismatch', 'error'), ...
        throw( ...
            exception.Base(thisError, 'error'), ...
            Frequency.toChar(freqThis), charFreqDates{:} ...
        );
    end
    %)
end%

