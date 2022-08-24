function [m, dim] = mean(x, w, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tilting/quantiles');
    inputParser.addRequired('InputData', @(x) isnumeric(x) || isa(x, 'Series'));
    inputParser.addRequired('Weights', @isnumeric);
    inputParser.addOptional('Dim', 2, @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=1);
end
inputParser.parse(x, w, varargin{:});
dim = inputParser.Results.Dim;

if isa(x, 'Series')
    [x, dim] = applyFunctionAlongDim(x, @tilting.mean, w, dim);
    return
end

%--------------------------------------------------------------------------

if ~isempty(w) && all(w(1)==w)
    w = [ ];
else
    w = w(:);
end

[x, shape] = tilting.reshape(x, dim, 2);

if ~isempty(w)
    w = w / sum(w);
    m = sum(x .* w, 1, 'omitnan');
else
    m = mean(x, 1, 'omitnan');
end

m = tilting.reshape(m, shape);

end
