function this = condition(this, dates, names, varargin)

stringify = @(x) reshape(string(x), 1, []);
names = stringify(names);

swapPairs = cell.empty(1, 0);
namesInvalid = string.empty(1, 0);
for n = names
    inx = n==this.SlackPairs(:, 1);
    if nnz(inx)==0
        namesInvalid(end+1) = n;
        continue
    end % if
    swapPairs(end+1) = {this.SlackPairs(inx, :)};
end % for

if ~isempty(namesInvalid)
    exception.error([
        "Plan:InvalidNameInContext"
        "This name cannot be conditioned upon in the simulation Plan: %s "
    ], namesInvalid);
end % if

this = swap(this, dates, swapPairs{:});

end%

