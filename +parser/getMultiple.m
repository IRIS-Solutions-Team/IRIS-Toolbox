function multiple = getMultiple(list)
% getMultiple  Find entries with multiple occurrence in list of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

multiple = cell(1,0);

nn = length(list); % Number of non-unique names.
[lsu, posu, posn] = unique(list);
nu = length(posu); % Number of unique names.

if nu<nn
    posn = repmat(posn, 1, nu);
    match = repmat(1:nu, nn, 1);
    ixMultiple = sum(posn==match, 1)>1;
    multiple = lsu(ixMultiple);
    multiple = fliplr(multiple); % Matlab reports last occurrences in posn, flip to fix the order.
end

end