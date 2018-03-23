function outp = subsref(this, s)

currentType = s(1).type;
currentSubs = s(1).subs;

switch currentType
case '.'
    outp = builtin('subsref', this, s);
    return
case '()'
    if ~isempty(currentSubs)
        [newDates, newData, newColumnNames] = applyIndexingToTimeSeries( );
        this = initData(this, newDates, newData);
        this.ColumnNames = newColumnNames;
    end
    outp = this;
case '{}'
    if isempty(currentSubs)
        outp = this.Data;
    elseif isa(currentSubs{1}, 'Date') || isequal(currentSubs{1}, ':')
        [~, newData] = applyIndexingToTimeSeries( );
        outp = newData;
    elseif numel(currentSubs)==1 && isnumeric(currentSubs{1}) ...
            && numel(currentSubs{1})==1 && round(currentSubs{1})==currentSubs{1}
        this.Start = addTo(this.Start, -currentSubs{1});
        outp = this;
    else
        error( ...
            'TimeSeries:subsref', ...
            'Invalid subscripted reference to TimeSeries.' ...
        );
    end
end

s(1) = [ ];
if isempty(s)
    if  isa(outp, 'TimeSeries')
        outp = trim(outp);
    end
else
    outp = subsref(outp, s);
end

return




    function [newDates, newData, newColumnNames] = applyIndexingToTimeSeries( )
        time = currentSubs{1};
        [newData, newDates] = getData(this, time);
        newColumnNames = this.ColumnNames;
        if length(currentSubs)>1
            s1 = struct( );
            s1.type = '()';
            s1.subs = currentSubs;
            s1.subs{1} = ':';
            newData = builtin('subsref', newData, s1);
            if nargout>2
                newColumnNames = builtin('subsref', newColumnNames, s1);
            end
        end
    end
end
