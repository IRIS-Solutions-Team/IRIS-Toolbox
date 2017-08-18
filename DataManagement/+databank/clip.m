function d = clip(d, newStart, newEnd)

frequency = newStart.Frequency;
listOfFields = fieldnames(d);
numberOfFields = numel(listOfFields);
for i = 1 : numberOfFields
    ithField = listOfFields{i};
    if isa(d.(ithField), 'TimeSeries')
        if d.(ithField).Frequency==frequency
            d.(ithField) = clip(d.(ithField), newStart, newEnd);
        end
        continue
    end
    if isstruct(d.(ithField))
        d.(ithField) = databank.clip(d.(ithField), newStart, newEnd);
    end
end

end
