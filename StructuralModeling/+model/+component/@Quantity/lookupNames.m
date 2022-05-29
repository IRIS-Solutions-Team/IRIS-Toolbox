% lookupNames  Look up positions of base names
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [pos, validNames, invalidNames] = lookupNames(this, names, throw, types)

names = reshape(string(names), 1, []);
pos = nan(size(names));
for i = 1 : numel(names)
    if ~isfield(this.LookupTable, names(i))
        continue
    end
    pos(i) = this.LookupTable.(names(i));
    if ~isempty(types) && ~any(this.Type(pos(i))==types)
        pos(i) = NaN;
    end
end

inxNa = isnan(pos);
validNames = names(~inxNa);
if nargout>=3
    invalidNames = names(inxNa);
end

if ~any(inxNa) || throw==""
    return
end

if ~isempty(invalidNames)
    if throw=="error"
        action = @exception.error;
    elseif throw=="warning"
        action = @exception.error;
    end
    action([
        "Quantity:NameNotFound"
        "This name does not exist in the model: %s "
    ], invalidNames);
end

end%

