function x = applyFunctions(x, func)

if nargin<2 || isempty(func)
    return
end

if ~iscell(func)
    func = {func};
end

for i = 1 : numel(func)
    if ~isa(func{i}, 'function_handle')
        continue
    end
    x = func{i}(x);
end

end%

