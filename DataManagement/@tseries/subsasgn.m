function this = subsasgn(this, s, y, varargin)
% subsasgn  Subscripted assignment for time series
%
% __Syntax__
%
%     X(Dates) = Values
%     X(Dates, I, J, K, ...) = Values
%
%
% __Input Arguments__
%
% * `X` [ tseries ] - Tseries object that will be assigned new
% observations.
%
% * `Dates` [ numeric ] - Dates for which the new observations will be
% assigned.
%
% * `I`, `J`, `K`, ... [ numeric ] - References to 2nd and higher
% dimensions of the tseries object.
%
% * `Values` [ numeric ] - New observations that will assigned at specified
% dates.
%
%
% __Output Arguments__
%
% * `X` [ tseries ] - Tseries object with newly assigned observations.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

if isstruct(s) && isequal(s(1).type, '.')
    % Give standard dot access to properties
    this = builtin('subsasgn', this, s, y);
    return
end

if ~isstruct(s)
    % Simplified syntax: subsasgn(x, dates, y, ref2, ref3, ...)
    dates = s;
    s = struct( );
    s.type = '()';
    s.subs = [{dates}, varargin];
end

switch s(1).type
    case {'()', '{}'}
        % Run recognizeShift( ) to tell if the first reference is a lag/lead. If yes, 
        % the startdate `x` will be adjusted within recognizeShift( )
        sh = 0;
        if length(s)>1 || isa(y, 'tseries')
            [this, s, sh] = recognizeShift(this, s);
        end
        % After a lag or lead, only one ( )-reference is allowed.
        if length(s)~=1 || ~isequal(s(1).type, '()')
            utils.error('tseries:subsasgn', ...
                ['Invalid subscripted assignment ', ...
                'to tseries object.']);
        end
        this = setData(this, s, y);
        this = trim(this);
        % Shift start date back.
        if sh~=0
            this.Start = addTo(this.Start, sh);
        end
end

end%


function this = setData(this, s, y)
% Pad LHS tseries data with NaNs to comply with references.
% Remove the rows from dates that do not pass the frequency test.
[this, s, dates, freqTest] = expand(this, s);

% Get RHS tseries object data.
if isa(y, 'tseries')
    y = mygetdata(y, dates);
end

% Convert LHS tseries NaNs to complex if LHS is real and RHS is complex.
if isreal(this.data) && ~isreal(y)
    this.data(isnan(this.data)) = NaN + 1i*NaN;
end

% If RHS has only one row but multiple cols (or size>1 in other dims), 
% tseries is multivariate, and assigned are multiple dates, then expand RHS
% in 1st dimension.
xSize = size(this.data);
ySize = size(y);
if length(y)>1 && size(y, 1)==1 ...
        && length(s.subs{1})>1 ...
        && any(xSize(2:end)>1)
    n = length(s.subs{1});
    y = reshape(y(ones(1, n), :), [n, ySize(2:end)]);
end

% Report frequency mismatch.
% Remove the rows from RHS that do not pass the frequency test.
ySize = size(y);
if any(~freqTest)
    utils.warning('tseries:subsasgn', ...
        'Date frequency mismatch in assignment to tseries object.');
    if ySize(1)==length(freqTest)
        y = y(freqTest, :);
        y = reshape(y, [size(y, 1), ySize(2:end)]);
    end
end

try
    this.data = subsasgn(this.data, s, y);
catch Err
    msg = Err.message;
    if ~isempty(msg) && msg(end)=='.'
        msg(end) = '.';
    end
    utils.error('tseries:subsasgn', ...
        ['Error in tseries assignment.\n', ...
        '\tUncle says: %s.'], ...
        msg);
end

% Make sure empty tseries have start date set to NaN no matter what.
if isempty(this.data)
    this.start = NaN;
end

% If RHS is empty and first index is ':', then some of the columns could
% have been deleted, and the comments must be adjusted accordingly.
if isempty(y) && strcmp(s.subs{1}, ':')
    this.Comment = subsasgn(this.Comment, s, y);
end
end%


function [this, s, dates, freqTest] = expand(this, s)
% If LHS data are complex, use NaN+NaNi to pad missing observations.
if isreal(this.data)
    unit = 1;
else
    unit = 1 + 1i;
end

% Replace x(dates) with x(dates, :, ..., :).
if length(s.subs)==1
    s.subs(2:ndims(this.data)) = {':'};
end

% * Inf and ':' produce the entire tseries range.
% * Convert subscripts in 1st dimension from dates to indices.
% * We cannot use `isequal(S.subs{1}, ':')` because `isequal(58, ':')`
% Give standartd dot access to properties
% produces `true`.
if (ischar(s.subs{1}) && strcmp(s.subs{1}, ':')) ...
        || isequal(s.subs{1}, Inf)
    s.subs{1} = ':';
    if isnan(this.start)
        % LHS is empty.
        dates = [ ];
    else
        dates = this.start + (0 : size(this.data, 1)-1);
    end
    freqTest = true(size(dates));
elseif isnumeric(s.subs{1}) && ~isempty(s.subs{1})
    dates = s.subs{1};
    if ~isempty(dates)
        f2 = DateWrapper.getFrequencyFromNumeric(dates);
        if isnan(this.start)
            % If LHS series is empty tseries, set start date to the minimum
            % date with the same frequency as the first date.
            this.start = min(dates(f2==f2(1)));
        end
        f1 = DateWrapper.getFrequencyFromNumeric(this.Start);
        freqTest = f1==f2;
        dates(~freqTest) = [ ];
        s.subs{1} = round(dates - this.start + 1);
    end
else
    dates = [ ];
    freqTest = [ ];
end

% Reshape tseries data to reduce number of dimensions if called with
% fewer dimensions. Eg x.data is Nx2x2, and assignment is for x(:, 3).
% This mimicks standard Matlab behaviour.
nSubs = length(s.subs);
isReshaped = false;
if nSubs<ndims(this.data)
    tempSubs = cell([1, nSubs]);
    tempSubs(:) = {':'};
    tempSize = size(this.data);
    this.data = this.data(tempSubs{:});
    this.Comment = this.Comment(tempSubs{:});
    isReshaped = true;
end

% Add NaNs to data when user indices go beyond the data size.
% Add NaNs to 1st dimension when user indices are non-positive.
% Add empty strings for comments to comply with the new size.
% This modifies standard Matlab matrix assignment, which produces zeros.
for i = find(~strcmp(':', s.subs))
    % Non-positive index in 1st dimension.
    if i==1 && any(s.subs{1}<1)
        n = 1 - min(s.subs{1});
        currentSize = size(this.data);
        currentSize(1) = n;
        this.data = [nan(currentSize)*unit;this.data];
        this.start = this.start - n;
        s.subs{1} = s.subs{1} + n;
    end
    % If index exceeds current size, add NaNs. This is different than
    % standard Matlab behaviour: Matlab adds zeros.
    if any(s.subs{i}>size(this.data, i))
        currentSize = size(this.data);
        currentSize(end+1:nSubs) = 1;
        addSize = currentSize;
        addSize(i) = max(s.subs{i}) - addSize(i);
        this.data = cat(i, this.data, nan(addSize)*unit);
        if i>1
            % Add an appropriate empty cellstr to comments if tseries data
            % are expanded in 2nd or higher dimensions.
            comment = cell([1, addSize(2:end)]);
            comment(:) = {''};
            this.Comment = cat(i, this.Comment, comment);
        end
    end
end

% Try to reshape tseries data array back.
if isReshaped
    try
        this.data = reshape(this.data, tempSize);
        this.Comment = reshape(this.Comment, [1, tempSize(2:end)]);
    catch %#ok<CTCH>
        utils.error('tseries:subsasgn', ...
            'Attempt to grow tseries data array along ambiguous dimension.');
    end
end
end%

