
function [outputSeries, varargout] = binop(fn, a, b, varargin)

    if isa(a, 'Series') && isa(b, 'Series')
        sizeA = size(a.Data);
        sizeB = size(b.Data);
        a.Data = a.Data(:, :);
        b.Data = b.Data(:, :);
        [rowA, colA] = size(a.Data);
        [rowB, colB] = size(b.Data);
        if colA==1 && colB~=1
            % First input argument is Series scalar; second Series with
            % multiple columns. Expand the first Series to match the size of the
            % second in 2nd and higher dimensions.
            a.Data = repmat(a.Data, 1, colB);
            sizeOutputData = sizeB;
        elseif colA~=1 && colB==1
            % First Series non-scalar; second
            % Series scalar
            b.Data = repmat(b.Data, 1, colA);
            sizeOutputData = sizeA;
        else
            sizeOutputData = sizeA;
        end

        % startA = double(a.Start);
        % startB = double(b.Start);
        % freqA = dater.getFrequency(startA);
        % freqB = dater.getFrequency(startB);
        % if ~isnan(freqA) && ~isnan(freqB) && freqA~=freqB
            % exception.error([
                % "Series:FrequencyMismatch"
                % "Date frequency mismatch between input time series when evaluating "
                % "this function: %s(%s, %s) "
            % ], string(func2str(fn)), Frequency(freqA), Frequency(freqB));
        % end

        [dates, dataA, dataB] = getDataFromMultiple("unbalanced", string(func2str(fn)), a, b);

        % startDate = min([startA, startB], [], "OmitNaN");
        % endDateA = dater.plus(startA, rowA-1);
        % endDateB = dater.plus(startB, rowB-1);
        % endDate = max([endDateA, endDateB], [], "OmitNaN");
        % dataA = getDataFromTo(a, startDate, endDate);
        % dataB = getDataFromTo(b, startDate, endDate);

        % Evaluate the operator or function
        [outputData, varargout{1:nargout-1}] = fn(dataA, dataB, varargin{:}); 

        try
            outputData = reshape(outputData, [size(outputData, 1), sizeOutputData(2:end)]);
        catch %#ok<CTCH>
            exception.error([
                "Series:DimensionMismatch"
                "Invalid dimensions of output time series produced when evaluating "
                "this function: %s "
            ], string(func2str(fn)));
        end

        % Create output series
        outputSeries = a;
        outputSeries.Data = outputData;
        if isempty(dates)
            dates = NaN;
        end
        outputSeries.Start = dates(1);
        outputSeries = resetComment(outputSeries);
        outputSeries = trim(outputSeries);

    else
        sizeB = size(b);
        sizeA = size(a);
        strFn = func2str(fn);
        if isa(a, 'Series')
            outputSeries = a;
            a = a.Data;
            if any(strcmp(strFn, ...
                    {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                    && sizeB(1)==1 && all(sizeB(2:end)==sizeA(2:end))
                % Expand non time seriesk data in first dimension to match the number
                % of periods of the Series object for elementwise operators.
                b = repmat(b, sizeA(1), 1);
            end
        else
            outputSeries = b;
            b = b.Data;
            if any(strcmp(strFn, ...
                    {'times', 'plus', 'minus', 'rdivide', 'mdivide', 'power'})) ...
                    && sizeA(1)==1 && all(sizeA(2:end)==sizeB(2:end))
                % Expand non time series data in first dimension to match the number
                % of periods of the Series object for elementwise operators.
                a = repmat(a, sizeB(1), 1);
            end
        end
        [y, varargout{1:nargout-1}] = fn(a, b, varargin{:});
        sizeY = size(y);
        sizeOutputData = size(outputSeries.Data);
        if sizeY(1)==sizeOutputData(1)
            % Size of the numeric result in 1st dimension matches the size of the
            % input Series object. Return a Series object with the original
            % number of periods.
            outputSeries.Data = y;
            if numel(sizeY)~=numel(sizeOutputData) || any(sizeY(2:end)~=sizeOutputData(2:end))
                outputSeries.Comment = repmat({''}, [1, sizeY(2:end)]);
            end
            outputSeries = trim(outputSeries);
        else
            % Size of the numeric result has changed in 1st dimension from the
            % size of the input Series object. Return a numeric array.
            outputSeries = y;
        end
    end

end%

