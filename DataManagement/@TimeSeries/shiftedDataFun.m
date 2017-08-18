function data = shiftedDataFun(data, fun, shift, order)

if nargin<2
    shift = -1;
end

if nargin<3
    order = 1;
end

for i = 1 : order
    shiftedData = TimeSeries.shiftDataKeepRange(data, shift);
    if iscell(data)
        data = cellfun(fun, data, shiftedData, 'UniformOutput', false);
    else
        data = fun(data, shiftedData);
    end
end

end
