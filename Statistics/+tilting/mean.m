function [m, dim] = mean(x, w, dim)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('tilting/quantiles');
    INPUT_PARSER.addRequired('InputData', @(x) isnumeric(x) || isa(x, 'TimeSeriesBase'));
    INPUT_PARSER.addRequired('Weights', @isnumeric);
    INPUT_PARSER.addOptional('Dim', @(x) isnumeric(x) && numel(x)==1 && x==round(x) && x>=1);
end
INPUT_PARSER.parse(x, w, varargin{:});
dim = INPUT_PARSER.Results.Dim;

if isa(x, 'TimeSeriesBase')
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
