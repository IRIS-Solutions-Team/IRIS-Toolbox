function opt = resolveAlias(opt, x, empty)

remove = string.empty(1, 0);
for n = reshape(string(fieldnames(x)), 1, [])
    for a = x.(n)
        if ~isequal(opt.(a), empty)
            opt.(n) = opt.(a);
        end
    end
    remove = [remove, x.(n)]; %#ok<AGROW> 
end

if ~isempty(remove)
    opt = rmfield(opt, remove);
end

end%
