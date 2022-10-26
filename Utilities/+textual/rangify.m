
function s = rangify(positions, strings, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Separator", " ");
    addParameter(ip, "Range", ":");
end
parse(ip, varargin{:});
opt = ip.Results;


    positions = sort(reshape(positions, 1, []));
    s = strings(positions);

    inxDiff = diff(positions)==1;
    inx = [false, inxDiff] & [inxDiff, false];
    s(inx) = "";
    s = join(s, opt.Separator);
    s = regexprep(s, "  +", opt.Range);

end%
