
function d = redate(d, oldDate, newDate)

    list = fieldnames(d);
    freq = dater.getFrequency(oldDate);
    inxSeries = structfun(@(x) isa(x, 'Series') && getFrequency(x)==freq, d);
    inxStructs = structfun(@isstruct, d);

    % Cycle over all Series objects
    for i = reshape(find(inxSeries), 1, [])
       d.(list{i}) = redate(d.(list{i}), oldDate, newDate);
    end

    % Call recusively redate(~) on nested databases
    for i = reshape(find(inxStructs), 1, [])
       d.(list{i}) = databank.redate(d.(list{i}), oldDate, newDate);
    end

end%

