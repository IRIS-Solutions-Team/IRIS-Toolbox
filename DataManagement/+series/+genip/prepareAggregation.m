function aggregation = prepareAggregation(aggregationModel, numLowPeriods, numWithin)

aggregation = struct( );

if isnumeric(aggregationModel)
    aggregation.Model = reshape(aggregationModel, 1, numWithin);
elseif any(strcmpi(char(aggregationModel), {'average', 'mean'}))
    aggregation.Model = ones(1, numWithin)/numWithin;
elseif strcmpi(char(aggregationModel), 'last')
    aggregation.Model = zeros(1, numWithin);
    aggregation.Model(end) = 1;
elseif strcmpi(char(aggregationModel), 'first')
    aggregation.Model = zeros(1, numWithin);
    aggregation.Model(1) = 1;
else
    % Default 'sum'
    aggregation.Model = ones(1, numWithin);
end
aggregation.ModelFlipped = aggregation.Model(end:-1:1);

end%
