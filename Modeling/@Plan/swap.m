function this = swap(this, dates, varargin)
% swap  Swap endogeneity and exogeneity of variable-shock pairs at specified dates
%
% __Syntax__
%
%     p = swap(p, datesToSwap, pairToSwap, pairToSwap, ...)
%
%
% __Input Arguments__
%
% * `p` [ Plan ] - Simulation plan.
%
% * `datesToSwap` [ DateWrapper | numeric ] - Dates at which the
% endogeneity and exogeneity of the variable-shock pairs will be swapped.
%
% * `pairToSwap` [ cellstr ] - Cell array consisting of the name of a
% variables (transition or measurement) and the name of a shock (transition
% or measurement) whose endogeneity and exogeneity will be swapped in the
% simulation at specified dates, `datesToSwap`. Any number of pairs can be
% specified as input arguments to the `swap(~)` function.
%
%
% __Output Arguments__
%
% * `p` [ Plan ] - Simulation plan with the new information included.
%
%
% __Description__
%
% The simulation plan only specifies the dates and the names of variables
% and shocks; it does not include the particular values to which the
% variables will be exogenized. These values need to be included in the
% input databank entering the [`@Model/simulate(~)`](Model/index.html#simulate) 
% function.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


if isempty(varargin)
    pairsToSwap = cell.empty(1, 0);
elseif isstruct(varargin{1})
    pairsToSwap = varargin{1};
    varargin(1) = [ ];
else
    inxOfPairs = cellfun(@(x) (iscellstr(x) || isa(x, 'string')) && size(x, 2)==2, varargin);
    pairsToSwap = cell.empty(0, 2);
    while ~isempty(inxOfPairs) && inxOfPairs(1)
        pairsToSwap = [ pairsToSwap
                        varargin{1}  ];
        varargin(1) = [ ];
        inxOfPairs(1) = [ ];
    end
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('Plan.swap');
    parser.addRequired('Plan', @(x) isa(x, 'Plan'));
    parser.addRequired('DatesToSwap', @DateWrapper.validateDateInput);
    parser.addRequired('PairsToSwap', @validatePairsToSwap);
    parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
end
parser.parse(this, dates, pairsToSwap, varargin{:});
opt = parser.Options;

if numel(varargin)==1 && isstruct(varargin{1})
    inputStruct = varargin{1};
    namesToExogenize = fieldnames(inputStruct);
    numOfPairs = numel(namesToExogenize);
    pairsToSwap = cell(numOfPairs, 2);
    for i = 1 : numOfPairs
        pairsToSwap(i, :) = { namesToExogenize{i}, ...
                              inputStruct.(namesToExogenize{i}) };
    end
end

%--------------------------------------------------------------------------

numOfPairs = size(pairsToSwap, 1);
anticipationMismatch = cell(1, 0);
for i = 1 : numOfPairs
    setToValue = this.SwapId;
    this.SwapId = this.SwapId + uint16(1);
    [nameToExogenize, nameToEndogenize] = pairsToSwap{i, :};

    [this, anticipateEndogenized] = ...
        implementEndogenize( this, ...
                             dates, ...
                             nameToEndogenize, ...
                             setToValue, ...
                             'AnticipationStatus=', opt.AnticipationStatus );

    [this, anticipateExogenized] = ...
        implementExogenize( this, ...
                            dates, ...
                            nameToExogenize, ...
                            setToValue, ...
                            'AnticipationStatus=', opt.AnticipationStatus );

    if ~isequal(anticipateEndogenized, anticipateExogenized)
        % Throw a warning (future error) if the anticipation
        % status of the variable and that of the shock fail to
        % match
        anticipationMismatch{end+1} = sprintf( '%s[%s] <-> %s[%s]', ...
                                               nameToExogenize, ...
                                               statusToString(anticipateExogenized), ...
                                               nameToEndogenize, ...
                                               statusToString(anticipateEndogenized) );
        % Do the swap using the anticipation status of the shock
        % This is for GPMN compatibility only
        % Will be removed in the near future
        [this, anticipateEndogenized] = ...
            implementEndogenize( this, ...
                                 dates, ...
                                 nameToEndogenize, ...
                                 setToValue, ...
                                 'AnticipationStatus=', anticipateEndogenized );

        [this, anticipateExogenized] = ...
            implementExogenize( this, ...
                                dates, ...
                                nameToExogenize, ...
                                setToValue, ...
                                'AnticipationStatus=', anticipateEndogenized );
    end
end

if ~isempty(anticipationMismatch)
    THIS_ERROR = { 'Plan:AnticipationStatusMismatch' 
                   [ 'Anticipation status mismatch in this swapped pair: %s \n', ...
                     '    Use anticipate(~) to align anticipation status of the paired variable and shock\n', ...
                     '    This warning will become an error in a future IRIS release' ] };
    throw( exception.Base(THIS_ERROR, 'warning'), ...
           anticipationMismatch{:} );
end

end%


%
% Local Functions
%


function flag = validatePairsToSwap(pairs)
    if numel(pairs)==1 && isstruct(pairs{1})
        flag = true;
        return
    end
    if iscellstr(pairs) && size(pairs, 2)==2
        flag = true;
        return
    end
    flag = false;
end%




function varargout = statusToString(varargin)
    varargout = varargin;
    for i = 1 : nargin
        if isequal(varargin{i}, true)
            varargout{i} = 'true';
        else
            varargout{i} = 'false';
        end
    end
end%
