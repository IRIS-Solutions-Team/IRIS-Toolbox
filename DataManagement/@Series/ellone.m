function [trend, rem] = ellone(this, order, lambda, varargin)

persistent ip
if isempty(ip)
    ip = extend.InputParser();
    addRequired(ip, 'inputSeries', @(x) isa(x, 'Series') && isnumeric(x.Data));
    addRequired(ip, 'order', @(x) isequal(x, 1) || isequal(x, 2));
    addRequired(ip, 'lambda', @(x) isnumeric(x) && isscalar(x) && x>0);

    addParameter(ip, 'Range', Inf, @validate.range);
end
parse(ip, this, order, lambda, varargin{:});
opt = ip.Results;


    [data, newStart] = getDataFromTo(this, opt.Range);
    numPeriods = size(data, 1);

    d = eye(numPeriods-order, numPeriods);
    D = d;
    if order==1
        D(:, 2:end) = D(:, 2:end) - d(:, 1:end-1);
    else
        D(:, 2:end) = D(:, 2:end) - 2*d(:, 1:end-1); 
        D(:, 3:end) = D(:, 3:end) + d(:, 1:end-2);
    end

    H = D*D';
    f = -D*data;
    bound = repmat(lambda, numPeriods-order, 1);
    nu = quadprog(H, f, [], [], [], [], -bound, bound);
    trendData = data - D'*nu;

    trend = fill(this, trendData, newStart);
    rem = fill(this, data - trendData, newStart);

end%

