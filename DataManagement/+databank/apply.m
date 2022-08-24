% >=R2019b
%{
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, opt)

arguments
    inputDb (1, 1) {locallyValidateInputDbOrFunc}
    func (1, 1) {locallyValidateInputDbOrFunc}

    opt.StartsWith (1, 1) string = ""
        opt.HasPrefix__StartsWith = []
    opt.EndsWith (1, 1) string = ""
        opt.HasSuffix__EndsWith = []
    opt.Prepend (1, 1) string = ""
        opt.AddToStart__Prepend = []
        opt.AddPrefix__Prepend = []
    opt.Append (1, 1) string = ""
        opt.AddToEnd__Append = []
        opt.AddSuffix__Append = []
    opt.RemoveStart (1, 1) logical = false
        opt.RemovePrefix__RemoveStart = []
    opt.RemoveEnd (1, 1) logical = false
        opt.RemoveSuffix__RemoveEnd = []
    opt.RemoveSource (1, 1) logical = false
    opt.SourceNames {locallyValidateNames} = @all
    opt.TargetNames {locallyValidateNames} = @auto
    opt.TargetDb {locallyValidateDb} = @auto
        opt.AddToDatabank__TargetDb = []
    opt.WhenError (1, 1) string {mustBeMember(opt.WhenError, ["keep", "remove", "error"])} = "keep"
end
%}
% >=R2019b


% <=R2019a
%(
function [outputDb, appliedToNames, newNames] = apply(inputDb, func, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "StartsWith", "");
        addParameter(ip, "HasPrefix__StartsWith", []);
    addParameter(ip, "EndsWith", "");
        addParameter(ip, "HasSuffix__EndsWith", []);
    addParameter(ip, "Prepend", "");
        addParameter(ip, "AddToStart__Prepend", []);
        addParameter(ip, "AddPrefix__Prepend", []);
    addParameter(ip, "Append", "");
        addParameter(ip, "AddToEnd__Append", []);
        addParameter(ip, "AddSuffix__Append", []);
    addParameter(ip, "RemoveStart", false);
        addParameter(ip, "RemovePrefix__RemoveStart", []);
    addParameter(ip, "RemoveEnd", false);
        addParameter(ip, "RemoveSuffix__RemoveEnd", []);
    addParameter(ip, "RemoveSource", false);
    addParameter(ip, "SourceNames", @all);
    addParameter(ip, "TargetNames", @auto);
    addParameter(ip, "TargetDb", @auto);
        addParameter(ip, "AddToDatabank__TargetDb", []);
    addParameter(ip, "WhenError", "keep");
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


opt = iris.utils.resolveOptionAliases(opt, [], true);


if validate.databank(func)
    [func, inputDb] = deal(inputDb, func);
end

if ~isa(opt.SourceNames, 'function_handle')
    if isa(opt.SourceNames, 'Rxp')
        opt.SourceNames = databank.filter(inputDb, 'name', opt.SourceNames);
    end
    opt.SourceNames = cellstr(opt.SourceNames);
end

opt.StartsWith = char(opt.StartsWith);
opt.EndsWith = char(opt.EndsWith);

opt.Prepend = char(opt.Prepend);
opt.Append = char(opt.Append);

hereCheckInputOutputNames( );

if isa(inputDb, 'Dictionary')
    namesFields = cellstr(keys(inputDb));
elseif isstruct(inputDb)
    namesFields = fieldnames(inputDb);
end

numFields = numel(namesFields);
newNames = repmat({''}, size(namesFields));


outputDb = opt.TargetDb;
if isequal(outputDb, @auto)
    outputDb = inputDb;
end

inxApplied = false(1, numFields);
inxToRemove = false(1, numFields);
for i = 1 : numFields
    name__ = namesFields{i};
    if ~isa(opt.SourceNames, 'function_handle') && ~any(strcmpi(name__, opt.SourceNames))
       continue
    end 
    if ~isempty(opt.StartsWith) && ~startsWith(name__, opt.StartsWith)
        continue
    end
    if ~isempty(opt.EndsWith) && ~endsWith(name__, opt.EndsWith)
        continue
    end

    inxApplied(i) = true;

    %
    % Create output field name
    %
    if iscellstr(opt.TargetNames)
        inxName = strcmp(opt.SourceNames, name__);
        newName__ = opt.TargetNames{inxName};
    elseif isa(opt.TargetNames, 'function_handle') && ~isequal(opt.TargetNames, @auto)
        newName__ = opt.TargetNames(name__);
    else
        newName__ = name__;
        if opt.RemoveStart
            newName__ = extractAfter(newName__, strlength(opt.StartsWith));
        end
        if opt.RemoveEnd
            newName__ = extractBefore(newName__, strlength(newName__)-strlength(opt.EndsWith)+1);
        end
        if ~isempty(opt.Prepend)
            newName__ = [opt.Prepend, newName__];
        end
        if ~isempty(opt.Append)
            newName__ = [newName__, opt.Append];
        end
    end
    newNames{i} = newName__;

    field__ = inputDb.(name__);
    if ~isempty(func)
        success = true;
        try
            field__ = func(field__);
        catch exc
            success = false;
            if opt.WhenError=="error"
                exception.warning([
                    "Databank:ErrorEvaluatingFunction"
                    "The function failed with an error on this field: %s"
                ], name__);
                rethrow(exc);
            end
        end
    end
    if isa(outputDb, 'Dictionary')
        store(outputDb, newName__, field__);
    else
        outputDb.(newName__) = field__;
    end
    inxToRemove(i) = (opt.RemoveSource && ~strcmp(name__, newName__)) ...
        || (opt.WhenError=="remove" && ~success);
end

if any(inxToRemove)
    outputDb = rmfield(outputDb, namesFields(inxToRemove));
end

appliedToNames = namesFields(inxApplied);
newNames = newNames(inxApplied);

return


    function hereCheckInputOutputNames( )
        if isa(opt.TargetNames, 'function_handle')
            return
        end
        if validate.list(opt.SourceNames)
            opt.SourceNames = cellstr(opt.SourceNames);
        end
        if validate.list(opt.TargetNames)
            opt.TargetNames = cellstr(opt.TargetNames);
        end
        if iscellstr(opt.TargetNames) 
            if iscellstr(opt.TargetNames) && numel(opt.SourceNames)==numel(opt.TargetNames)
                return
            end
        end
        exception.error([
            "Databank:InconsistentInputOutputNames"
            "When used together in databank.apply(~), "
            "options SourceNames= and TargetNames= "
            "must be lists of the same size"
        ]);
    end%
end%


function locallyValidateInputDbOrFunc(input)
    if isempty(input) || validate.databank(input) || isa(input, 'function_handle')
        return
    end
    error("Validation:Failed", "Input value must empty, a databank or a function handle");
end%


function locallyValidateNames(input)
    if isa(input, 'function_handle') || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function locallyValidateDb(input)
    if isa(input, 'function_handle') || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####
% saveAs=databank/applyUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

d1 = struct();
d1.x = Series(1:10, 1);
d1.y = 1;
d1.z = "aaa";

%% Test plain vanilla 

func = @(x) x + 1;
d2 = databank.apply(d1, func);
d3 = databank.apply(func, d1);
%
for n = databank.fieldNames(d1)
    field1 = d1.(n);
    field2 = d2.(n);
    field3 = d3.(n);
    if isa(field1, 'Series')
        field1 = field1(:);
        field2 = field2(:);
        field3 = field3(:);
    end
    assertEqual(testCase, func(field1), field2);
    assertEqual(testCase, func(field1), field3);
end


%% Test SourceNames

sourceNames = ["x", "y"];
func = @(x) x + 1;
d2 = databank.apply(d1, func, "sourceNames", sourceNames, "addToDatabank", struct());
d3 = databank.apply(func, d1, "sourceNames", sourceNames, "addToDatabank", struct());
%
assertEqual(testCase, databank.fieldNames(d2), sourceNames);
assertEqual(testCase, databank.fieldNames(d3), sourceNames);


##### SOURCE END #####
%}
