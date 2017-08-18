function d = addparam(this, d)
% addparam  Add model parameters to a database
%
% Syntax
% =======
%
%     D = addparam(M, D)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose parameters will be added to database
% `D`.
%
% * `D` [ struct ] - Database to which the model parameters will be added.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with the model parameters added.
%
%
% Description
% ============
%
% Any existing database entries whose names coincide with the names of
% model parameters will be overwritten.
%
%
% Example
% ========
%
%     d = struct( );
%     d = addparam(m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

try
    d; %#ok<VUNUS>
catch
    d = struct( );
end

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
for i = find(ixp)
    name = this.Quantity.Name{i};
    value = model.Variant.getQuantity(this.Variant, i, ':');
    d.(name) = permute(value, [1, 3, 2]);
end

end
