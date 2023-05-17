
% >=R2019b
%(
function [flag, missing] = exist(db, fields, opt)

arguments
    db (1, 1) {validate.databank(db)}
    fields (1, :) string

    opt.WhenMissing (1, 1) string {mustBeMember(opt.WhenMissing, ["error", "warning", "silent"])} = "error"
end
%)
% >=R2019b


% <=R2019a
%{
function [flag, missing] = exist(db, fields, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "WhenMissing", "error");
end
parse(ip, varargin{:});
opt = ip.Results;
%}
% <=R2019a



    fields = textual.stringify(fields);
    flag = true;
    missing = string.empty(1, 0);
    for n = fields
        if isfield(db, n)
            continue
        end
        flag = false;
        missing(end+1) = n;
    end

    if ~flag
        exception.(opt.WhenMissing)([
            "Databank"
            "This field is missing from the databank: %s"
        ], missing);
    end

end%

