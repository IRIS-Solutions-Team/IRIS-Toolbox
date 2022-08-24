% >=R2019b
%{
function [listFields, tokens, outputDb] = filter(inputDb, opt)

arguments
    inputDb {validate.mustBeDatabank}

    opt.Name {local_validateName} = @all
    opt.Class {local_validateClass} = @all
    opt.Filter {local_validateFilter} = []
end
%}
% >=R2019b


% <=R2019a
%(
function [listFields, tokens, outputDb] = filter(inputDb, varargin)

persistent ip
if isempty(ip)
    ip = inputParser(); 
    addParameter(ip, "Name", @all);
    addParameter(ip, "Class", @all);
    addParameter(ip, "Filter", []);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


if isa(inputDb, 'Dictionary')
    listFields = keys(inputDb);
else
    listFields = fieldnames(inputDb);
end
listFields = reshape(cellstr(listFields), 1, [ ]);

%
% Filter field names
%
[listFields, tokens] = local_filterNames(listFields, opt);


%
% Filter field classes
%
[listFields, tokens] = local_filterClass(inputDb, listFields, tokens, opt);

%
% Run user filter
%
[listFields, tokens] = local_runUserFilter(inputDb, listFields, tokens, opt);

listFields = string(listFields);
if nargout>=3
    outputDb = databank.copy(inputDb, 'SourceNames', listFields);
end

end%


%
% Local Functions
%


function [listFields, tokens] = local_filterNames(listFields, opt)
    %(
    tokens = repmat({string.empty(1, 0)}, size(listFields));
    if isequal(opt.Name, @all) || all(strcmpi(opt.Name, '--all'))
        return
    end
    isRegular = false;
    if isa(opt.Name, 'Rxp')
        isRegular = true;
        opt.Name = opt.Name.String;
    else
        if ~isa(opt.Name, 'string')
            opt.Name = string(opt.Name);
        end
        if isscalar(opt.Name) 
            if startsWith(opt.Name, "--rexp:")
                isRegular = true;
                opt.Name = erase(opt.Name, "--rexp:");
            end
        end
    end
    if isRegular
        [start, tokens] = regexp(listFields, opt.Name, 'start', 'tokens', 'once');
        inxName = ~cellfun('isempty', start);
    else
        opt.Name = reshape(opt.Name, 1, [ ]);
        inxName = ismember(listFields, opt.Name);
    end
    inxName = reshape(inxName, 1, [ ]);
    listFields = listFields(inxName);
    tokens = tokens(inxName);
    %)
end%


function [listFields, tokens] = local_filterClass(inputDb, listFields, tokens, opt)
    %(
    if isempty(listFields) || isequal(opt.Class, @all) || all(strcmpi(opt.Class, '--all'))
        return
    end
    numFields = numel(listFields);
    opt.Class = reshape(string(opt.Class), 1, [ ]);
    inxClass = false(1, numFields);
    if isa(inputDb, 'Dictionary')
        for i = 1 : numFields
            class__ = string(class(retrieve(inputDb, listFields{i})));
            inxClass(i) = any(class__==opt.Class);
        end
    else
        for i = 1 : numFields
            class__ = string(class(inputDb.(listFields{i})));
            inxClass(i) = any(class__==opt.Class);
        end
    end
    listFields = listFields(inxClass);
    tokens = tokens(inxClass);
    %)
end%


function [listFields, tokens] = local_runUserFilter(inputDb, listFields, tokens, opt)
    %(
    if isempty(listFields) || isempty(opt.Filter)
        return
    end
    numFields = numel(listFields);
    inxFilter = false(1, numFields);
    if isa(inputDb, 'Dictionary')
        for i = 1 : numFields
            inxFilter(i) = logical(opt.Filter(retrieve(inputDb, listFields{i})));
        end
    else
        for i = 1 : numFields
            inxFilter(i) = logical(opt.Filter(inputDb.(listFields{i})));
        end
    end
    listFields = listFields(inxFilter);
    tokens = tokens(inxFilter);
    %)
end%

%
% Local validators
%

function local_validateName(x)
    %(
    if isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x) || isa(x, 'Rxp') 
        return
    end
    error("Input value must be @all, an array of strings, or a Rxp object.");
    %)
end%

function local_validateClass(x)
    %(
    if isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x)
        return
    end
    error("Input value must be @all, or an array of strings.");
    %)
end%

function local_validateFilter(x)
    %(
    if isempty(x) || isa(x, 'function_handle')
        return
    end
    error("Input value must be empty or a function.");
    %)
end%




% 
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/filterUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);
    s = struct( );
    s.a = Series( );
    s.b = Series( );
    s.c = 1;
    s.a_b = Series( );
    d = Dictionary( );
    store(d, "a", Series( ));
    store(d, "b", Series( ));
    store(d, "c", 1);
    store(d, "a.b", Series( ));


%% Test with Name Filter As List
    assertEqual(testCase, databank.filter(s, 'NameFilter', {'b', 'a_b', 'z'}), ["b", "a_b"]);
    assertEqual(testCase, databank.filter(s, 'NameFilter', ["b", "a_b", "z"]), ["b", "a_b"]);
    assertEqual(testCase, databank.filter(d, 'NameFilter', {'b', 'a.b', 'z'}), ["b", "a.b"]);
    assertEqual(testCase, databank.filter(d, 'NameFilter', ["b", "a.b", "z"]), ["b", "a.b"]);


%% Test Name List and User Filter
    [list, tokens] = databank.filter(s, 'NameFilter', {'a', 'c', 'a_b'}, 'Filter', @(x) isa(x, 'Series'));
    assertEqual(testCase, list, ["a", "a_b"]);
    [list, tokens] = databank.filter(d, 'NameFilter', {'a', 'c', 'a.b'}, 'Filter', @(x) isa(x, 'Series'));
    assertEqual(testCase, list, ["a", "a.b"]);

##### SOURCE END #####
%}

