% >=R2019b
%(
function this = normalize(this, dates, opt)

arguments
    this TimeSubscriptable
    dates double

    opt.Aggregation {validate.mustBeA(opt.Aggregation, "function_handle")} = @mean
    opt.Mode (1, 1) string {startsWith(opt.Mode, ["mult", "add"], "ignoreCase", 1)} = "mult"
end
%)
% >=R2019b


% <=R2019a
%{
function this = normalize(this, dates, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Aggregation", @mean);
    addParameter(ip, "Mode", "mult");
end
parse(ip, varargin{:});
opt = ip.Results;;
%}
% <=R2019a


if startsWith(opt.Mode, "add", "ignoreCase", true)
    func = @minus;
else
    func = @rdivide;
end

sizeData = size(this.Data);
this.Data = this.Data(:, :);
norm = getData(this, reshape(dates, [], 1));
norm = norm(:, :);


%==========================================================================
for i = 1 : size(this.Data, 2)
    this.Data(:, i) = func(this.Data(:, i), opt.Aggregation(norm(:, i)));
end
%==========================================================================


if numel(sizeData)>2
    this.Data = reshape(this.Data, sizeData);
end
this = trim(this);

end%

