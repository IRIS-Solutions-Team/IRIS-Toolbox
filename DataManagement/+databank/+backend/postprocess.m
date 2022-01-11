function db = postprocess(db, names, postprocess)

if isempty(postprocess) || isempty(names)
    return
end

if isa(postprocess, 'function_handle')
    postprocess = {postprocess};
end

for n = textual.stringify(names)
    for i = 1 : numel(postprocess)
        if ~isempty(postprocess{i})
            db.(n) = postprocess{i}(db.(n));
        end
    end
end

end%

