function low = aggregate(high, lowFreq, varargin)
% aggregate  Convert TimeSeries from higher frequency to lower frequency.
%
% __Syntax__
%
%     Y = aggregate(X, LowFreq, ...)
%
%
% __Input Arguments__
%
% * `X` [ TimeSeries ] - Input TimeSeries that will be converted to higher
% frequency.
%
% * `LowFreq` [ Frequency | char ] - Lower frequency to which the input
% TimeSeries will be converted.
%
%
% __Output Arguments__
%
% * `Y` [ TimeSeries ] - Lower frequency TimeSeries.
%
%
% __Options__
%
% * `'Missing='` [ *`'keep'`* | `'remove'` ] - Keep or remove missing
% observations from the data array before applying aggregation function.
%
% * `'Error='` [ *`'missing'`* | `'throw'` ] - What to do when an attempt
% to aggregate data for a period results in an error.
%
% * `'Function='` [ *`@mean`* | function_handle | numeric | `'end'`] -
% Aggregation function; a numeric scalar or `'end'` means selecting the
% respective observation (counted from the first observation in the
% higher frequency period, after missing values have been kept or removed).
%
%
% __Description__
%
%
% __Example__
%
%

% -Copyright (c) 2017 OGResearch Ltd.

persistent INPUT_PARSER 

if isequal(INPUT_PARSER, [ ])
    INPUT_PARSER = extend.InputParser('TimeSeries/aggregate');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'TimeSeries'));
    INPUT_PARSER.addRequired('LowFreq', @(x) isa(x, 'Frequency') || isa(Frequency(x), 'Frequency'))
    INPUT_PARSER.addParameter('Missing', 'keep', @(x) any(strcmpi(x, {'keep', 'remove'})));
    INPUT_PARSER.addParameter( ...
        'Function', @mean, ...
        @(x) isa(x, 'function_handle') || (isnumeric(x) && all(round(x)==x)) || islogical(x) || isequal(x, 'end') ...
    );
    INPUT_PARSER.addParameter('Error', 'missing', @(x) any(strcmpi(x, {'missing', 'throw'})));
end

INPUT_PARSER.parse(high, lowFreq, varargin{:});
opt = INPUT_PARSER.Results;

TIME_SERIES = template(high);

if ~isa(lowFreq, 'Frequency')
    lowFreq = Frequency(lowFreq);
end

highFreq = getFrequency(high.Start);

assert( ...
    highFreq>lowFreq, ...
    'TimeSeries:aggregate', ...
    'Function aggregate( ) converts TimeSeries from higher to lower frequency.' ...
);
    
%--------------------------------------------------------------------------

if isnumeric(opt.Function) || islogical(opt.Function)
    select = opt.Function;
    opt.Function = @(x) x(select);
elseif isequal(opt.Function, 'end')
    opt.Function = @(x) x(end);
end

missingValue = high.MissingValue;
missingTest = high.MissingTest;

[highExtStart, highExtEnd, lowStart, lowEnd, ixHighInLowBins] = aggregateRange(high.Start, high.End, lowFreq);

highData = getDataFromRange(high, highExtStart, highExtEnd);
highDataSize = size(highData);
highDataNdims = numel(highDataSize);

keepMissing = strcmpi(opt.Missing, 'keep');
throwError = strcmpi(opt.Error, 'throw');

lowDataBins = cellfun(@(ix) aggregateBin(highData(ix, :)), ixHighInLowBins, 'UniformOutput', false);

lowData = cat(1, lowDataBins{:});
if highDataNdims>2
    lowData = reshape(lowData, [size(lowData, 1), highDataSize(2:end)]);
end

low = fill(TIME_SERIES, lowData, lowStart);
low = trim(low);

return


    function y = aggregateBin(x)
        numberOfObs = size(x, 1);
        numberOfColumns = size(x, 2);
        y = repmat(missingValue, 1, numberOfColumns);
        for ithColumn = 1 : numberOfColumns
            try
                if keepMissing
                    ixMissing = false(numberOfObs, 1);
                else
                    ixMissing = missingTest(x(:, ithColumn));
                end
                if any(~ixMissing)
                    y(1, ithColumn) = opt.Function( x(~ixMissing, ithColumn) );
                end
            catch Error
                if throwError
                    rethrow(Error);
                end
            end
        end
    end
end
