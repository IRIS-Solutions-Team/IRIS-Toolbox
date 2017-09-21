function d = addstd(this, d)
% addstd  Add model std deviations to databank
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     D = addstd(M, ~D)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose std deviations will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the model std deviations will be added.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the model std deviations added.
%
%
% __Description__
%
% Any existing databank entries whose names coincide with the names of
% model std deviations will be overwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addstd(m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

if nargin<2
    d = struct( );
end

%--------------------------------------------------------------------------

listOfStdNames = getStdName(this.Quantity);
ne = numel(listOfStdNames);
vecStd = this.Variant.StdCorr(:, 1:ne, :);
for i = 1 : ne
    d.(listOfStdNames{i}) = permute(vecStd(1, i, :), [2, 3, 1]);
end

end
