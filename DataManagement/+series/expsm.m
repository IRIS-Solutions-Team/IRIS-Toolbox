% expsm  Apply exponential smoothing to numeric data
%
% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


function smooth = expsm(x, beta, initials)

    sizeX = size(x);
    ndimsX = ndims(x);
    x = x(:, :);
    numColumns = size(x, 2);

    smooth = nan(size(x));
    numPeriods0 = NaN;
    if isequaln(initials, NaN)
        initials = [];
    end
    initials = reshape(initials, [], 1);
    numInitials = size(initials, 1);
    for i = 1 : numColumns
        ithX = x(:, i);
        inxNaNData = isnan(ithX);
        first = find(~inxNaNData, 1);
        last = find(~inxNaNData, 1, 'last');
        ithX = [initials; ithX(first:last)];
        numPeriods = size(ithX, 1);
        if numPeriods~=numPeriods0
            w = local_getExpSmoothMatrix(beta, numPeriods);
        end
        ithX = w*ithX;
        ithX = ithX(numInitials+1:end);
        smooth(first:last, i) = ithX;
        numPeriods0 = numPeriods;
    end

    if ndimsX>2
        smooth = reshape(smooth, sizeX);
    end

end%

%
% Local functions
%

function ww = local_getExpSmoothMatrix(beta, numPeriods)
    %(
    betap = beta.^(0:numPeriods-1);
    w = toeplitz(betap(1:end-1));
    w = tril(w);
    w = w * (1-beta);
    ww = zeros(numPeriods);
    ww(:, 1) = transpose(betap);
    ww(2:end, 2:end) = w;
    %)
end%

