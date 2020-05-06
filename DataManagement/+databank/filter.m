function [select, tokens, outputDb] = filter(inputDb, varargin)
% filter  Filter databank fields by their names, classes or user filter
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.filter');
    addRequired(pp, 'Database', @validate.databank);
    addParameter(pp, {'Name', 'NameFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x) || isa(x, 'Rxp'));
    addParameter(pp, {'Class', 'ClassFilter'}, @all, @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isstring(x));
    addParameter(pp, 'Filter', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
end
parse(pp, inputDb, varargin{:});
opt = pp.Options;

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
inxName = locallyFilterNames( );


%
% Filter field classes
%
inxClass = locallyFilterClass( );


%
% Run user filter
%
inxUserFilter = locallyRunUserFilter( );


%
% Combine all filters
%
inxSelect = inxName & inxClass & inxUserFilter;

select = string(listFields(inxSelect));
tokens = tokens(inxSelect);

if nargout>=3
    outputDb = databank.copy(inputDb, 'SourceNames=', select);
end

return

    function inxName = locallyFilterNames( )
        %(
        tokens = repmat({[]}, size(listFields));
        if isequal(opt.Name, @all) || isequal(opt.Name, "--all")
            inxName = true(size(listFields));
        else
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
        end
        inxName = reshape(inxName, 1, [ ]);
        %)
    end%


    function inxClass = locallyFilterClass( )
        %(
        if isequal(opt.Class, @all) || isequal(opt.Class, "--all")
            inxClass = true(size(listFields));
        else
            if isa(inputDb, 'Dictionary')
                func = @(x) class(retrieve(inputDb, x));
            else
                func = @(x) class(inputDb.(x));
            end
            listClasses = cellfun(func, listFields, 'UniformOutput', false);
            listClasses = reshape(string(listClasses), [ ], 1);
            opt.Class = reshape(string(opt.Class), 1, [ ]);
            inxClass = any(opt.Class==listClasses, 2);
        end
        inxClass = reshape(inxClass, 1, [ ]);
        %)
    end%


    function inxUserFilter = locallyRunUserFilter( )
        %(
        if isempty(opt.Filter)
            inxUserFilter = true(size(listFields));
        else
            inxUserFilter = cellfun(@(name) feval(opt.Filter, inputDb.(name)), listFields);
        end
        inxUserFilter = reshape(inxUserFilter, 1, [ ]);
        %)
    end%
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

##### SOURCE END #####
%}

