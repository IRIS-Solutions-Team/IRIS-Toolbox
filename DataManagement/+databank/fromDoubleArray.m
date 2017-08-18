function databank = fromDoubleArray(databank, array, names, range)

persistent TIME_SERIES
if ~isa(TIME_SERIES, 'TimeSeries')
    TIME_SERIES = TimeSeries( );
end

numberOfSeries = size(array, 1);


