function d = addplainparam(this, d)
% addplainparam  Add plain parameters to databank
%
% __Syntax__
%
%     D = addplainparam(M, ~D)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose parameters will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the model parameters will be added;
% if omitted, a new databank will be created.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the model parameters added.
%
%
% __Description__
%
% Function `addplainparam( )` adds all plain parameters to the databank,
% `D`, as arrays with values for all parameter variants. Plain parameters
% include all model parameters except std deviations and cross-correlations
% of shocks.
%
% Any existing databank entries whose names coincide with the names of
% model parameters will be overwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addplainparam(m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

if nargin<2
    d = struct( );
end

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
for i = find(ixp)
    ithName = this.Quantity.Name{i};
    d.(ithName) = permute(this.Variant.Values(:, i, :), [1, 3, 2]);
end

end
