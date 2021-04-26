function this = rename(this, method, varargin)

% >=R2019b
%(
arguments
    this model.component.Quantity
    method (1, 1) string {mustBeMember(method, ["pair", "list"])}
end
%)
% >=R2019b

stringify = @(x) reshape(string(x), 1, []);

if isempty(this.OriginalNames)
    this.OriginalNames = stringify(this.Name);
end

if method=="pair"
    [oldNames, newNames] = locallyListsFromPairs(this, varargin{:});
else
    oldNames = stringify(varargin{1});
    newNames = stringify(varargin{2});
end

oldNames = strip(oldNames);
newNames = strip(newNames);

pos = lookupNames(this, oldNames, "error", []);
this.Name(pos) = newNames;
validateNames(this);

end%

%
% Local functions
%

function [oldNames, newNames] = locallyListsFromPairs(this, varargin)
    %(
    renamePairs = cell(numel(varargin), 2);

    numPairs = numel(varargin);
    oldNames = repmat("", 1, numPairs);
    newNames = repmat("", 1, numPairs);

    for i = 1 : numPairs
        pair = string(varargin{i});
        if numel(pair)==1
            match = regexp(pair, "\w+", "match");
            oldNames(i) = match(1);
            newNames(i) = match(2);
        else
            oldNames(i) = pair(1);
            newNames(i) = pair(2);
        end
    end
end%

