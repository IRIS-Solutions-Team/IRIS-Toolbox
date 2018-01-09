function this = clip(this, newStart, newEnd)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('TimeSubscriptable/clip');
    INPUT_PARSER.addRequired('TimeSeries', @(x) isa(x, 'TimeSubscriptable'));
    INPUT_PARSER.addRequired('NewStartDate', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, -Inf));
    INPUT_PARSER.addRequired('NewEndDate', @(x) isa(x, 'Date') || isa(x, 'DateWrapper') || isequal(x, Inf));
end

thisStart = this.Start;
thisEnd = this.End;
thisFrequency = this.Frequency;

assert( ...
    isequal(newStart, -Inf) || validateDate(this, newStart), ...
    'TimeSeries:clip', ...
    'Illegal start date.' ...
);

assert( ...
    isequal(newEnd, Inf) || validateDate(this, newEnd), ...
    'TimeSeries:clip', ...
    'Illegal end date.' ...
);

if newStart>newEnd
    this = emptyData(this);
    return
end

if thisStart>=newStart && thisEnd<=newEnd
    return
end

sizeOfData = size(this.Data);
ndimsOfData = ndims(this.Data);
thisData = this.Data(:, :);
clipStart( );
clipEnd( );
if ndimsOfData>2
    thisData = reshape(thisData, [size(thisData, 1), sizeOfData(2:end)]);
end
this.Start = thisStart;
this.Data = thisData;

return


    function clipStart( )
        if size(thisData, 1)==0
            return
        end
        if thisStart>newStart
            return
        end
        if newStart<=thisEnd
            posNewStart = positionOf(newStart, thisStart);
            thisData(1:posNewStart-1, :) = [ ];
            thisStart = newStart;
            return
        else
            this = emptyData(this);
        end
    end


    function clipEnd( )
        if size(thisData, 1)==0
            return
        end
        if thisEnd<newEnd
            return
        end
        if newEnd>=thisStart
            posNewEnd = positionOf(newEnd, thisStart);
            thisData(posNewEnd+1:end, :) = [ ];
            return
        else
            this = emptyDate(this);
        end
    end
end


