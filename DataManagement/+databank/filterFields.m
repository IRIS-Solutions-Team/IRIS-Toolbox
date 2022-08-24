% >=R2019b
%{
function outputNames = filterFields(inputDb, opt)

arguments
    inputDb (1, 1) {validate.databank(inputDb)}

    opt.Name = @all
    opt.Class (1, :) {locallyValidateClass} = @all
    opt.Value = @all
end
%}
% >=R2019b


% <=R2019a
%(
function outputNames = filterFields(inputDb, varargin)

persistent ip
if isempty(ip)
ip = inputParser();
    addParameter(ip, 'Name', @all);
    addParameter(ip, 'Class', @all);
    addParameter(ip, 'Value', @all);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


stringify = @(x) reshape(string(x), 1, []);

testForAll = @(x) isequal(x, @all) || isequal(x, "__all__") || isequal(x, '__all__');
isNameFilter = ~testForAll(opt.Name);
isClassFilter = ~testForAll(opt.Class);
isValueFilter = ~testForAll(opt.Value);

allKeys = stringify(fieldnames(inputDb));
if ~isNameFilter && ~isClassFilter && ~isValueFilter
    outputNames = allKeys;
    return
end

shortlist = allKeys;

if isNameFilter
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isequal(iris.utils.applyFunctions(n, opt.Name), true)
            shortlistUpdate(end+1) = n; 
        end
    end
    shortlist = shortlistUpdate;
end


if isClassFilter
    opt.Class = stringify(opt.Class);
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isa(inputDb, 'Dictionary')
            value = retrieve(inputDb, n);
        else
            value = inputDb.(n);
        end
        for c = opt.Class
            if isa(value, c)
                shortlistUpdate(end+1) = n;
                break
            end
        end
    end
    shortlist = shortlistUpdate;
end

if isValueFilter
    shortlistUpdate = string.empty(1, 0);
    for n = shortlist
        if isa(inputDb, 'Dictionary')
            value = retrieve(inputDb, n);
        else
            value = inputDb.(n);
        end
        if isequal(iris.utils.applyFunctions(value, opt.Value), true)
            shortlistUpdate(end+1) = n;
        end
    end
    shortlist = shortlistUpdate;
end

outputNames = shortlist;

end%

%
% Local Validators
%

function locallyValidateClass(x)
    %( 
    if isequal(x, @all) || isstring(x) || ischar(x) || iscellstr(x)
        return
    end
    error("Input value must be a string or array of strings.");
    %)
end%

%#ok<*AGROW>

