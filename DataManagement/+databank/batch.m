function outputDb = batch(inputDb, newNameTemplate, generator, varargin)
% batch  Execute batch job within databank
%{
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank/batch');
    pp.KeepUnmatched = true;
    addRequired(pp, 'inputDb', @validate.databank);
    addRequired(pp, 'newNameTemplate', @(x) ischar(x) || (isa(x, 'string') && isscalar(x)));
    addRequired(pp, 'generator', @(x) isa(x, 'function_handle') || ischar(x) || (isstring(x) && isscalar(x)));

    addParameter(pp, 'Arguments', "$0", @locallyValidateArguments);
    addParameter(pp, 'AddToDatabank', @default, @(x) isequal(x, @default) || validate.databank(x));
    addParameter(pp, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
end
parse(pp, inputDb, newNameTemplate, generator, varargin{:});
opt = pp.Options;

%--------------------------------------------------------------------------

opt.Arguments = locallyPrepareArguments(opt.Arguments);
numArguments = numel(opt.Arguments);

if iscell(opt.Arguments)
%
% Names and function arguments given by lists in Arguments=
%
    selectNames = opt.Arguments{1};
    selectTokens = repmat("", 1, numel(selectNames));
else
%
% Filter databank names 
%
    if ~isempty(opt.Filter)
        filterOpt = opt.Filter;
    else
        filterOpt = pp.UnmatchedInCell;
    end
    [selectNames, selectTokens] = databank.filter(inputDb, filterOpt{:});
end


%
% Create output databank
%
if isequal(opt.AddToDatabank, @default)
    outputDb = inputDb;
else
    outputDb = opt.AddToDatabank;
end


%
% Create new names based on the template, old names and tokens from the old
% names
%
newNames = locallyMakeSubstitutions(newNameTemplate, selectNames, selectTokens);


%
% Generate new fields and intercept Matlab errors
%
errorReport = cell.empty(1, 0);
for i = 1 : numel(newNames)
    hereGenerateNewField(newNames(i), selectNames(i), selectTokens(i), i);
end


%
% Report the new field names during whose creation Matlab threw an error
%
if ~isempty(errorReport)
    hereThrowError();
end

return


    function hereGenerateNewField(newName, oldName, tokens, pos)
        %try
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
        %catch Err
        %    errorReport = [errorReport, {newName, Err.message}];
        %end
        return

            function newValue = hereFromFunction( )
                %(
                if isstring(opt.Arguments)
                    % Arguments=["$0", "$1", "$1_$2"] etc
                    namArguments = opt.Arguments;
                    inxZero = namArguments=="$0";
                    namArguments(inxZero) = oldName;
                    if any(~inxZero)
                        namArguments(~inxZero) = locallyMakeSubstitutions( ...
                            namArguments(~inxZero), oldName, tokens ...
                        );
                    end
                else
                    namArguments = cellfun(@(x) x(pos), opt.Arguments);
                end
                isDictionary = isa(inputDb, 'Dictionary');
                valArguments = cell(1, numArguments);
                for ii = 1 : numArguments
                    if isDictionary
                        valArguments{ii} = retrieve(inputDb, namArguments(ii));
                    else
                        valArguments{ii} = inputDb.(namArguments(ii));
                    end
                end
                newValue = feval(generator, valArguments{:});
                %)
            end%


            function newValue = hereFromExpression( )
                %(
                expression = locallyMakeSubstitutions(string(generator), oldName, tokens);
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
 

function newNames = locallyMakeSubstitutions(template, names, tokens)
    %(
    newNames = repmat(string(template), size(names));
    for i = 1 : numel(names)
        newNames(i) = replace(newNames(i), "$0", names(i));
        if ~isempty(tokens) && ~isempty(tokens{i})
            numTokens = numel(tokens{i});
            newNames(i) = replace(...
                newNames(i), compose("$%g", 1 : numTokens), string(tokens{i}) ...
            );
        end
    end
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

    x1 = databank.batch(d1, '$1_$2', '100+$0', 'Name=', Rxp('^(.)(.)$')); 
    x2 = databank.batch(d1, '$1_$2', '100+$0', 'Filter=', {'Name=', Rxp('^(.)(.)$')});
    x3 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', '100+$0', 'Name=', Rxp('^(.)(.)$')); 
    assertEqual(testCase, x1, x2);
    assertEqual(testCase, all(ismember(fieldnames(d1), fieldnames(x1))), true);
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, x1.a_1, d1.a1+100);
    assertEqual(testCase, x1.b_2, d1.b2+100);
    assertEqual(testCase, x1.c_3, d1.c3+100);
    assertEqual(testCase, x1.d_4, d1.d4+100);



%% Test Function Name Filter Tokens

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name=', Rxp('^(.)(.)$')); 
    x2 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Filter=', {'Name=', Rxp('^(.)(.)$')});
    assertEqual(testCase, x1, x2);
    assertEqual(testCase, all(ismember(fieldnames(d1), fieldnames(x1))), true);
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, ismember(["a1", "b2", "c3", "d4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, x1.a_1, d1.a1+100);
    assertEqual(testCase, x1.b_2, d1.b2+100);
    assertEqual(testCase, x1.c_3, d1.c3+100);
    assertEqual(testCase, x1.d_4, d1.d4+100);


%% Test Dictionary Against Struct

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name=', Rxp('^(.)(.)$')); 
    x2 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', @(x) 100+x, 'Name=', Rxp('^(.)(.)$')); 
    assertEqual(testCase, class(x2), 'Dictionary');
    for name = ["a_1", "b_2", "c_3", "d_4"]
        assertEqual(testCase, x1.(name), retrieve(x2, name));
    end


%% Test Option AddToDatabank Struct

    x1 = databank.batch(d1, '$1_$2', @(x) 100+x, 'Name=', Rxp('^(.)(.)$'), 'AddToDatabank=', struct( ));
    assertEqual(testCase, class(x1), 'struct');
    assertEqual(testCase, ismember(["a_1", "b_2", "c_3", "d_4"], fieldnames(x1)), true(1, 4));
    assertEqual(testCase, ismember(["a1", "b2", "c3", "d4"], fieldnames(x1)), false(1, 4));


%% Test Option AddToDatabank Dictionary

    x1 = databank.batch(Dictionary.fromStruct(d1), '$1_$2', @(x) 100+x, 'Name=', Rxp('^(.)(.)$'), 'AddToDatabank=', Dictionary( ));
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
        , "Name=", list ... 
        , "Arguments=", ["$0", "diff_$0"] ...
    );
    assertEqual(testCase, all(ismember("diff_"+list, fieldnames(d3))), true);
    for name = list
        expd = grow(d2.(name), "+", d2.("diff_"+name), range);
        assertEqual(testCase, expd, d3.(name+"_extend"));
    end


##### SOURCE END #####
%}
