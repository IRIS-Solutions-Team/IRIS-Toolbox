%{
% 
% # `isnan` ^^(Model)^^
% 
% {== Check for NaNs in model object. ==}
% 
% 
%  ## Syntax ##
% 
%      [Flag, List] = isnan(M, 'Parameters')
%      [Flag, List] = isnan(M, 'Steady')
%      [Flag, List] = isnan(M, 'Derivatives')
%      [Flag, List] = isnan(M, 'Solution')
% 
% 
%  ## Input Arguments ##
% 
%  `M` [ model ]
% >
% > Model object.
% >
% 
%  ## Output arguments ##
% 
%  `Flag` [ `true` | `false` ]
% >
% > True if at least one `NaN` value exists
% > in the queried category.
% >
% 
%  `List` [ cellstr ]
% > 
% > List of parameters (if called with `'Parameters'`)
% > or variables (if called with `'Steady'`) that are assigned NaN in at
% > least one parameter variant, or equations (if called with `'Derivatives'`)
% > that produce an NaN derivative in at least one parameterisation.
% >
% 
%  ## Description ##
% 
% 
%  ## Examples ##
% 
% 
%}
% --8<--


function [flag, list] = isnan(this, varargin)

if ~isempty(varargin) ...
    && (validate.stringScalar(varargin{1}) && string(varargin{1})~=":")
    request = lower(strtrim(string(varargin{1})));
    varargin(1) = [ ];
else
    request = "all";
end

%( Input parser
persistent pp 
if isempty(pp)
    validRequests = ["all", "parameters", "sstate", "steady", "solution", "derivatives"];
    pp = extend.InputParser('model/isnan');
    addRequired(pp, 'Model', @(x) isa(x, 'model'));
    addRequired(pp, 'Request', @(x) any(x==validRequests));
end
%)
parse(pp, this, request);

if ~isempty(varargin) && (isnumeric(varargin{1}) || islogical(varargin{1}))
    variantsRequested = varargin{1};
    if isinf(variantsRequested)
        variantsRequested = ':';
    end
else
    variantsRequested = ':';
end

%--------------------------------------------------------------------------


switch request
    case "all"
        x = this.Variant.Values(:, :, variantsRequested);
        inxNaN = any(isnan(x), 3);
        if nargout>1
            list = this.Quantity.Name(inxNaN);
        end
        flag = any(inxNaN);

    case "parameters"
        x = this.Variant.Values(:, :, variantsRequested);
        inxNaN = any(isnan(x), 3);
        inxNaN = inxNaN & this.Quantity.Type==4;
        if nargout>1
            list = this.Quantity.Name(inxNaN);
        end
        flag = any(inxNaN);

    case {"steady", "sstate"}
        % Check for NaNs in transition and measurement variables.
        x = this.Variant.Values(:, :, variantsRequested);
        inxNaN = any(isnan(x), 3);
        inxNaN = inxNaN & ...
            (this.Quantity.Type==1 ...
            | this.Quantity.Type==2);
        if nargout>1
            list = this.Quantity.Name(inxNaN);
        end
        flag = any(inxNaN);

    case "solution"
        inxSolved = beenSolved(this, variantsRequested);
        flag = ~all(inxSolved);
        list = ~inxSolved;

    case "derivatives"
        nv = length(this);
        numEquations = length(this.Equation);
        eqSelect = true(1, numEquations);
        list = false(1, numEquations);
        flag = false;
        opt = struct( );
        opt.select = true;
        for v = 1 : nv
            [~, ~, indexNaNDeriv] = diffFirstOrder(this, eqSelect, v, opt);
            flag = flag || any(indexNaNDeriv);
            list(indexNaNDeriv) = true;
        end
        list = this.Equation.Input(list);
end

end%

