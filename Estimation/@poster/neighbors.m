% 
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function d = neighbor(this, multiplicativeNeighbors, opt)

arguments
    this (1, 1) poster
    multiplicativeNeighbors (1, :) double

    opt.Neighbors (1, 1) struct = struct()
    opt.Min (1, 1) double = 1
end
%}
% >=R2019b


% <=R2019a
%(
function d = neighbor(this, multiplicativeNeighbors, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Neighbors", struct());
    addParameter(ip, "Min", 1);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


d = struct();

pList = this.ParameterNames;
pStar = this.InitParam;
numParams = numel(pList);
numNeighbors = numel(multiplicativeNeighbors);

for i = 1 : numParams
    x = cell(1, 4);

    % `x{1}` is the vector of x-axis points at which the log posterior is
    % evaluated.
    if isstruct(opt.Neighbors) && isfield(opt.Neighbors, pList{i})
        n = numel(opt.Neighbors.(pList{i}));
        pp = cell(1, n);
        pp(:) = {pStar};
        for j = 1 : n
            pp{j}(i) = opt.Neighbors.(pList{i})(j);
            x{1}(end+1, 1) = pp{j}(i);
        end
    else
        n = numNeighbors;
        pp = cell(1, numNeighbors);
        pp(:) = {pStar};
        for j = 1 : numNeighbors
            if pp{j}(i)>=opt.Min
                pp{j}(i) = pStar(i)*multiplicativeNeighbors(j);
            else
                pp{j}(i) = pStar(i) + (multiplicativeNeighbors(j)-1);
            end
            x{1}(end+1, 1) = pp{j}(i);
        end
    end

    % `x{2}` first column is minus the log posterior, second column is minus
    % the log likelis.
    x{2} = zeros(n, 4);

    % The function `eval` returns log posterior, not minus log posterior.
    [x{2}(:, 1), x{2}(:, 2), x{2}(:, 3), x{2}(:, 4)] = eval(this, pp{:}); %#ok<EVLC>
    x{2} = -x{2};

    % x{3} is normalized to its minimum
    x{3} = x{2};
    inxNa = any(~isfinite(x{3}), 2);
    x{3}(inxNa, :) = NaN;
    if any(~inxNa)
        x{3}(~inxNa, :) = x{3}(~inxNa, :) - min(x{3}(~inxNa, :), [], 1);
    end

    % `x{4}` is a vector of auxiliary information.
    x{4} = [this.InitParam(i), -this.InitLogPost, this.Lower(i), this.Upper(i)];

    d.(pList{i}) = x;
end

end%

