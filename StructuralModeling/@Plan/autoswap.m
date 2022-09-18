
function this = autoswap(this, dates, namesToAutoswap, varargin)

%(
persistent ip
if isempty(ip)
    ip = inputParser();
    addRequired(ip, 'plan', @(x) isa(x, 'Plan'));
    addRequired(ip, 'datesToSwap', @validate.date);
    addRequired(ip, 'namesToAutoswap', @(x) ischar(x) || iscellstr(x) || isstring(x) || isequal(x, @all));
    addParameter(ip, 'AnticipationStatus', @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
        addParameter(ip, 'Anticipate__AnticipationStatus', []);
end
parse(ip, this, dates, namesToAutoswap, varargin{:});
opt = ip.Results;

opt = iris.utils.resolveOptionAliases(opt, [], true);
%)


    inxToAutoswap = false(size(this.AutoswapPairs, 1), 1); 
    if isequal(namesToAutoswap, @all)
        inxToAutoswap(:) = true;
    else
        inxToAutoswap = here_indexPairsToSwap( );
    end
    pairsToAutoswap = this.AutoswapPairs(inxToAutoswap, :);
    this = swap(this, dates, pairsToAutoswap, 'AnticipationStatus', opt.AnticipationStatus);

    return


    function inxToAutoswap = here_indexPairsToSwap( )
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

