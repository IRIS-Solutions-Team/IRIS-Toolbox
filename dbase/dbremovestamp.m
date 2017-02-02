function d = dbremovestamp(d)
lsField = fieldnames(d);
for i = 1 : length(lsField)
    name = lsField{i};
    if isstruct(d.(name))
        d.(name) = dbremovestamp(d.(name));
    elseif isa(d.(name), 'tseries')
        d.(name) = removeStamp(d.(name));
    end
end