
function [array, trendLine] = insertTrendLine(this, array, range, rowNames)

    numPages = size(array, 3);
    trendLine = dat2ttrend(range, this);
    posTrendLine = locateTrendLine(this.Quantity, rowNames);
    if numel(posTrendLine)==1
        array(posTrendLine, :, :) = repmat(trendLine, 1, 1, numPages);
    end

end%

