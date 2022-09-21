
function [this, outputDb, pos, sortKey] = sort(this, inputDb, sortBy, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addRequired(ip, 'a', @(x) isa(x, 'SVAR'));
    addRequired(ip, 'inputDb', @(x) isempty(x) || validate.databank(x));
    addRequired(ip, 'sortBy', @(x) ischar(x) || isstring(x));
    addOptional(ip, 'Progress', false, @(x) isequal(x, true) || isequal(x, false));
end
parse(ip, this, inputDb, sortBy, varargin{:});
opt = ip.Results;

isData = nargout>1 && ~isempty(inputDb);

ny = size(this.A, 1);
numAlt = size(this.A, 3);

if isData
    req = datarequest('e', this, inputDb, Inf);
    rng = req.Range;
    e = req.E;
    numData = size(e, 3);
    if numData ~= numAlt
        utils.error('SVAR:sort', ...
            ['The number of data sets (%g) must match ', ...
            'the number of parameterisations (%g).'], ...
            numData, numAlt);
    end
end

% Look for the simulation horizon and the presence of asymptotic responses
% in the `sortBy` string.
[h, isY] = myparsetest(this, sortBy);

if opt.Progress
    progress = ProgressBar("[IrisToolbox] SVAR/sort")
end

XX = [];
for iAlt = 1 : numAlt
    [S, Y] = here_simulate(); %#ok<ASGLU>
    XX = here_evalSortKey(XX);
    if opt.Progress
        update(progress, iAlt/numAlt);
    end
end

pos = here_sort();
this = subsalt(this, pos);

outputDb = inputDb;
if isData
    e = e(:, :, pos);
    outputDb = myoutpdata(this, rng, e, [ ], this.ResidualNames, inputDb);
end

return

    function [S, Y] = here_simulate()
        % Simulate the test statistics.
        S = zeros(ny, ny, 0);
        Y = nan(ny, ny, 1);
        % Impulse responses.
        if h > 0
            S = timedom.var2vma(this.A(:, :, iAlt), this.B(:, :, iAlt), h);
        end
        % Asymptotic impulse responses.
        if isY
            A = polyn.var2polyn(this.A(:, :, iAlt));
            C = sum(A, 3);
            Y = C\this.B(:, :, iAlt);
        end
    end%


    function XX = here_evalSortKey(XX)
        % Evalutate the sort criterion.
        try
            X = eval(sortBy);
            XX = [XX, X(:)];
        catch err
            utils.error('SVAR:sort', ...
                ['Error evaluating the sort string ''%s''.\n', ...
                '\tUncle says: %s'], ...
                sortBy, err.message);
        end
    end%


    function pos = here_sort( )
        % Sort by the distance from median.
        n = size(XX, 2);
        if n > 0
            MM = median(XX, 2);
            sortKey = nan(1, n);
            for ii = 1 : n
                sortKey(ii) = sum((XX(:, ii) - MM).^2 / n);
            end
            [sortKey, pos] = sort(sortKey, 'ascend');
        end
    end%
end%
