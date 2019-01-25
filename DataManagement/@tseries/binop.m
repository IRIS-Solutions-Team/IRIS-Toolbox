function [x, varargout] = binop(fn, a, b, varargin)
% binop  Binary operators and functions on tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(a, 'tseries') && isa(b, 'tseries')
    sizeA = size(a.Data);
    sizeB = size(b.Data);
    a.Data = a.Data(:, :);
    b.Data = b.Data(:, :);
    [rowA, colA] = size(a.Data);
    [rowB, colB] = size(b.Data);
    if colA==1 && colB~=1
        % First input argument is tseries scalar; second tseries with
        % multiple columns. Expand the first tseries to match the size of the
        % second in 2nd and higher dimensions.
        a.Data = repmat(a.Data, 1, colB);
        sizeX = sizeB;
    elseif colA~=1 && colB==1
        % First tseries non-scalar; second tseries scalar.
        b.Data = repmat(b.Data, 1, colA);
        sizeX = sizeA;
    else
        sizeX = sizeA;
    end
    startDate = min([a.Start, b.Start]);
    endDate = max([a.Start+rowA-1, b.Start+rowB-1]);
    range = startDate : endDate;
    dataA = rangedata(a, range);
    dataB = rangedata(b, range);
    % Evaluate the operator.
    [dataX, varargout{1:nargout-1}] = fn(dataA, dataB, varargin{:});    
    x = a;
    try
        x.Data = reshape(dataX, [size(dataX, 1), sizeX(2:end)]);
    catch %#ok<CTCH>
        throw( ...
            exception.Base('Series:BinopSizeMismatch', 'error') ...
            );
    end
    x.Start = range(1);
    x = resetComment(x);
    x = trim(x);
else
    sizeB = size(b);
    sizeA = size(a);
    strFn = func2str(fn);
    if isa(a, 'tseries')
        x = a;
        a = a.Data;
        if any(strcmp(strFn, ...
                {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                && sizeB(1)==1 && all(sizeB(2:end)==sizeA(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            b = repmat(b, sizeA(1), 1);
        end
    else
        x = b;
        b = b.Data;
        if any(strcmp(strFn, ...
                {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                && sizeA(1)==1 && all(sizeA(2:end)==sizeB(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            a = repmat(a, sizeB(1), 1);
        end
    end
    [y, varargout{1:nargout-1}] = fn(a, b, varargin{:});
    sizeY = size(y);
    sizeX = size(x.Data);
    if sizeY(1)==sizeX(1)
        % Size of the numeric result in 1st dimension matches the size of the
        % input tseries object. Return a tseries object with the original
        % number of periods.
        x.Data = y;
        if length(sizeY)~=length(sizeX) || any(sizeY(2:end)~=sizeX(2:end))
            x.Comment = repmat({''}, [1, sizeY(2:end)]);
        end
        x = trim(x);
    else
        % Size of the numeric result has changed in 1st dimension from the
        % size of the input tseries object. Return a numeric array.
        x = y;
    end
end

end%

