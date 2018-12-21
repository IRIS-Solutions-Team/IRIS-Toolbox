function this = setData(this, s, y)
% setData  Assign data to time series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

ERROR_ASSIGNMENT = { 'TimeSubscriptable:ErrorAssigning'
                     'Error when assigning to a time seris\nMatlab says: %s ' };
testColon = @(x) (ischar(x) || isa(x, 'string')) && isequal(x, ':');

% Simplified call
if isa(s, 'DateWrapper') || isnumeric(s)
    temp = s;
    s = struct( );
    s.type = '()';
    s.subs = {temp};
end

%--------------------------------------------------------------------------

convertToDateWrapper = isa(this.Start, 'DateWrapper');

% Pad LHS tseries data with NaNs to comply with references.
% Remove the rows from dates that do not pass the frequency test.
[this, s, dates, freqTest] = expand(this, s);

% Get RHS tseries object data.
if isa(y, 'TimeSubscriptable')
    checkFrequencyOrInf(y, dates);
    y = getData(y, dates);
end

% Convert LHS tseries NaNs to complex if LHS is real and RHS is complex.
if isreal(this.Data) && ~isreal(y)
    this.Data(isnan(this.Data)) = NaN + 1i*NaN;
end

% If RHS has only one row but multiple cols (or size>1 in other dims), 
% tseries is multivariate, and assigned are multiple dates, then expand RHS
% in 1st dimension.
xSize = size(this.Data);
sizeOfRhs = size(y);
if length(y)>1 && size(y, 1)==1 ...
   && length(s.subs{1})>1 ...
   && any(xSize(2:end)>1)
    n = length(s.subs{1});
    y = reshape(y(ones(1, n), :), [n, sizeOfRhs(2:end)]);
end

% Report frequency mismatch
% Remove the rows from RHS that do not pass the frequency test; LHS dates
% have already been removed and a warning thrown in expand(~)
sizeOfRhs = size(y);
if any(~freqTest)
    if sizeOfRhs(1)==numel(freqTest)
        y = y(freqTest, :);
        y = reshape(y, [size(y, 1), sizeOfRhs(2:end)]);
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
    if convertToDateWrapper
        this.Start = DateWrapper.NaD;
    else
        this.Start = NaN;
    end
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


function [this, s, dates, freqTest] = expand(this, s)
    ERROR_GROW_AMBIGUOUS_DIM = { 'TimeSubscriptale:subsasgn', ...
                                 'Attempt to grow time series data array along ambiguous dimension' };
    testColon = @(x) (ischar(x) || isa(x, 'string')) && isequal(x, ':');

    convertToDateWrapper = isa(this.Start, 'DateWrapper');
    startOfThis = double(this.Start);
    freqOfThis = DateWrapper.getFrequencyAsNumeric(startOfThis);

    % If LHS data are complex, use NaN+NaNi to pad missing observations.
    if isreal(this.Data)
        unit = 1;
    else
        unit = 1 + 1i;
    end

    % Replace x(dates) with x(dates, :, ..., :).
    if length(s.subs)==1
        s.subs(2:ndims(this.Data)) = {':'};
    end

    % Inf and ':' produce the entire time series range
    % Convert subscripts in 1st dimension from dates to indices
    % We cannot use isequal(s.subs{1}, ':') because isequal(58, ':')
    % Give standartd dot access to properties
    timeRef = s.subs{1};
    if testColon(timeRef) || isequal(timeRef, Inf) || isequal(timeRef, [-Inf, Inf])
        s.subs{1} = ':';
        if isnan(startOfThis)
            % LHS is empty
            dates = double.empty(1, 0);
        else
            dates = startOfThis + (0 : size(this.Data, 1)-1);
        end
        freqTest = true(size(dates));
    elseif (isa(timeRef, 'DateWrapper') || isnumeric(timeRef)) && ~isempty(timeRef)
        dates = double(s.subs{1});
        if ~isempty(dates)
            freqOfDates = DateWrapper.getFrequencyAsNumeric(dates);
            if isnan(startOfThis)
                % If LHS series is empty tseries, set start date to the minimum
                % date with the same frequency as the first date
                startOfThis = min(dates(freqOfDates==freqOfDates(1)));
                freqOfThis = freqOfDates(1);
            end
            freqTest = freqOfThis==freqOfDates;
            dates(~freqTest) = [ ];
            s.subs{1} = round(dates - startOfThis + 1);
        end
    else
        dates = double.empty(1, 0);
        freqTest = true(1, 0);
    end

    % Reshape tseries data to reduce number of dimensions if called with
    % fewer dimensions. Eg x.Data is Nx2x2, and assignment is for x(:, 3).
    % This mimicks standard Matlab behavior.
    nSubs = length(s.subs);
    needsReshapeBack = false;
    if nSubs<ndims(this.Data)
        tempSubs = cell([1, nSubs]);
        tempSubs(:) = {':'};
        tempSize = size(this.Data);
        this.Data = this.Data(tempSubs{:});
        this.Comment = this.Comment(tempSubs{:});
        needsReshapeBack = true;
    end

    % Add NaNs to data when user indices go beyond the data size.
    % Add NaNs to 1st dimension when user indices are non-positive.
    % Add empty strings for comments to comply with the new size.
    % This modifies standard Matlab matrix assignment, which produces zeros.
    for i = find(~strcmp(':', s.subs))
        % Non-positive index in 1st dimension.
        if i==1 && any(s.subs{1}<1)
            n = 1 - min(s.subs{1});
            currentSize = size(this.Data);
            currentSize(1) = n;
            this.Data = [nan(currentSize)*unit;this.Data];
            startOfThis = startOfThis - n;
            s.subs{1} = s.subs{1} + n;
        end
        % If index exceeds current size, add NaNs. This is different than
        % standard Matlab behavior: Matlab adds zeros.
        if any(s.subs{i}>size(this.Data, i))
            currentSize = size(this.Data);
            currentSize(end+1:nSubs) = 1;
            addSize = currentSize;
            addSize(i) = max(s.subs{i}) - addSize(i);
            this.Data = cat(i, this.Data, nan(addSize)*unit);
            if i>1
                % Add an appropriate empty cellstr to comments if tseries data
                % are expanded in 2nd or higher dimensions.
                comment = cell([1, addSize(2:end)]);
                comment(:) = {''};
                this.Comment = cat(i, this.Comment, comment);
            end
        end
    end

    % Try to reshape time series data array back
    if needsReshapeBack
        try
            this.Data = reshape(this.Data, tempSize);
            this.Comment = reshape(this.Comment, [1, tempSize(2:end)]);
        catch %#ok<CTCH>
            throw( exception.Base(ERROR_GROW_AMBIGUOUS_DIM, 'error') );
        end
    end

    if convertToDateWrapper && ~isa(startOfThis, 'DateWrapper')
        startOfThis = DateWrapper(startOfThis);
    end
    this.Start = startOfThis;

    % Report frequency mismatch as a warning
    if any(~freqTest)
        charFreqOfThis = Frequency.toChar(freqOfThis);
        freqOfDates = unique(freqOfDates(~freqTest), 'stable');
        charFreqOfDates = arrayfun(@Frequency.toChar, freqOfDates, 'UniformOutput', false);
        throw( exception.Base('TimeSubscriptable:FrequencyMismatch', 'warning'), ...
               Frequency.toChar(freqOfThis),charFreqOfDates{:} );
    end
end%

