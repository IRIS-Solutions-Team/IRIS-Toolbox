function outputDb = batch(inputDb, newNameTemplate, generator, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('+databank/batch');
    pp.KeepUnmatched = true;
    addRequired(pp, 'inputDb', @validate.databank);
    addRequired(pp, 'newNameTemplate', @(x) ischar(x) || isstring(x) || iscellstr(x));
    addRequired(pp, 'generator', @(x) isa(x, 'function_handle') || ischar(x) || (isstring(x) && isscalar(x)));

    addParameter(pp, 'Arguments', "$0", @locallyValidateArguments);
    addParameter(pp, 'AddToDatabank', @auto, @(x) isequal(x, @auto) || validate.databank(x));
    addParameter(pp, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
end
parse(pp, inputDb, newNameTemplate, generator, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

%
% opt.Arguments is either of the following two:
% 
% * a string array with templates that will be resolved for each name and
% each set of tokens, 
%
% * a cell array of strings with a list of arguments, and the size of this
% list corresponds to the size of the list of names entered in
% Filter={Name=...}
%
opt.Arguments = locallyPrepareArguments(opt.Arguments);
numArguments = numel(opt.Arguments);

if iscell(opt.Arguments)
%
% Names and function arguments given by lists in Arguments=;
% make sure tokenSets is a 1-by-N cell array where N is the number of
% selectNames
%
    selectNames = opt.Arguments{1};
    tokenSets = cell(1, numel(selectNames));
else
%
% Filter databank names 
%
    if ~isempty(opt.Filter)
        filterOpt = opt.Filter;
    else
        filterOpt = pp.UnmatchedInCell;
    end
    [selectNames, tokenSets] = databank.filter(inputDb, filterOpt{:});
end


%
% Create output databank
%
if isequal(opt.AddToDatabank, @auto)
    outputDb = inputDb;
else
    outputDb = opt.AddToDatabank;
end


%
% Create new names based on the template, old names and tokens from the old
% names
%
newNameTemplate = string(newNameTemplate);
if isscalar(newNameTemplate)
    numNames = numel(selectNames);
    newNames = repmat("", 1, numNames);
    for i = 1 : numNames
        newNames(i) = locallyMakeSubstitutions(newNameTemplate, selectNames(i), tokenSets(i));
    end
else
    newNames = newNameTemplate;
end


%
% Generate new fields and intercept Matlab errors
%
errorReport = cell.empty(1, 0);
for i = 1 : numel(newNames)
    hereGenerateNewField(newNames(i), selectNames(i), tokenSets(i), i);
end


%
% Report the new field names during whose creation Matlab threw an error
%
if ~isempty(errorReport)
    hereThrowError();
end

return


    function hereGenerateNewField(newName, oldName, tokenSet, pos)
        try
            if isa(generator, 'function_handle')
                newValue = hereFromFunction( );
            else
                newValue = hereFromExpression( );
            end
            if isa(outputDb, 'Dictionary')
                store(outputDb, newName, newValue);
            else
                outputDb.(newName) = newValue;
            end
        catch Err
            errorReport = [errorReport, {newName, Err.message}];
        end
        return

            function newValue = hereFromFunction( )
                %(
                isDictionary = isa(inputDb, 'Dictionary');
                numArguments = numel(opt.Arguments);
                valArguments = cell(1, numArguments);
                needsSubstitute = isstring(opt.Arguments);
                for ii = 1 : numArguments
                    if needsSubstitute
                        %
                        % Arguments=["$0", "$1", "$1_$2", ... ]
                        % to evalute func(d.("$0"), d.("$1"), d.("$1_$2"))
                        %
                        name__ = locallyMakeSubstitutions( ...
                            opt.Arguments(ii), oldName, tokenSet ...
                        );
                    else
                        %
                        % Arguments={ ["x", "xa", "xb"], ["y", "ya", "yb"], ...}
                        % to evaluate func(d.x, d.xa, d.xb), etc
                        %
                        name__ = opt.Arguments{ii}(pos);
                    end
                    if isDictionary
                        valArguments{ii} = retrieve(inputDb, name__);
                    else
                        valArguments{ii} = inputDb.(name__);
                    end
                end
                newValue = feval(generator, valArguments{:});
                %)
            end%


            function newValue = hereFromExpression( )
                %(
                expression = locallyMakeSubstitutions(string(generator), oldName, tokenSet);
                newValue = databank.eval(inputDb, expression);
                %)
            end%
    end%




    function hereThrowError()
        %(
        thisError= [
            "Databank:ErrorGeneratingField"
            "Error generating this new databank field: %s "
            "Matlab says %s "
        ];
        throw(exception.Base(thisError, 'error'), errorReport{:});
        %)
    end%
end%


%
% Local Functions
%
 

function newName = locallyMakeSubstitutions(template, name, tokenSet)
    %(
    newName = replace(template, "$0", name);
    % tokenSet is 1-by-1 cell array here, we need to write tokenSet{1}
    if isempty(tokenSet) || isempty(tokenSet{1})
        return
    end
    newName = replace( ...
        newName, compose("$%g", 1 : numel(tokenSet{1})), string(tokenSet{1}) ...
    );
    %)
end%




function arguments = locallyPrepareArguments(arguments)
    %(
    if isstring(arguments) || ischar(arguments) || iscellstr(arguments)
        arguments = reshape(string(arguments), 1, [ ]);
        return
    else
        arguments = reshape(cellfun(@string, arguments, 'UniformOutput', false), 1, [ ]);
        return
    end
    %)
end%




function flag = locallyValidateArguments(input)
    %(
    if isstring(input) || ischar(input) || iscellstr(input)
        flag = true;
        return
    end
    if iscell(input) && ~isempty(input) && all(cellfun(@(x) isstring(x) || iscellstr(x), input))
        flag = true;
        return
    end
    flag = false;
    %)
end%




%
% Unit Tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/batchUnitTest.m

    testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);
    d1 = struct();
    d1.a1 = 1;
    d1.b2 = 2;
    d1.c3 = round(100*Series(1:10, @rand));
    d1.d4 = round(100*Series(1:10, @rand));


%% Test Expression Name Filter Tokens

    x1 = databank.batch(d1, '$1_$2', '100+$0', 'Name', Rxp('^(.)(.)$')); 
    x2 = databank.batch(d1, '$1_$2', '100+$0', 'Filter', {'Name', Rxp('^(.)(.)$')});
    x3 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', '100+$0', 'Name', Rxp('^(.)(.)$')); 
    assertEqual(testCase, x1, x2);
    assertEqual(testCase, all(ismember(fieldnames(d1), fieldnames(x1))), true);
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, x1.a_1, d1.a1+100);
    assertEqual(testCase, x1.b_2, d1.b2+100);
    assertEqual(testCase, x1.c_3, d1.c3+100);
    assertEqual(testCase, x1.d_4, d1.d4+100);



%% Test Function Name Filter Tokens

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name', Rxp('^(.)(.)$')); 
    x2 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Filter', {'Name', Rxp('^(.)(.)$')});
    assertEqual(testCase, x1, x2);
    assertEqual(testCase, all(ismember(fieldnames(d1), fieldnames(x1))), true);
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, ismember(["a1", "b2", "c3", "d4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, x1.a_1, d1.a1+100);
    assertEqual(testCase, x1.b_2, d1.b2+100);
    assertEqual(testCase, x1.c_3, d1.c3+100);
    assertEqual(testCase, x1.d_4, d1.d4+100);


%% Test Dictionary Against Struct

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name', Rxp('^(.)(.)$')); 
    x2 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', @(x) 100+x, 'Name', Rxp('^(.)(.)$')); 
    assertEqual(testCase, class(x2), 'Dictionary');
    for name = ["a_1", "b_2", "c_3", "d_4"]
        assertEqual(testCase, x1.(name), retrieve(x2, name));
    end


%% Test Option AddToDatabank Struct

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name', Rxp('^(.)(.)$'), 'AddToDatabank', struct( ));
    assertEqual(testCase, class(x1), 'struct');
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, ismember(["a1", "b2", "c3", "d4"], fieldnames(x1)), false(1, 4));


%% Test Option AddToDatabank Dictionary

    x1 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', @(x) 100+x, 'Name', Rxp('^(.)(.)$'), 'AddToDatabank', Dictionary( ));
    assertEqual(testCase, class(x1), 'Dictionary');
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], keys(x1)), true(1, 4));
    assertEqual(testCase, ismember(["a1", "b2", "c3", "d4"], keys(x1)), false(1, 4));


%% Test Function Arguments

    d2 = struct( );
    list = ["X", "AB", "XYZ"];
    for name = list
        d2.(name) = Series(1:10, @rand);
        d2.("diff_"+name) = Series(1:20, @rand);
    end
    range = 11:20;
    d3 = databank.batch( ...
        d2, "$0_extend", @(x,y) grow(x, "+", y, range) ...
        , "Name", list ... 
        , "Arguments", ["$0", "diff_$0"] ...
    );
    assertEqual(testCase, all(ismember("diff_"+list, fieldnames(d3))), true);
    for name = list
        expd = grow(d2.(name), "+", d2.("diff_"+name), range);
        assertEqual(testCase, expd, d3.(name+"_extend"));
    end


%% Test Csaba 2020-05-20 Issue

    d0 = struct( );
    list = ["A", "B", "C"];
    for n = list
        d0.(n) = Series(1, rand(20, 1));
        d0.(n+"_U2W") = Series(1, rand(20, 1));
        d0.(n+"_U2") = Series(1, rand(20, 1));
    end

    args = {'$0', '$0_U2W', '$0_U2'};
    d = databank.batch(d0, '$0', @(x, y, z) x*y/z, 'Name', list, 'Arguments', args);
    for n = list
        assertEqual(testCase, d.(n), d0.(n)*d0.(n+"_U2W")/d0.(n+"_U2"));
    end

    args = {list, list+"_U2W", list+"_U2"};
    d = databank.batch(d0, list, @(x, y, z) x*y/z, 'Arguments', args); 
    for n = list
        assertEqual(testCase, d.(n), d0.(n)*d0.(n+"_U2W")/d0.(n+"_U2"));
    end

##### SOURCE END #####
%}
