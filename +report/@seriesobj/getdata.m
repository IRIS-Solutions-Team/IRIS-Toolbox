function [Outp,Time] = getdata(This,Inp,Range,ColStruct)
% getdata  [Not a public function] Evaluate data for report/series.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nCol = length(Range);
if isempty(ColStruct)
    doDates( );
else
    doColStruct( );
end


% Nested functions...


%**************************************************************************

    
    function doDates( )
        % Table range can consist of dates with different frequencies.
        % For each frequency, find an input tseries with matching
        % frequency.
        if isequal(Range,Inf) || length(Inp) == 1
            [Outp,Time] = Inp{1}(Range,:);
            return
        end
        Time = Range;
        
        rangeFreq = datfreq(Range);
        dataFreq = cellfun(@freq,Inp);
        % We cannot pre-allocate `outp` properly because the number of
        % columns is unknown at this point.
        Outp = [ ];
        for ii = [0,1,2,4,6,12,52,365]
            rangePos = rangeFreq == ii;
            dataPos = dataFreq == ii;
            if any(rangePos) && any(dataPos)
                dataPos = find(dataPos,1);
                thisRange = Range(rangePos);
                thisData = Inp{dataPos}(thisRange,:);
                if isempty(Outp)
                    Outp = nan(nCol,size(thisData,2));
                end
                Outp(rangePos,:) = thisData;
            end
        end
    end % doDates( )


%**************************************************************************
    
    
    function doColStruct( )
        nRow = size(Inp{1},2);
        Outp = nan(nCol,nRow);
        Time = 1 : nCol;
        for ii = 1 : nCol
            func = ColStruct(ii).func;
            date = ColStruct(ii).date;
            x = Inp{1};
            if isfunc(func)
                x = feval(func,x);
                if ~isa(x,'tseries') && ~isnumericscalar(x)
                    utils.error('seriesobj:getdata', ...
                        ['Function %s fails to evaluate to tseries or numeric scalar ', ...
                        'when applied to this series: ''%s''.'], ...
                        func2str(func),This.title);
                end
            end
            if isa(x,'tseries')
                x = x(date);
            end
            if ~isnumericscalar(x)
                if ~isa(x,'tseries') && ~isnumericscalar(x)
                    utils.error('seriesobj:getdata', ...
                        ['Value in column #%g ', ...
                        'fails evalute to numeric scalar for this series: ''%s''.'], ...
                        ii,This.title);
                end
            end
            try %#ok<TRYNC>
                Outp(ii,:) = x;
            end
        end
    end % doColStruct( )


end
