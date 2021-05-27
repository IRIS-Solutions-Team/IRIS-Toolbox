% Type `web +databank/minusControl.md` for help on this function
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

%#ok<*VUNUS>
%#ok<*CTCH>

% >=R2019b
%(
function outputDb = minusControl(model, inputDb, controlDb, opt)

arguments
    model Model
    inputDb {validate.mustBeDatabank}
    controlDb {validate.mustBeDatabank} = struct([])

    opt.Range {validate.mustBeRange} = Inf
    opt.AddToDatabank (1, 1) {locallyValidateDatabank} = @auto
end
%)
% >=R2019b


% <=R2019a
%{
function outputDb = minusControl(model, inputDb, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser();
    addOptional(pp, 'controlDb', struct([]), @validate.databank);
    addParameter(pp, 'Range', Inf);
    addParameter(pp, 'AddToDatabank', @auto);
end
parse(pp, varargin{:});
opt = pp.Results;
opt = rmfield(opt, 'controlDb');
controlDb = pp.Results.controlDb;
%}
% <=R2019a


opt.Range = double(opt.Range);

if isempty(controlDb) || isempty(fieldnames(controlDb))
    if any(isinf(opt.Range))
        dbRange = databank.range(inputDb, "sourceNames", string(fieldnames(inputDb)));
        if iscell(dbRange)
            exception.error([
                "Databank:MixedFrequency"
                "Input time series must be all of the same date frequency."
            ]);
        end
    else
        dbRange = opt.Range;
    end
    controlDb = steadydb(model, dbRange);
end

quantity = getp(model, "Quantity");
inx = getIndexByType(quantity, 1, 2, 31, 32);

if isequal(opt.AddToDatabank, @auto)
    outputDb = inputDb;
else
    outputDb = opt.AddToDatabank;
end

needsClip = isinf(opt.Range(1)) && isinf(opt.Range(end));

for pos = reshape(find(inx), 1, [])
    n = quantity.Name{pos};
    if isfield(inputDb, n) && isfield(controlDb, n)
        if quantity.InxLog(pos)
            func = @rdivide;
        else
            func = @minus;
        end
        try
            outputSeries = bsxfun( ...
                func, ...
                real(inputDb.(n)), ...
                real(controlDb.(n)) ...
            );
            outputSeries = comment(outputSeries, inputDb.(n));
            if needsClip
                outputSeries = clip(outputSeries, opt.Range);
            end
            if isstruct(outputDb)
                outputDb.(n) = outputSeries;
            else
                store(outputDb, n, outputSeries);
            end
        end
    end
end

end%

%
% Local validators
%

function locallyValidateDatabank(x)
    %(
    if validate.databank(x) || isequal(x, @auto)
        return
    end
    error("Input value must be a databank (struct or Dictionary) or @auto.");
    %)
end%




%
% Unit tests
%
%{
##### SOURCE BEGIN #####

% saveAs=databank/minusControlUnitTest.m

testCase = matlab.unittest.FunctionTestCase.fromFunction(@(x)x);

m = Model.fromSnippet("test", "linear", true);
m = solve(m);
m = steady(m);

% test>>>
% !variables x, y
% !log-variables y
% !equations x = 0; y = 1;
% <<<test

d.x = Series(1:10, @randn);
d.y = exp(Series(1:10, @randn));


%% Test control databank 

c = steadydb(m, 1:10);
smc1 = databank.minusControl(m, d, c);
smc2 = databank.minusControl(m, d);

for n = access(m, "transition-variables")
        assertEqual(testCase, smc1.(n).Data, smc2.(n).Data);
end


%% Test Range option

range = 3:8;
c = steadydb(m, range);
smc1 = databank.minusControl(m, d, c);
smc2 = databank.minusControl(m, d, "range", range);

for n = access(m, "transition-variables")
        assertEqual(testCase, smc1.(n).Data, smc2.(n).Data);
end


%% Test AddToDatabank option

outputDb = Dictionary();
smc1 = databank.minusControl(m, d);
smc2 = databank.minusControl(m, d, "addToDatabank", outputDb);

assertClass(testCase, smc2, "Dictionary");

for n = access(m, "transition-variables")
        assertEqual(testCase, smc1.(n).Data, smc2.(n).Data);
end

##### SOURCE END #####
%}

