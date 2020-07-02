% swap  Swap endogeneity and exogeneity of variable-shock pairs at specified dates
%{
% Syntax
%--------------------------------------------------------------------------
%
%     p = swap(p, datesToSwap, pairToSwap, pairToSwap, ...)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`p`__ [ Plan ] 
%
%     Simulation plan to which the new swapped pairs will be added.
%
%
% __`datesToSwap`__ [ DateWrapper ]
%
%     Dates at which the endogeneity and exogeneity of the variable-shock
%     pairs will be swapped.
%
%
% __`pairToSwap`__ [ string ] 
% 
%     String array consisting of the name of a variables (transition or
%     measurement) and the name of a shock (transition or measurement)
%     whose endogeneity and exogeneity will be swapped in the simulation at
%     specified dates, `datesToSwap`. Any number of pairs can be specified
%     as input arguments to the `swap(~)` function.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`p`__ [ Plan ] 
%
%     Simulation plan with the new swap information included.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% The simulation plan only specifies the dates and the names of variables
% and shocks; it does not include the particular values to which the
% variables will be exogenized. These values need to be included in the
% input databank entering the [`@Model/simulate(~)`](Model/index.html#simulate) 
% function.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function this = swap(this, dates, varargin)

if isempty(varargin)
    pairsToSwap = cell.empty(1, 0);
elseif isstruct(varargin{1})
    pairsToSwap = varargin{1};
    varargin(1) = [ ];
else
    inxPairs = cellfun(@(x) (iscellstr(x) || isa(x, 'string')) && size(x, 2)==2, varargin);
    pairsToSwap = cell.empty(0, 2);
    while ~isempty(inxPairs) && inxPairs(1)
        pairsToSwap = [ 
            pairsToSwap
            varargin{1}  
        ];
        varargin(1) = [ ];
        inxPairs(1) = [ ];
    end
end

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.swap');
    addRequired(pp, 'Plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'DatesToSwap', @DateWrapper.validateDateInput);
    addRequired(pp, 'PairsToSwap', @locallyValidatePairsToSwap);
    addParameter(pp, {'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
end
%)
opt = pp.parse(this, dates, pairsToSwap, varargin{:});

if isscalar(varargin) && isstruct(varargin{1})
    inputStruct = varargin{1};
    namesToExogenize = keys(inputStruct);
    pairsToSwap = string.empty(0, 2);
    for n = namesToExogenize
        pairsToSwap = [pairsToSwap; n, inputStruct.(n)];
    end
end
pairsToSwap = string(pairsToSwap);

%--------------------------------------------------------------------------

anticipationMismatch = cell(1, 0);
for pair = transpose(pairsToSwap)
    swapId = this.DEFAULT_SWAP_LINK;

    [this, anticipateEndogenized] = implementEndogenize( ...
        this, dates, pair(2), swapId ...
        , 'AnticipationStatus=', opt.AnticipationStatus ...
    );

    [this, anticipateExogenized] = implementExogenize( ...
        this, dates, pair(1), swapId ...
        , 'AnticipationStatus=', opt.AnticipationStatus ...
    );

    if ~isequal(anticipateEndogenized, anticipateExogenized)
        % Throw a warning (future error) if the anticipation
        % status of the variable and that of the shock fail to
        % match
        anticipationMismatch{end+1} = sprintf( ...
            '%s[%s] <-> %s[%s]' ...
            , pair(1), locallyStatusToString(anticipateExogenized) ...
            , pair(2), locallyStatusToString(anticipateEndogenized) ...
        );
    end
end

if ~isempty(anticipationMismatch)
    thisError = [ 
        "Plan:AnticipationStatusMismatch" 
        "Anticipation status mismatch in this swapped pair: %s "
    ];
    throw(exception.Base(thisError, 'error'), anticipationMismatch{:});
end

end%


%
% Local Functions
%


function flag = locallyValidatePairsToSwap(pairs)
    %(
    if numel(pairs)==1 && isstruct(pairs{1})
        flag = true;
        return
    end
    if (iscellstr(pairs) || isstring(pairs)) && ndims(pairs)==2 && size(pairs, 2)==2
        flag = true;
        return
    end
    flag = false;
    %)
end%


function varargout = locallyStatusToString(varargin)
    %(
    varargout = varargin;
    for i = 1 : nargin
        if isequal(varargin{i}, true)
            varargout{i} = 'true';
        else
            varargout{i} = 'false';
        end
    end
    %)
end%
