% >=R2019b
%{
function this = randomlyGrowing(range, params, opt)

arguments
    range {mustBeNonempty, validate.mustBeProperRange(range)}
    params (1, 2) double = [0, 1]

    opt.Initial = 0
    opt.Exponentiate = true
    opt.Dimensions = 1
    opt.Comment = ""
    opt.UserData = []
end
%}
% >=R2019b


% <=R2019a
%(
function this = randomlyGrowing(range, params, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Initial", 0);
    addParameter(ip, "Exponentiate", true);
    addParameter(ip, "Dimensions", 1);
    addParameter(ip, "Comment", "");
    addParameter(ip, "UserData", []);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


numPeriods = dater.rangeLength(range);
data = params(1) + randn([numPeriods, opt.Dimensions]) * params(2);
data(1, :) = opt.Initial;
data = cumsum(data, 1);
if opt.Exponentiate
    data = exp(data);
end

range = double(range);
this = Series(range(1), data, opt.Comment, opt.UserData);

end%

