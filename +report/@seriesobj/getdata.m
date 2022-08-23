function [outp, time] = getdata(this, inp, range, colStruct)
% getdata  Evaluate data for report/series
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

numOfColumns = length(range);
if isempty(colStruct)
    doDates( );
else
    doColStruct( );
end

return


    function doDates( )
        % Table range can consist of dates with different frequencies.
        % For each frequency, find an input tseries with matching
        % frequency.
        if isequal(range, Inf) || length(inp)==1
            [outp, time] = inp{1}(range, :);
            return
        end
        time = range;
        
        freqOfRange = dater.getFrequency(range);
        freqOfData = nan(size(inp));
        for i = 1 : numel(inp)
            freqOfData(i) = inp{i}.FrequencyAsNumeric;
        end
        freqOfData = cellfun(@(x) dater.getFrequency(x.Start), inp);
        % We cannot pre-allocate `outp` because the number of columns is
        % unknown at this point.
        outp = [ ];
        for ii = [0, 1, 2, 4, 6, 12, 52, 365]
            rangePos = freqOfRange==ii;
            dataPos = freqOfData==ii;
            if any(rangePos) && any(dataPos)
                dataPos = find(dataPos, 1);
                thisrange = range(rangePos);
                thisData = inp{dataPos}(thisrange, :);
                if isempty(outp)
                    outp = nan(numOfColumns, size(thisData, 2));
                end
                outp(rangePos, :) = thisData;
            end
        end
    end%


    function doColStruct( )
        isnumericscalar = @(x) isnumeric(x) && isscalar(x);
        nRow = size(inp{1}, 2);
        outp = nan(numOfColumns, nRow);
        time = 1 : numOfColumns;
        for ii = 1 : numOfColumns
            func = colStruct(ii).func;
            date = colStruct(ii).date;
            x = inp{1};
            if isa(func, 'function_handle')
                x = feval(func, x);
                if ~isa(x, 'Series') && ~isnumericscalar(x)
                    utils.error('seriesobj:getdata', ...
                        ['Function %s fails to evaluate to tseries or numeric scalar ', ...
                        'when applied to this series: ''%s''.'], ...
                        func2str(func), this.title);
                end
            end
            if isa(x, 'Series')
                x = x(date);
            end
            if ~isnumericscalar(x)
                if ~isa(x, 'Series') && ~isnumericscalar(x)
                    utils.error('seriesobj:getdata', ...
                        ['Value in column #%g ', ...
                        'fails evalute to numeric scalar for this series: ''%s''.'], ...
                        ii, this.title);
                end
            end
            try %#ok<TRYNC>
                outp(ii, :) = x;
            end
        end
    end% 
end
