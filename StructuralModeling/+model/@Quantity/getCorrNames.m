% getCorrNames  Get names of cross-correlation coefficients of shocks
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function namesCorr = getCorrNames(this, request, clonePattern)

inxShocks = this.Type==31 | this.Type==32;
listShocks = string(this.Name(inxShocks));

if nargin>=3 && any(strlength(clonePattern)>0)
    listShocks = clonePattern(1) + listShocks + clonePattern(2);
end

ne = sum(inxShocks);
[row, col] = find(tril(true(ne), -1));

if nargin<2 || isequal(request, @all)
    request = 1 : numel(row);
end

namesCorr = repmat("", 1, numel(request));
for i = reshape(request, 1, [])
    name = model.Quantity.CORR_PREFIX + listShocks(col(i)) + "__" + listShocks(row(i));
    namesCorr(i) = name;
end

namesCorr = cellstr(namesCorr);

end%


