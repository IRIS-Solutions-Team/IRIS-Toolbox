function this = rename(this, method, varargin)

% >=R2019b
%{
arguments
    this model.Quantity
    method (1, 1) string {mustBeMember(method, ["pair", "list", "func"])}
end

arguments (Repeating)
    varargin
end
%}
% >=R2019b


allNames = textual.stringify(this.Name);
ttrendName = textual.stringify(this.RESERVED_NAME_TTREND);
posTtrend = find(allNames==ttrendName);
inx = allNames==ttrendName;

if isempty(this.OriginalNames)
    this.OriginalNames = textual.stringify(this.Name);
end

if method=="func"
    this = local_applyFunc(this, varargin{:});
else
    if method=="pair"
        [oldNames, newNames] = local_listsFromPairs(this, varargin{:});
    else
        oldNames = textual.stringify(varargin{1});
        newNames = textual.stringify(varargin{2});
    end
    oldNames = strip(oldNames);
    newNames = strip(newNames);
    pos = lookupNames(this, oldNames, "error", []);
    if iscell(this.Name)
        this.Name(pos) = cellstr(newNames);
    end
end

%
% Reset the ttrend name no matter what
%
posTrendLine = locateTrendLine(this, NaN);
if iscell(this.Name)
    this.Name{posTrendLine} = char(this.RESERVED_NAME_TTREND);
else
    this.Name(posTrendLine) = string(this.RESERVED_NAME_TTREND);
end

validateNames(this);

end%


function [oldNames, newNames] = local_listsFromPairs(this, varargin)
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
    %)
end%


function this = local_applyFunc(this, func)
    %(
    allNames = textual.stringify(this.Name);
    for i = setdiff(1:numel(allNames), locateTrendLine(this, NaN))
        allNames(i) = func(allNames(i));
    end
    if iscell(this.Name)
        this.Name = cellstr(allNames);
    end
    %)
end%

