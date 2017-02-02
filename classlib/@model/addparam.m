function d = addparam(this, d)
% addparam  Add model parameters to a database (struct).
%
% Syntax
% =======
%
%     D = addparam(M,D)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose parameters will be added to database
% (struct) `D`.
%
% * `D` [ struct ] - Database to which the model parameters will be added.
%
%
% Output arguments
% =================
%
% * `D [ struct ] - Database with the model parameters added.
%
%
% Description
% ============
%
% If there are database entries in `D` whose names conincide with the model
% parameters, they will be overwritten.
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
