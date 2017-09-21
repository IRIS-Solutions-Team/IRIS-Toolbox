function [flag, lsBound, lsPrior, lsNotFound] = chkpriors(this, priorStruct)
% chkpriors  Check compliance of initial conditions with priors and bounds.
%
% __Syntax__
%
%     Flag = chkpriors(M, E)
%     [Flag, InvalidBound, InvalidPrior, NotFound] = chkpriors(M, E)
%
%
% __Input Arguments__
%
% * `M` [ struct ] - Model object.
%
% * `E` [ struct ] - Prior structure. See `model/estimate` for details.
%
%
% __Output Arguments__
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
% __Options__
%
%
% __Description__
%
%
% __Example__
%

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/chkpriors');
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addRequired('PriorStruct', @isstruct);
end
INPUT_PARSER.parse(this, priorStruct);

%--------------------------------------------------------------------------

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
    ithParam = priorStruct.(lsp{iName}) ;
    
    if isempty(ithParam)
        initVal = NaN;
    else
        initVal = ithParam{1};
    end
    
    if isnan(initVal)
        % Use initial condition from model object
        if ~isnan(posQty(iName))
            initVal = this.Variant.Values(:, posQty(iName), :);
        elseif ~isnan(posStdCorr(iName))
            initVal = this.Variant.Values(:, posStdCorr(iName), :);
        end
    end
    
    % get prior function
    if numel(ithParam)>3 && ~isempty(ithParam{4})
        fh = ithParam{4} ;
        % check prior consistency
        if ~isa(fh, 'function_handle') || ~isfinite(fh(initVal))
            ixValidPrior(iName) = false ;
        end
    end
    
    % check bounds consistency
    if numel(ithParam)<2 || isempty(ithParam{2}) || ithParam{2}<=-realmax
        lowerBound = -Inf;
    else
        lowerBound = ithParam{2};
    end
    if ~isequal(lowerBound, -Inf)
        if initVal<lowerBound
            ixValidBound(iName) = false ;
        end
    end
    
    if numel(ithParam)<3 || isempty(ithParam{3}) || ithParam{3}>=realmax
        upperBound = Inf;
    else
        upperBound = ithParam{3};
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




