function outp = binary(fun, a, b)

if isa(a, 'TimeSeries') && isa(b, 'TimeSeries')
    [aData, bData, outp, size1d] = bothTimeSeries( );
    outp.ColumnNames = "";
elseif isa(a, 'TimeSeries')
    [aData, bData, outp, size1d] = firstTimeSeries( );
else
    [aData, bData, outp, size1d] = secondTimeSeries( );
end

if ~iscell(aData) && ~iscell(bData)
    outpData = feval(fun, aData, bData);
elseif ~iscell(aData)
    outpData = cellfun(@(x) feval(fun, aData, x), bData, 'UniformOutput', false);
elseif ~iscell(bData)
    outpData = cellfun(@(x) feval(fun, x, bData), aData, 'UniformOutput', false);
else
    outpData = cellfun(@(x, y) feval(fun, x, y), aData, bData, 'UniformOutput', false);
end

assert( ...
    size(outpData, 1)==size1d, ...
    'TimeSeries:binary', ...
    'Function %s( ) applied along 2nd or higher dimension of TimeSeries objects must preserve size in first dimension.', ...
    fun ...
);

outp.Data = outpData;

return




    function [aData, bData, outp, size1d] = bothTimeSeries( )
        [range, aData, bData] = getDataFromAll('longRange', a, b);
        first = getFirst(range);
        outp = a;
        outp.Start = first;
        size1d = size(aData, 1);
        if iscell(aData) && ~iscell(bData)
            bData = num2cell(bData);
        elseif ~iscell(aData) && iscell(bData)
            aData = num2cell(aData);
        end
    end




    function [aData, bData, outp, size1d] = firstTimeSeries( )
        aData = a.Data;
        bData = b;
        outp = a;
        size1d = size(a.Data, 1);
    end




    function [aData, bData, outp, size1d] = secondTimeSeries( )
        aData = a;
        bData = b.Data;
        outp = b;
        size1d = size(b.Data, 1);
    end
end
