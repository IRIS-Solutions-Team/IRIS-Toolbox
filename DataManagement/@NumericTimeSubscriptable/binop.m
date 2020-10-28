% binop  Binary operators and functions on NumericTimeSubscriptable objects
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [x, varargout] = binop(fn, a, b, varargin)

if isa(a, 'NumericTimeSubscriptable') && isa(b, 'NumericTimeSubscriptable')
    sizeA = size(a.Data);
    sizeB = size(b.Data);
    a.Data = a.Data(:, :);
    b.Data = b.Data(:, :);
    [rowA, colA] = size(a.Data);
    [rowB, colB] = size(b.Data);
    if colA==1 && colB~=1
        % First input argument is NumericTimeSubscriptable scalar; second NumericTimeSubscriptable with
        % multiple columns. Expand the first NumericTimeSubscriptable to match the size of the
        % second in 2nd and higher dimensions.
        a.Data = repmat(a.Data, 1, colB);
        sizeX = sizeB;
    elseif colA~=1 && colB==1
        % First NumericTimeSubscriptable non-scalar; second
        % NumericTimeSubscriptable scalar
        b.Data = repmat(b.Data, 1, colA);
        sizeX = sizeA;
    else
        sizeX = sizeA;
    end

    if isa(a.Start, "DateWrapper"), dateFunction = @DateWrapper;
        else, dateFunction = @double; end

    startA = double(a.Start);
    startB = double(b.Start);
    if isnan(startA) && isnan(startB)
        startDate = NaN;
        endDate = NaN;
    else
        freqA = dater.getFrequency(startA);
        freqB = dater.getFrequency(startB);
        if freqA~=freqB
            exception.error([
                "Series:FrequencyMismatch"
                "Date frequency mismatch between input time series when evaluating "
                "this function: %s(%s, %s) "
            ], string(func2str(fn)), Frequency(freqA), Frequency(freqB));
        end
        startDate = min([startA, startB]);
        endDate = max([startA+rowA-1, startB+rowB-1]);
    end
    dataA = getDataFromTo(a, startDate, endDate);
    dataB = getDataFromTo(b, startDate, endDate);
    % Evaluate the operator or function
    [dataX, varargout{1:nargout-1}] = fn(dataA, dataB, varargin{:}); 
    % Create output series
    x = a;
    try
        x.Data = reshape(dataX, [size(dataX, 1), sizeX(2:end)]);
    catch %#ok<CTCH>
        exception.error([
            "Series:DimensionMismatch"
            "Invalid dimensions of output time series produced when evaluating "
            "this function: %s "
        ], string(func2str(fn)));
    end
    x.Start = dateFunction(startDate);
    x = resetComment(x);
    x = trim(x);
else
    sizeB = size(b);
    sizeA = size(a);
    strFn = func2str(fn);
    if isa(a, 'TimeSubscriptable')
        x = a;
        a = a.Data;
        if any(strcmp(strFn, ...
                {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                && sizeB(1)==1 && all(sizeB(2:end)==sizeA(2:end))
            % Expand non time seriesk data in first dimension to match the number
            % of periods of the NumericTimeSubscriptable object for elementwise operators.
            b = repmat(b, sizeA(1), 1);
        end
    else
        x = b;
        b = b.Data;
        if any(strcmp(strFn, ...
                {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                && sizeA(1)==1 && all(sizeA(2:end)==sizeB(2:end))
            % Expand non time series data in first dimension to match the number
            % of periods of the NumericTimeSubscriptable object for elementwise operators.
            a = repmat(a, sizeB(1), 1);
        end
    end
    [y, varargout{1:nargout-1}] = fn(a, b, varargin{:});
    sizeY = size(y);
    sizeX = size(x.Data);
    if sizeY(1)==sizeX(1)
        % Size of the numeric result in 1st dimension matches the size of the
        % input NumericTimeSubscriptable object. Return a NumericTimeSubscriptable object with the original
        % number of periods.
        x.Data = y;
        if numel(sizeY)~=numel(sizeX) || any(sizeY(2:end)~=sizeX(2:end))
            x.Comment = repmat({''}, [1, sizeY(2:end)]);
        end
        x = trim(x);
    else
        % Size of the numeric result has changed in 1st dimension from the
        % size of the input NumericTimeSubscriptable object. Return a numeric array.
        x = y;
    end
end

end%

