
function [C, R] = acf(this, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addOptional(ip, 'Dates', Inf, @validate.date);

    addParameter(ip, 'Demean', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'Order', 0, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=0);
    addParameter(ip, 'SmallSample', true, @(x) isequal(x, true) || isequal(x, false));
    addParameter(ip, 'RemoveNaN', true, @validate.logicalScalar);
end
ip.parse(varargin{:});
dates = ip.Results.Dates;
opt = rmfield(ip.Results, "Dates");


    data = getData(this, dates);
    if ndims(data)>3
        data = data(:, :, :);
    end

    % Remove leading and trailing NaN rows
    if opt.RemoveNaN
        inxToRemove = any(isnan(data(:, :)), 2);
        data = data(~inxToRemove, :, :);
    end

    C = covfun.acovfsmp(data, opt);
    if nargout>1
        R = covfun.cov2corr(C);
    end

end%

