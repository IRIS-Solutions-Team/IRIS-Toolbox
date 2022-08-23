% getStdNames  Get names of standard deviations of shocks
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function listStd = getStdNames(this, request, clonePattern)

inxShocks = this.Type==31 | this.Type==32;
listShocks = string(this.Name(inxShocks));

if nargin>=3 && any(strlength(clonePattern)>0)
    listShocks = textual.fromPattern(listShocks, clonePattern);
end

listStd = string(model.Quantity.STD_PREFIX) + listShocks;

if nargin>=2 && ~isequal(request, @all)
    listStd = listStd(request);
end

listStd = cellstr(listStd);

end%

