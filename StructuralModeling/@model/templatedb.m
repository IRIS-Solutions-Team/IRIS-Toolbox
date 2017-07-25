function d = templatedb(this)
% templatedb  Create model-specific template database.
%
%
% Syntax
% =======
%
%     D = templatedb(M)
%
% Input arguments
% ================
%
%
% * `M` [ model ] - Model object for which the empty template database will
% be created.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Empty database (a 0x0 structr) with a field for each
% of the model variables, shocks, and parameters.
%
%
% Description
% ============
%
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

lsExtra = { ...
    model.RESERVED_NAME_TTREND, ...
    };
d = createTemplateDbase(this.Quantity, lsExtra);

end
