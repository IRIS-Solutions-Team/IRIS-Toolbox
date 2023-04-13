
% >=R2019b
%(
function this = quickAssign(this, from, opt)

arguments
    this Model
    from (1, 1) struct
    opt.WhenFails (1, 1) string = "error"
end
%)
% >=R2019b


% <=R2019a
%{
function this = quickAssign(this, from, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "WhenFails", "error");
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a


    failed = string.empty(1, 0);
    for i = 1 : numel(this.Quantity.Name(1:end-1))
        name = this.Quantity.Name{i};
        if isfield(from, name)
            try
                this.Variant.Values(1, i, :) = from.(name);
            catch
                failed(end+1) = string(name);
            end
        end
    end

    if ~isempty(failed)
        exception.(opt.WhenFails)([
            "Model"
            "Assigning this name failed: %s"
        ], failed);
    end

end%

