function this = plus(this, d2)
% See help on dbase/dbplus

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

f2 = fieldnames(d2);
for i = 1 : numel(f2)
    this.(f2{i}) = d2.(f2{i});
end

end%

