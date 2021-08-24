% 
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function d = neighbor(this, multiplicativeNeighbors, options)

arguments
    this (1, 1) poster
    multiplicativeNeighbors (1, :) double

    options.Neighbors (1, 1) struct = struct()
end

d = struct();

pList = this.ParameterNames;
pStar = this.InitParam;
numParams = numel(pList);
numNeighbors = numel(multiplicativeNeighbors);

for i = 1 : numParams
    x = cell(1, 4);

    % `x{1}` is the vector of x-axis points at which the log posterior is
    % evaluated.
    if isstruct(options.Neighbors) && isfield(options.Neighbors, pList{i})
        n = numel(options.Neighbors.(pList{i}));
        pp = cell(1, n);
        pp(:) = {pStar};
        for j = 1 : n
            pp{j}(i) = options.Neighbors.(pList{i})(j);
            x{1}(end+1, 1) = pp{j}(i);
        end
    else
        n = numNeighbors;
        pp = cell(1, numNeighbors);
        pp(:) = {pStar};
        for j = 1 : numNeighbors
            pp{j}(i) = pStar(i)*multiplicativeNeighbors(j);
            x{1}(end+1, 1) = pp{j}(i);
        end
    end

    % `x{2}` first column is minus the log posterior, second column is minus
    % the log likelis.
    x{2} = zeros(n, 4);

    % The function `eval` returns log posterior, not minus log posterior.
    [x{2}(:, 1), x{2}(:, 2), x{2}(:, 3), x{2}(:, 4)] = eval(this, pp{:}); %#ok<EVLC>
    x{2} = -x{2};

    x{3} = x{2};
    x{3} = x{3} - min(x{3}, [], 1);

    % `x{3}` is a vector of auxiliary information.
    x{4} = [this.InitParam(i), -this.InitLogPost, this.Lower(i), this.Upper(i)];

    d.(pList{i}) = x;
end

end%

