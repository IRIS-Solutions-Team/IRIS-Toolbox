function x = subsref(this, s)
% subsref  Subscripted reference for model and systemfit objects.
%
% Syntax for retrieving object with subset of parameterisations
% ==============================================================
%
%     M(Inx)
%
%
% Syntax for retrieving parameters or steady-state values
% ========================================================
%
%     M.Name
%
%
% Syntax to retrieve a std deviation or a cross-correlation of shocks
% ====================================================================
%
%     M.std_ShockName
%     M.corr_ShockName1__ShockName2
%
% Note that a double underscore is used to separate the names of shocks in
% correlation coefficients.
%
%
% Input arguments
% ================
%
% * `M` [ model | systemfit ] - Model or systemfit object.
%
% * `Inx` [ numeric | logical ] - Inx of requested parameterisations.
%
% * `Name` - Name of a variable, shock, or parameter.
%
% * `ShockName1`, `ShockName2` - Name of a shock.
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

% Dot-name reference m.name.
if strcmp(s(1).type,'.') && ischar(s(1).subs)
    name = s(1).subs;
    ell = lookup(this.Quantity, {name});
    posQty = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    if isnan(posQty) && isnan(posStdCorr)
        throw( exception.Base('Model:INVALID_NAME', 'error'), '', name ); %#ok<GTARG>
    end
    if ~isnan(posQty)
        % Quantity.
        x = model.Variant.getQuantity(this.Variant, posQty, ':');
    else
        % Std or Corr.
        x = model.Variant.getStdCorr(this.Variant, posStdCorr, ':');
    end
    x = permute(x, [1, 3, 2]);
    if isa(this.Behavior.DotReferenceFunc, 'function_handle')
        x = feval(this.Behavior.DotReferenceFunc, x);
    end
    s(1) = [ ];
    if ~isempty(s)
        x = subsref(x, s);
    end

elseif strcmp(s(1).type, '()') && length(s(1).subs)==1 ...
        && isnumeric(s(1).subs{1})
    % m(pos)
    subs = s(1).subs{1};
    nAlt = length(this);
    ixExceeds = subs>nAlt;
    if any(ixExceeds)
        throw( ...
            exception.Base('Model:IndexExceedsVariants', 'error'), ...
            exception.Base.alt2str( sort(subs(ixExceeds)) ) ...
            ); %#ok<GTARG>
    end
    x = subsalt(this, subs);
    s(1) = [ ];
    if ~isempty(s)
        x = subsref(x, s);
    end
    
elseif strcmp(s(1).type, '{}') && iscellstr(s(1).subs)
    % m{Name1, Name2}
    lsName = cellfun(@(x) x.Name, this.Variant, 'UniformOutput', false);
    pos = textfun.findnames(lsName, s(1).subs);
    ixNan = isnan(pos);
    if any(ixNan)
        throw( ...
            exception.Base('Model:InvalidVariantName', 'error'), ...
            s(1).subs{ixNan} ...
            );
    end
    s(1).type = '()';
    s(1).subs = { pos };
    x = subsref(this, s);
end
