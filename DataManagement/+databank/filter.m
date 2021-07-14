% filter  Filter databank fields by their names, classes or user filter
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [listFields, tokens, outputDb] = filter(inputDb, options)

arguments
    inputDb {validate.mustBeDatabank}

    options.Name {locallyValidateName} = @all
    options.NameFilter {locallyValidateName} = @all
    options.Class {locallyValidateClass} = @all
    options.ClassFilter {locallyValidateClass} = @all
    options.Filter {locallyValidateFilter} = []
end

if ~isequal(options.NameFilter, @all)
    options.Name = options.NameFilter;
end

if ~isequal(options.ClassFilter, @all)
    options.Class = options.ClassFilter;
end
%}
% >=R2019b


% <=R2019a
%(
function [listFields, tokens, outputDb] = filter(inputDb, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser("~databank/filter");
    pp.KeepDefaultOptions = true;
    addRequired(pp, 'Database', @validate.databank);
    addParameter(pp, {'Name', 'NameFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x) || isa(x, 'Rxp'));
    addParameter(pp, {'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x));
    addParameter(pp, 'Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end

[skip, options] = maybeSkip(pp, varargin{:});
if ~skip
    options = parse(pp, inputDb, varargin{:});
end
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
[listFields, tokens] = locallyFilterNames(listFields, options);


%
% Filter field classes
%
[listFields, tokens] = locallyFilterClass(inputDb, listFields, tokens, options);

%
% Run user filter
%
[listFields, tokens] = locallyRunUserFilter(inputDb, listFields, tokens, options);

listFields = string(listFields);
if nargout>=3
    outputDb = databank.copy(inputDb, 'SourceNames', listFields);
end

end%


%
% Local Functions
%


function [listFields, tokens] = locallyFilterNames(listFields, options)
    %(
    tokens = repmat({string.empty(1, 0)}, size(listFields));
    if isequal(options.Name, @all) || isequal(options.Name, "--all")
        return
    end
    isRegular = false;
    if isa(options.Name, 'Rxp')
        isRegular = true;
        options.Name = options.Name.String;
    else
        if ~isa(options.Name, 'string')
            options.Name = string(options.Name);
        end
        if isscalar(options.Name) 
            if startsWith(options.Name, "--rexp:")
                isRegular = true;
                options.Name = erase(options.Name, "--rexp:");
            end
        end
    end
    if isRegular
        [start, tokens] = regexp(listFields, options.Name, 'start', 'tokens', 'once');
        inxName = ~cellfun('isempty', start);
    else
        options.Name = reshape(options.Name, 1, [ ]);
        inxName = ismember(listFields, options.Name);
    end
    inxName = reshape(inxName, 1, [ ]);
    listFields = listFields(inxName);
    tokens = tokens(inxName);
    %)
end%


function [listFields, tokens] = locallyFilterClass(inputDb, listFields, tokens, options)
    %(
    if isempty(listFields) || isequal(options.Class, @all) || isequal(options.Class, "--all")
        return
    end
    numFields = numel(listFields);
    options.Class = reshape(string(options.Class), 1, [ ]);
    inxClass = false(1, numFields);
    if isa(inputDb, 'Dictionary')
        for i = 1 : numFields
            class__ = string(class(retrieve(inputDb, listFields{i})));
            inxClass(i) = any(class__==options.Class);
        end
    else
        for i = 1 : numFields
            class__ = string(class(inputDb.(listFields{i})));
            inxClass(i) = any(class__==options.Class);
        end
    end
    listFields = listFields(inxClass);
    tokens = tokens(inxClass);
    %)
end%


function [listFields, tokens] = locallyRunUserFilter(inputDb, listFields, tokens, options)
    %(
    if isempty(listFields) || isempty(options.Filter)
        return
    end
    numFields = numel(listFields);
    inxFilter = false(1, numFields);
    if isa(inputDb, 'Dictionary')
        for i = 1 : numFields
            inxFilter(i) = logical(options.Filter(retrieve(inputDb, listFields{i})));
        end
    else
        for i = 1 : numFields
            inxFilter(i) = logical(options.Filter(inputDb.(listFields{i})));
        end
    end
    listFields = listFields(inxFilter);
    tokens = tokens(inxFilter);
    %)
end%

%
% Local validators
%

function locallyValidateName(x)
    %(
    if isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x) || isa(x, 'Rxp') 
        return
    end
    error("Input value must be @all, an array of strings, or a Rxp object.");
    %)
end%

function locallyValidateClass(x)
    %(
    if isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x)
        return
    end
    error("Input value must be @all, or an array of strings.");
    %)
end%

function locallyValidateFilter(x)
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

