function shiftedData = shiftDateKeepRange(data, shift)

if shift==0
    shiftedData = data;
else
    sizeData = size(data);
    ndimsData = numel(sizeData);
    missingValue = TimeSeries.getDefaultMissingValue(data);
    shiftedData = data;
    ref = repmat({':'}, 1, ndimsData-1);
    if shift<0
        shiftedData(end+shift+1:end, ref{:}) = [ ];
        shiftedData = [ repmat(missingValue, [-shift, sizeData(2:end)]); shiftedData ];
    else
        shiftedData(1:shift, ref{:}) = [ ];
        shiftedData = [ shiftedData; repmat(missingValue, [shift, sizeData(2:end)]) ];
    end
end

end
