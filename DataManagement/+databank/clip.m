function d = clip(d, newStart, newEnd)

isNewStartInf = isequal(newStart, -Inf);
isNewEndInf = isequal(newEnd, Inf);

if isNewStartInf && isNewEndInf
    return
end

if ~isNewStartInf
    freq = DateWrapper.getFrequencyAsNumeric(newStart);
else
    freq = DateWrapper.getFrequencyAsNumeric(newEnd);
end

listOfFields = fieldnames(d);
numberOfFields = numel(listOfFields);
for i = 1 : numberOfFields
    ithField = listOfFields{i};
    if isa(d.(ithField), 'TimeSubscriptable')
        if d.(ithField).FrequencyAsNumeric==freq
            d.(ithField) = clip(d.(ithField), newStart, newEnd);
        end
        continue
    end
    if isstruct(d.(ithField))
        d.(ithField) = databank.clip(d.(ithField), newStart, newEnd);
    end
end

end%

