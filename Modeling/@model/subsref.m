function output = subsref(this, s)
% subsref  Subscripted reference for model objects.
%
% __Syntax for Retrieving Object with Subset of Parameter Variants__
%
%     M(Inx)
%
%
% __Syntax for Retrieving Parameters or Steady-State Values__
%
%     M.Name
%
%
% __Syntax to Retrieve Std Deviations or Cross-correlation of Shocks__
%
%     M.std_ShockName
%     M.corr_ShockName1__ShockName2
%
% A double underscore is used to separate the names of shocks in
% correlation coefficients.
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
% * `Inx` [ numeric | logical ] - Inx of requested parameterisations.
%
% * `Name` - Name of a variable, shock, or parameter.
%
% * `ShockName1`, `ShockName2` - Name of a shock.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Dot-name reference m.name.
if strcmp(s(1).type,'.') && ischar(s(1).subs)
    name = s(1).subs;
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    if ~isnan(posQty)
        % Quantity.
        output = this.Variant.Values(:, posQty, :);
    elseif ~isnan(posStdCorr)
        % Std or Corr.
        output = this.Variant.StdCorr(:, posStdCorr, :);
    else
        throw( exception.Base('Model:InvalidName', 'error'), '', name ); %#ok<GTARG>
    end
    output = permute(output, [1, 3, 2]);
    if isa(this.Behavior.DotReferenceFunc, 'function_handle')
        output = feval(this.Behavior.DotReferenceFunc, output);
    end
    s(1) = [ ];
    if ~isempty(s)
        output = subsref(output, s);
    end
    return
end

if strcmp(s(1).type, '()') && length(s(1).subs)==1 ...
        && isnumeric(s(1).subs{1})
    % m(pos)
    variantsRequested = s(1).subs{1};
    output = getVariant(this, variantsRequested);
    s(1) = [ ];
    if ~isempty(s)
        output = subsref(output, s);
    end
    return
end

throw( exception.Base('General:InvalidReference', 'error'), ...
       class(this) );

end%
