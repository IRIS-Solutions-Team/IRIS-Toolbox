
% >=R2019b
%{
function this = randomlyGrowing(range, params, options)

arguments
    range {mustBeNonempty, validate.mustBeProperRange(range)}
    params (1, 2) double = [0, 1]

    options.Initial = 0
    options.Exponentiate = true
    options.Dimensions = 1
    options.Comment = ""
    options.UserData = []
end
%}
% >=R2019b


% <=R2019a
%(
function this = randomlyGrowing(range, params, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addParameter(pp, 'Initial', 0);
    addParameter(pp, 'Exponentiate', true);
    addParameter(pp, 'Dimensions', 1);
    addParameter(pp, 'Comment', "");
    addParameter(pp, 'UserData', []);
end
parse(pp, varargin{:});
options = pp.Results;
%)
% <=R2019a


numPeriods = dater.rangeLength(range);
data = params(1) + randn([numPeriods, options.Dimensions]) * params(2);
data(1, :) = options.Initial;
data = cumsum(data, 1);
if options.Exponentiate
    data = exp(data);
end

range = double(range);
this = Series(range(1), data, options.Comment, options.UserData);

end%

