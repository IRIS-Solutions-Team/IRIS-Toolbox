function lsCorr = getCorrName(this, request)
% getCorrName  Get names of cross-correlation coefficients of shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ixe = this.Type==int8(31) | this.Type==int8(32);
lse = this.Name(ixe);
ne = sum(ixe);

pos = tril(ones(ne), -1)==1;
[row, col] = find(pos);

try
    request; %#ok<VUNUS>
catch
    request = 1 : length(row);
end

nRequest = length(request);
lsCorr = cell(1, nRequest);
for i = request
    name = ['corr_', lse{col(i)}, '__', lse{row(i)}];
    lsCorr{i} = name;
end

end

