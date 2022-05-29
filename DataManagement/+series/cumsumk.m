function x = cumsumk(x, k, varargin)
% cumsumk  Cumulative sum over k periods
%
% Backend [IrisToolbox] function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('numeric.cumsumk');
    addRequired(pp, 'InputData', @isnumeric);
    addRequired(pp, 'K', @(x) isnumeric(x) && isscalar(x) && x==round(x));
    addOptional(pp, 'Rho', 1, @(x) isnumeric(x) && isscalar(x));
    addOptional(pp, 'naInit', 0, @isnumeric);
end
parse(pp, x, k, varargin{:});
rho = pp.Results.Rho;
naInit = pp.Results.naInit;

%--------------------------------------------------------------------------

sizeX = size(x);
ndimsX = ndims(x);
if ndimsX>2
    x = x(:, :);
end

numPeriods = sizeX(1);
for i = 1 : size(x, 2)
    inxNaN = isnan(x(:, i));
    x(inxNaN, i) = naInit;
    if k<0
        first = find(~isnan(x(:, i)), 1);
        if isempty(first)
            continue
        end
        
        for t = (first-k) : numPeriods
            x(t, i) = rho*x(t+k, i) + x(t, i);
        end
    elseif k>0
        last = find(~isnan(x(:, i)), 1, 'last');
        if isempty(last)
            continue
        end
        for t = (last-k) : -1 : 1
            x(t, i) = rho*x(t+k, i) + x(t, i);
        end        
    end
end

% Remove presample or postsample
if k<0
    x = x(1-k:end, :);
elseif k>0
    x = x(1:end-k, :);
end

if ndimsX>2
    sizeX(1) = sizeX(1) - abs(k);
    x = reshape(x, sizeX);
end

end%

