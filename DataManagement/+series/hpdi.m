% hpdi  Highest probability density interval
%

function out = hpdi(x, coverage, dim)

    % Put requested dimenstion first, unfold array into 2D
    [x, redimStruct] = series.redim(x, dim);

    % Proceed columwise
    [numRows, numColumns] = size(x);
    numToExclude = round((1-coverage/100)*numRows);
    out = nan(2, numColumns);
    for i = 1 : numColumns
        ithX = x(:, i);
        ithX(isnan(ithX)) = [];
        if isempty(ithX)
            continue
        end
        ithX = sort(ithX);
        distance = ithX((end-numToExclude):end) - ithX(1:(numToExclude+1));
        [minDistance, pos] = min(distance);
        pos = pos(1);
        out(1, i) = ithX(pos);
        out(2, i) = ithX(pos) + minDistance;
    end

    % Rearrange results back to conform with input array dimensions
    out = series.redim(out, dim, redimStruct);

end%

