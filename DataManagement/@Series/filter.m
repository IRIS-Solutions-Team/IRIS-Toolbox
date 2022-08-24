
% >=R2019b
%{
function this = filter(this, armani, range, opt)

arguments
    this Series
    armani (1, 1) Armani
    range {validate.range} = Inf

    opt.FillMissing = 0
end
%}
% >=R2019b


% <=R2019a
%(
function this = filter(this, armani, range, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "FillMissing", 0);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


[data, startDate] = getDataFromTo(this, range);

if ~isempty(opt.FillMissing)
    data = local_fillMissing(data, opt.FillMissing);
end

data = filter(armani, data);
this = fill(this, data, startDate);

end%

%
% Local functions
%

function data = local_fillMissing(data, option)
    %(
    if validate.numericScalar(option)
        data = fillmissing(data, "constant", option);
    elseif iscell(option)
        data = fillmissing(data, option{:});
    else
        data = fillmissing(data, option);
    end
    %)
end%

