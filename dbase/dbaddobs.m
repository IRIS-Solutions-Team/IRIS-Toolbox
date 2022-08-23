function d = dbaddobs(d, add, time)

lsf = fieldnames(d);
for i = 1 : length(lsf)
    name = lsf{i};
    if ~isfield(add, name)
        continue
    end
    if isa(d.(name), 'Series') && isa(add.(name), 'Series')
        d.(name)(time) = add.(name)(time);
    elseif isstruct(d.(name)) && isstruct(add.(name))
        d.(name) = dbaddobs(d.(name), add.(name));
    end
end

end%

