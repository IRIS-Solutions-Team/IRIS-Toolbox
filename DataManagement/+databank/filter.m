% filter  Filter databank fields by their names, classes or user filter
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [listFields, tokens, outputDb] = filter(inputDb, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser("~databank/filter");
    pp.KeepDefaultOptions = true;
    addRequired(pp, 'Database', @validate.databank);
    addParameter(pp, {'Name', 'NameFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x) || isa(x, 'Rxp'));
    addParameter(pp, {'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x));
    addParameter(pp, 'Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
%)
[skip, opt] = maybeSkip(pp, varargin{:});
if ~skip
    opt = parse(pp, inputDb, varargin{:});
end

%--------------------------------------------------------------------------

if isa(inputDb, 'Dictionary')
    listFields = keys(inputDb);
else
    listFields = fieldnames(inputDb);
end
listFields = reshape(cellstr(listFields), 1, [ ]);

%
% Filter field names
%
[listFields, tokens] = locallyFilterNames(listFields, opt);


%
% Filter field classes
%
[listFields, tokens] = locallyFilterClass(inputDb, listFields, tokens, opt);

%
% Run user filter
%
[listFields, tokens] = locallyRunUserFilter(inputDb, listFields, tokens, opt);

listFields = string(listFields);
if nargout>=3
    outputDb = databank.copy(inputDb, 'SourceNames=', listFields);
end

end%


%
% Local Functions
%


function [listFields, tokens] = locallyFilterNames(listFields, opt)
    %(
    tokens = repmat({string.empty(1, 0)}, size(listFields));
    if isequal(opt.Name, @all) || isequal(opt.Name, "--all")
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


function [listFields, tokens] = locallyFilterClass(inputDb, listFields, tokens, opt)
    %(
    if isempty(listFields) || isequal(opt.Class, @all) || isequal(opt.Class, "--all")
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


function [listFields, tokens] = locallyRunUserFilter(inputDb, listFields, tokens, opt)
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
    assertEqual(testCase, databank.filter(s, 'NameFilter=', {'b', 'a_b', 'z'}), ["b", "a_b"]);
    assertEqual(testCase, databank.filter(s, 'NameFilter=', ["b", "a_b", "z"]), ["b", "a_b"]);
    assertEqual(testCase, databank.filter(d, 'NameFilter=', {'b', 'a.b', 'z'}), ["b", "a.b"]);
    assertEqual(testCase, databank.filter(d, 'NameFilter=', ["b", "a.b", "z"]), ["b", "a.b"]);


%% Test Name List and User Filter
    [list, tokens] = databank.filter(s, 'NameFilter=', {'a', 'c', 'a_b'}, 'Filter=', @(x) isa(x, 'Series'));
    assertEqual(testCase, list, ["a", "a_b"]);
    [list, tokens] = databank.filter(d, 'NameFilter=', {'a', 'c', 'a.b'}, 'Filter=', @(x) isa(x, 'Series'));
    assertEqual(testCase, list, ["a", "a.b"]);

##### SOURCE END #####
%}

