function int = hpdi(this, coverage, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('tseries.hpdi');
    inputParser.addRequired('InputSeries', @(x) isa(x, 'tseries'));
    inputParser.addRequired('Coverage', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=100);
    inputParser.addOptional('Dim', 2, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
end
inputParser.parse(this, coverage, varargin{:});
dim = inputParser.Results.Dim;

%--------------------------------------------------------------------------

int = unop(@numeric.hpdi, this, dim, coverage, dim);

end

