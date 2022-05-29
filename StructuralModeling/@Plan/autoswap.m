% Type `web Plan/autoswap.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = autoswap(this, dates, namesToAutoswap, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('Plan.autoswap');
    addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
    addRequired(pp, 'datesToSwap', @validate.date);
    addRequired(pp, 'namesToAutoswap', @(x) ischar(x) || iscellstr(x) || isstring(x) || isequal(x, @all));
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
this = swap(this, dates, pairsToAutoswap, 'AnticipationStatus', opt.AnticipationStatus);

return

    function inxToAutoswap = hereIndexPairsToSwap( )
        %(
        namesToAutoswap = reshape(strip(string(namesToAutoswap)), 1, []);
        inxRemove = startsWith(namesToAutoswap, "^");
        namesToAutoswap(inxRemove) = [];
        inxToAutoswap = false(size(this.AutoswapPairs, 1), 1);
        namesReport = string.empty(1, 0);
        for n = namesToAutoswap
            inx = strcmp(n, this.AutoswapPairs(:, 1)) | strcmp(n, this.AutoswapPairs(:, 2));
            if any(inx)
                inxToAutoswap = inxToAutoswap | inx;
            else
                namesReport(end+1) = n;
            end
        end
        if ~isempty(namesReport)
            exception.error([ 
                "Plan:CannotAutoswapName"
                "Cannot autoswap this name: %s " 
            ], namesReport);
        end
        %)
    end%
end%

