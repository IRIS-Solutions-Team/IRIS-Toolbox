function [flag, list] = isnan(this, varargin)
% isnan  Check for NaNs in model object.
%
% __Syntax__
%
%     [Flag, List] = isnan(M, 'Parameters')
%     [Flag, List] = isnan(M, 'Steady')
%     [Flag, List] = isnan(M, 'Derivatives')
%     [Flag, List] = isnan(M, 'Solution')
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object.
%
%
% __Output arguments__
%
% * `Flag` [ `true` | `false` ] - True if at least one `NaN` value exists
% in the queried category.
%
% * `List` [ cellstr ] - List of parameters (if called with `'Parameters'`)
% or variables (if called with `'Steady'`) that are assigned NaN in at
% least one parameter variant, or equations (if called with `'Derivatives'`)
% that produce an NaN derivative in at least one parameterisation.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

if ~isempty(varargin) && (ischar(varargin{1}) &&  ~strcmp(varargin{1}, ':'))
    request = lower(strtrim(varargin{1}));
    varargin(1) = [ ];
else
    request = 'All';
end

persistent INPUT_PARSER 
if isempty(INPUT_PARSER)
    validRequests = {'All', 'Parameters', 'Sstate', 'Steady', 'Solution', 'Derivatives'};
    INPUT_PARSER = extend.InputParser('model/isnan');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('Request', @(x) any(strcmpi(x, validRequests)));
end
INPUT_PARSER.parse(this, request);

if ~isempty(varargin) && (isnumeric(varargin{1}) || islogical(varargin{1}))
    variantsRequested = varargin{1};
    if isinf(variantsRequested)
        variantsRequested = ':';
    end
else
    variantsRequested = ':';
end

%--------------------------------------------------------------------------


if strcmpi(request, 'All')
    x = this.Variant.Values(:, :, variantsRequested);
    ixNan = any(isnan(x), 3);
    if nargout>1
        list = this.Quantity.Name(ixNan);
    end
    flag = any(ixNan);

elseif strcmpi(request, 'Parameters')
    x = this.Variant.Values(:, :, variantsRequested);
    ixNan = any(isnan(x), 3);
    ixNan = ixNan & this.Quantity.Type==TYPE(4);
    if nargout>1
        list = this.Quantity.Name(ixNan);
    end
    flag = any(ixNan);

elseif any(strcmpi(request, {'Steady', 'SState'}))
    % Check for NaNs in transition and measurement variables.
    x = this.Variant.Values(:, :, variantsRequested);
    ixNan = any(isnan(x), 3);
    ixNan = ixNan & ...
        (this.Quantity.Type==TYPE(1) ...
        | this.Quantity.Type==TYPE(2));
    if nargout>1
        list = this.Quantity.Name(ixNan);
    end
    flag = any(ixNan);

elseif strcmpi(request, 'Solution')
    T = this.Variant.Solution{1}(:, :, variantsRequested);
    R = this.Variant.Solution{2}(:, :, variantsRequested);
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

elseif strcmpi(request, 'Derivatives')
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
end

end
