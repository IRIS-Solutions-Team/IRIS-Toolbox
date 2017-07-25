function d = emptydb(this)
% emptydb  Create model-specific database with empty time series for all variables, shocks and parameters.
%
%
% Syntax
% =======
%
%     D = emptydb(M)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model for which the empty database will be created.
%
%
% Output arguments
% =================
%
% * `D` [ struct ] - Database with an empty time series for each
% variable and each shock, and a vector of currently assigned values for
% each parameter.
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

TYPE = @int8;

LS_RESERVED_NAME = { ...
    model.RESERVED_NAME_TTREND, ...
    };

LS_COMMENT = { ...
    model.COMMENT_TTREND, ...
    };

%--------------------------------------------------------------------------

nAlt = length(this);
lsName = [ this.Quantity.Name, LS_RESERVED_NAME ];
x = cell(1, length(lsName));
d = cell2struct(x, lsName, 2);
ixp = this.Quantity.Type==TYPE(4);
emptyTSeries = Series([ ], zeros(0, nAlt));

% Add and comment a time series for each variable.
cmt = getLabelOrName(this.Quantity);
for i = find(~ixp)
    name = this.Quantity.Name{i};
    d.(name) = comment(emptyTSeries, cmt{i});
end

% Add and comment a time series for reserved name.
for i = 1 : length(LS_RESERVED_NAME)
    name = LS_RESERVED_NAME{i};
    cmt = LS_COMMENT{i};
    d.(name) = comment(emptyTSeries, cmt);
end

% Add a value for each parameter.
d = addparam(this, d);

end
