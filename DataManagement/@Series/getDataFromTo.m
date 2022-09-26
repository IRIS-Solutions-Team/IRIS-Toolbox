% getDataFromTo  Retrieve time series data from date to date
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [x, actualFrom, actualTo, actualRange] = getDataFromTo(this, from, to)

    % No frequency check can be performed here; this is a responsibility of the
    % caller

    start = double(this.Start);
    try, to; catch, to = []; end;

    if nargin==1
        x = this.Data;
        actualFrom = start;
        actualTo = this.EndAsNumeric;
        if nargout>=4
            actualRange = dater.colon(actualFrom, actualTo);
        end
        return
    end

    [from, to] = local_resolveFromTo(from, to);

    if isnan(from) || isnan(to)
        ndimsData = ndims(this.Data);
        ref = [{[]}, repmat({':'}, 1, ndimsData-1)];
        x = this.Data(ref{:});
        actualFrom = from;
        actualTo = to;
        if nargout>=4
            actualRange = dater.colon(actualFrom, actualTo);
        end
        return
    end

    % Input dates from and to may be either date codes or serials; convert to
    % serials anyway
    serialFrom = dater.getSerial(from);
    serialTo = dater.getSerial(to);

    freqStart = dater.getFrequency(start);
    serialStart = dater.getSerial(start);
    data = this.Data;
    sizeData = size(data);
    missingValue = this.MissingValue;

    if ~isinf(serialFrom) && ~isinf(serialTo) && serialTo<serialFrom
        x = repmat(missingValue, [0, sizeData(2:end)]);
        if nargout>=2
            actualFrom = double.empty(0, 0);
            actualTo = double.empty(0, 0);
            actualRange = double.empty(1, 0);
        end
        return
    end

    if isnan(serialStart) 
        if isinf(serialFrom) || isinf(serialTo)
            lenRange = 0;
        else
            lenRange = round(serialTo - serialFrom + 1);
        end
        x = repmat(missingValue, [lenRange, sizeData(2:end)]);
        if nargout>=2
            actualFrom = double.empty(0, 0);
            actualTo = double.empty(0, 0);
            actualRange = double.empty(1, 0);
        end
        return
    end

    if isinf(serialFrom)
        posFrom = 1; 
    else
        posFrom = round(serialFrom - serialStart + 1);
    end

    if isinf(serialTo)
        posTo = sizeData(1);
    else
        posTo = round(serialTo - serialStart + 1);
    end

    numColumns = prod(sizeData(2:end));
    if posFrom>posTo
        x = repmat(missingValue, 0, numColumns);
    elseif posFrom>=1 && posTo<=sizeData(1)
        x = this.Data(posFrom:posTo, :);
    elseif (posFrom<1 && posTo<1) || (posFrom>sizeData(1) && posTo>sizeData(1))
        x = repmat(missingValue, posTo-posFrom+1, numColumns);
    elseif posFrom>=1
        addMissingAfter = repmat(missingValue, posTo-sizeData(1), numColumns);
        x = [ data(posFrom:end, :); addMissingAfter ];
    elseif posTo<=sizeData(1)
        addMissingBefore = repmat(missingValue, 1-posFrom, numColumns);
        x = [ addMissingBefore; data(1:posTo, :) ];
    else
        addMissingBefore = repmat(missingValue, 1-posFrom, numColumns);
        addMissingAfter = repmat(missingValue, posTo-sizeData(1), numColumns);
        x = [ addMissingBefore; data(:, :); addMissingAfter ];
    end

    if numel(sizeData)>2
        x = reshape(x, [size(x, 1), sizeData(2:end)]);
    end

    if nargout>=2
        actualFrom = dater.fromSerial(freqStart, serialStart + posFrom - 1);
        actualTo = dater.fromSerial(freqStart, serialStart + posTo - 1);
    end

    if nargout>=4
        actualRange = dater.colon(actualFrom, actualTo);
    end

end%


function [from, to] = local_resolveFromTo(from, to)
    %(
    if isempty(to) && (isequal(from, @all) || strcmp(from, ":"))
        % Legacy range specifications: @all, :
        from = Inf;
    end
    from = double(from);
    to = double(to);
    if isempty(to)
        to = from;
    end
    from = from(1);
    to = to(end);
    %)
end%

