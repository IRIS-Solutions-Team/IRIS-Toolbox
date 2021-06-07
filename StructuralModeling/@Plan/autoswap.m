% Type `web Plan/autoswap.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function this = autoswap(this, dates, namesToAutoswap, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.autoswap');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'datesToSwap', @validate.date);
    addRequired(pp, 'namesToAutoswap', @(x) ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @all));
    addParameter(pp, {'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
end
pp.parse(this, dates, namesToAutoswap, varargin{:});
opt = pp.Options;
inxToAutoswap = false(size(this.AutoswapPairs, 1), 1); 
if isequal(namesToAutoswap, @all)
    inxToAutoswap(:) = true;
else
    inxToAutoswap = hereIndexPairsToSwap( );
end
pairsToAutoswap = this.AutoswapPairs(inxToAutoswap, :);
this = swap(this, dates, pairsToAutoswap, 'AnticipationStatus=', opt.AnticipationStatus);

return

    function inxToAutoswap = hereIndexPairsToSwap( )
        %(
        namesToAutoswap = cellstr(namesToAutoswap);
        namesToAutoswap = transpose(namesToAutoswap(:));
        numNames = numel(namesToAutoswap);
        inxToAutoswap = false(size(this.AutoswapPairs, 1), 1);
        inxValid = true(1, numNames);
        for i = 1 : numel(namesToAutoswap)
            name = namesToAutoswap{i};
            inx = strcmp(name, this.AutoswapPairs(:, 1)) ...
                | strcmp(name, this.AutoswapPairs(:, 2));
            if any(inx)
                inxToAutoswap = inxToAutoswap | inx;
            else
                inxValid(i) = false;
            end
        end
        if any(~inxValid)
            thisError = [ 
                "Plan:CannotAutoswapName"
                "Cannot autoswap this name: %s " 
                ];
            throw( exception.Base(thisError, 'error'), ...
                namesToAutoswap{~inxValid} );
        end
        %)
    end%
end%

