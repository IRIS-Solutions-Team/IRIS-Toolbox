function [flag, list] = isnan(this, varargin)
% isnan  Check for NaNs in model object.
%
% Syntax
% =======
%
%     [flag, list] = isnan(M, 'parameters')
%     [flag, list] = isnan(M, 'sstate')
%     [flag, list] = isnan(M, 'derivatives')
%     [flag, list] = isnan(M, 'solution')
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True if at least one `NaN` value exists
% in the queried category.
%
% * `list` [ cellstr ] - List of parameters (if called with `'parameters'`)
% or variables (if called with `'sstate'`) that are assigned NaN in at
% least one parameterisation, or equations (if called with `'derivatives'`)
% that produce an NaN derivative in at least one parameterisation.
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

if ~isempty(varargin) && (ischar(varargin{1}) &&  ~strcmp(varargin{1}, ':'))
    request = lower(strtrim(varargin{1}));
    varargin(1) = [ ];
else
    request = 'all';
end

if ~isempty(varargin) && (isnumeric(varargin{1}) || islogical(varargin{1}))
    vecAlt = varargin{1};
    if isinf(vecAlt)
        vecAlt = ':';
    end
else
    vecAlt = ':';
end

%--------------------------------------------------------------------------


switch request
    case 'all'
        x = model.Variant.getQuantity(this.Variant, ':', vecAlt);
        ixNan = any(isnan(x), 3);
        if nargout>1
            list = this.Quantity.Name(ixNan);
        end
        flag = any(ixNan);
    case {'p', 'parameter', 'parameters'}
        x = model.Variant.getQuantity(this.Variant, ':', vecAlt);
        ixNan = any(isnan(x), 3);
        ixNan = ixNan & this.Quantity.Type==TYPE(4);
        if nargout>1
            list = this.Quantity.Name(ixNan);
        end
        flag = any(ixNan);
    case {'sstate'}
        % Check for NaNs in transition and measurement variables.
        x = model.Variant.getQuantity(this.Variant, ':', vecAlt);
        ixNan = any(isnan(x), 3);
        ixNan = ixNan & ...
            (this.Quantity.Type==TYPE(1) ...
            | this.Quantity.Type==TYPE(2));
        if nargout>1
            list = this.Quantity.Name(ixNan);
        end
        flag = any(ixNan);
    case {'solution'}
        T = this.solution{1}(:, :, vecAlt);
        R = this.solution{2}(:, :, vecAlt);
        % Transition matrix can be empty in 2nd dimension (no lagged
        % variables).
        if size(T, 1)>0 && size(T, 2)==0
            ixNan = false(1, size(T, 3));
        else
            ixNan = any(any(isnan(T), 1), 2) | any(any(isnan(R), 1), 2);
            ixNan = ixNan(:).';
        end
        flag = any(ixNan);
        if nargout>1
            list = ixNan;
        end
    case {'expansion'}
        expand = this.Expand{1}(:, :, vecAlt);
        ixNan = isempty(expand) | any(any(isnan(expand), 1), 2);
        ixNan = ixNan(:)';
        if nargout>1
            list = ixNan;
        end
        flag = any(ixNan);
    case {'deriv', 'derivative', 'derivatives'}
        nAlt = length(this);
        nEqtn = length(this.Equation);
        eqSelect = true(1, nEqtn);
        list = false(1, nEqtn);
        flag = false;
        opt = struct( );
        opt.select = true;
        for iAlt = 1 : nAlt
            [~, ~, ixNanDeriv] = diffFirstOrder(this, eqSelect, iAlt, opt);
            flag = flag || any(ixNanDeriv);
            list(ixNanDeriv) = true;
        end
        list = this.Equation.Input(list);
    otherwise
        utils.error('Invalid request: %s ', varargin{1});
end

end
