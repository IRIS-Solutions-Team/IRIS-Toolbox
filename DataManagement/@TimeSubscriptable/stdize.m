function [this, meanX, stdX] = stdize(this, varargin)

persistent parser
if isempty(parser)
    parser = extend.InputParser('TimeSubscriptable.stdize');
    parser.addRequired('inputSeries', @(x) isa(x, 'TimeSubscriptable'));
    parser.addOptional('normalize', 0, @(x) isequal(x, 0) || isequal(x, 1));
end
parser.parse(this, varargin{:});
normalize = parser.Results.normalize;

%--------------------------------------------------------------------------

[this.Data, meanX, stdX] = numeric.stdize(this.Data, normalize);

end%
