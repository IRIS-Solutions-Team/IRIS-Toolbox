% >=R2019b
%{
function outputDb = fromArray(array, names, startDate, opt)

arguments
    array double
    names (1, :) string
    startDate (1, 1) double

    opt.Comments (1, :) string = string.empty(1, 0)
    opt.OutputType (1, 1) string {mustBeMember(opt.OutputType, ["struct", "Dictionary", "__auto__"])} = "__auto__"
    opt.TargetDb {local_validateTargetDb} = false
        opt.AddToDatabank__TargetDb = []
end
%}
% >=R2019b


% <=R2019a
%(
function outputDb = fromArray(array, names, startDate, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, 'Comments', [], @(x) isempty(x) || isstring(x) || ischar(x) || iscellstr(x));
    addParameter(ip, 'OutputType', "__auto__", @(x) mustBeMember(x, ["struct", "Dictionary", "__auto__"]));
    addParameter(ip, 'TargetDb', false, @local_validateTargetDb);
        addParameter(ip, 'AddToDatabank__TargetDb', []);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], Except("AddToDatabank"));

outputDb = databank.backend.fromArrayNoFrills( ...
    permute(array, [2, 1, 3:ndims(array)]), names, startDate ...
    , opt.Comments, @all, opt.OutputType, opt.TargetDb ...
);

end%

%
% Local functions
%

function local_validateTargetDb(x)
    %(
    if isequal(x, false) || isstruct(x) || isa(x, 'Dictionary')
        return
    end
    error("Input values must be false, a struct, or a Dictionary.");
    %)
end%

