function [flag, lsBound, lsPrior, lsNotFound] = chkpriors(this, priorStruct)
% chkpriors  Check compliance of initial conditions with priors and bounds.
%
% Syntax
% =======
%
%     Flag = chkpriors(M,E)
%     [Flag,InvalidBound,InvalidPrior,NotFound] = chkpriors(M,E)
%
%
% Input arguments
% ================
%
% * `M` [ struct ] - Model object.
%
% * `E` [ struct ] - Prior structure. See `model/estimate` for details.
%
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if all parameters exist in the model
% object, and have initial values consistent with lower and upper bounds,
% and prior distributions.
%
% * `InvalidBound` [ cellstr ] - Cell array of parameters whose initial
% values are inconsistent with lower or upper bounds.
%
% * `InvalidPrior` [ cellstr ] - Cell array of parameters whose initial
% values are inconsistent with priors.
%
% * `NotFound` [ cellstr ] - Cell array of parameters that do not exist in
% the model object `M`.
%
%
% Options
% ========
%
%
% Description
% ============
%
%
% Example
% ========

%--------------------------------------------------------------------------

% Validate input arguments
pp = inputParser( ) ;
pp.addRequired('E', @isstruct) ;
pp.parse(priorStruct) ;

% Check consistency by looping over parameters
lsp = fields(priorStruct) ;
np = numel(lsp) ;

ixValidPrior = true(1, np) ;
ixValidBound = true(1, np) ;

ell = lookup(this.Quantity, lsp);
posQty = ell.PosName;
posStdCorr = ell.PosStdCorr;
ixFound = ~isnan(posQty) | ~isnan(posStdCorr);

for iName = find(ixFound)
    
    param = priorStruct.(lsp{iName}) ;
    
    if isempty(param)
        initVal = NaN;
    else
        initVal = param{1};
    end
    
    if isnan(initVal)
        % use initial condition from model object
        if ~isnan(posQty(iName))
            initVal = model.Variant.getQuantity( ...
                this.Variant, posQty(iName), ':' ...
                );
        else
            initVal = model.Variant.getStdCorr( ...
                this.Variant, posStdCorr(iName), ':' ...
                );
        end
    end
    
    % get prior function
    if numel(param)>3 && ~isempty(param{4})
        fh = param{4} ;
        % check prior consistency
        if ~isa(fh, 'function_handle') || ~isfinite(fh(initVal))
            ixValidPrior(iName) = false ;
        end
    end
    
    % check bounds consistency
    if numel(param)<2 || isempty(param{2}) || param{2}<=-realmax
        lowerBound = -Inf;
    else
        lowerBound = param{2};
    end
    if ~isequal(lowerBound, -Inf)
        if initVal<lowerBound
            ixValidBound(iName) = false ;
        end
    end
    
    if numel(param)<3 || isempty(param{3}) || param{3}>=realmax
        upperBound = Inf;
    else
        upperBound = param{3};
    end
    if ~isequal(upperBound, Inf)
        if initVal>upperBound
            ixValidBound(iName) = false ;
        end
    end
end

flag = all(ixValidPrior) && all(ixValidBound) && all(ixFound) ;
lsPrior = lsp(~ixValidPrior) ;
lsBound = lsp(~ixValidBound) ;
lsNotFound = lsp(~ixFound) ;

end




