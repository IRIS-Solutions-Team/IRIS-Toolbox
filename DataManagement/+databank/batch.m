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

    addParameter(pp, 'Arguments', ["$0"], @(x) isstring(x) || ischar(x) || iscellstr(x));
    addParameter(pp, 'AddToDatabank', @default, @(x) isequal(x, @default) || validate.databank(x));
    addParameter(pp, 'Filter', cell.empty(1, 0), @validate.nestedOptions);
end
parse(pp, inputDb, newNameTemplate, generator, varargin{:});
opt = pp.Options;
opt.Arguments = string(opt.Arguments);

%--------------------------------------------------------------------------

%
% Filter databank names 
%
if ~isempty(opt.Filter)
    filterOpt = opt.Filter;
else
    filterOpt = pp.UnmatchedInCell;
end
[selectNames, selectTokens] = databank.filter(inputDb, filterOpt{:});


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
    hereGenerateNewField(newNames(i), selectNames(i), selectTokens(i));
end


%
% Report the new field names during whose creation Matlab threw an error
%
if ~isempty(errorReport)
    hereThrowError();
end

return

    function hereGenerateNewField(newName, oldName, tokens)
        try
            if isa(generator, 'function_handle')
                isDictionary = isa(inputDb, 'Dictionary');
                namArguments = opt.Arguments;
                inxZero = namArguments=="$0";
                namArguments(inxZero) = oldName;
                if any(~inxZero)
                    namArguments(~inxZero) = locallyMakeSubstitutions( ...
                        namArguments(~inxZero), oldName, tokens ...
                    );
                end
                numArguments = numel(opt.Arguments);
                valArguments = cell(1, numArguments);
                for i = 1 : numArguments
                    if isDictionary
                        valArguments{i} = retrieve(inputDb, namArguments(i));
                    else
                        valArguments{i} = inputDb.(namArguments(i));
                    end
                end
                newValue = feval(generator, valArguments{:});
            else
                expression = locallyMakeSubstitutions(string(generator), oldName, tokens);
                newValue = databank.eval(inputDb, expression);
            end
            if isa(outputDb, 'Dictionary')
                store(outputDb, newName, newValue);
            else
                outputDb.(newName) = newValue;
            end
        catch Err
            errorReport = [errorReport, {newName, Err.message}];
        end
    end%


    function hereThrowError()
        thisError= [
            "Databank:ErrorGeneratingField"
            "Error generating this new databank field: %s "
            "Matlab says %s "
        ];
        throw(exception.Base(thisError, 'error'), errorReport{:});
    end%
end%


%
% Local Functions
%
 

function newNames = locallyMakeSubstitutions(template, names, tokens)
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

##### SOURCE END #####
%}
