% clip  Clip all time series in databank to a new range
%{
% ## Syntax ##
%
%     outputDatabank = databank.clip(inputDatabank, newStart, newEnd)
%
%
% ## Input Arguments ##
%
% __`inputDatabank`__ [ struct | Dictionary ] - 
% Input databank whose time series (of the matching frequency) will be
% clipped to a new range defined by `newStart` and `newEnd`.
%
% __`newStart`__ [ DateWrapper | `-Inf` ] - 
% A new start date to which all time series of the matching frequency will
% be clipped; `-Inf` means the start date will not be altered.
%
% __`newEnd`__ [ DateWrapper | `-Inf` ] - 
% A new end date to which all time series of the matching frequency will be
% clipped; `Inf` means the end date will not be altered.
%
%
% ## Output Arguments ##
%
% __`outputDatabank`__ [ struct | Dictionary ] - 
% Output databank in which all time series (of the matching frequency) are
% clipped to the new range.
%
%
% ## Description ##
%
%
% ## Example ##
%
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

% >=R2019b
%(
function outputDb = clip(inputDb, newStart, newEnd, opt)

arguments
    inputDb (1, 1) {validate.databank(inputDb)}
    newStart {mustBeNonempty, validate.dateInput(newStart)}
    newEnd {validate.mustBeScalarOrEmpty, validate.dateInput(newEnd)} = []

    opt.SourceNames {locallyValidateNames(opt.SourceNames)} = @all
    opt.TargetDb {locallyValidateDb(opt.TargetDb)} = @auto
end
%)
% >=R2019b

% <=R2019a
%{
function outputDb = clip(inputDb, newStart, newEnd, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('databank.clip');
    addRequired(pp, 'InputDatabank', @validate.databank);
    addRequired(pp, 'NewStart', @(x) isequal(x, -Inf) || DateWrapper.validateDateInput(x));
    addRequired(pp, 'NewEnd', @(x) isequal(x, Inf) || DateWrapper.validateDateInput(x));
    addParameter(pp, "SourceNames", @all, @(x) isequal(x, @all) || isstring(x) || ischar(x) || iscellstr(x));
    addParameter(pp, "TargetDb", @auto, @(x) isequal(x, @auto) || validate.databank(x));
end
opt = parse(pp, inputDb, newStart, newEnd, varargin{:});
%}
% <=R2019a

newStart = double(newStart);
newEnd = double(newEnd);

%--------------------------------------------------------------------------

if isequal(opt.TargetDb, @auto)
    outputDb = inputDb;
end

isNewStartInf = isequal(newStart, -Inf);
isNewEndInf = isequal(newEnd, Inf);

if isNewStartInf && isNewEndInf
    return
end

if ~isNewStartInf
    freq = dater.getFrequency(newStart(1));
else
    freq = dater.getFrequency(newEnd);
end

if isequal(opt.SourceNames, @all)
    list = keys(inputDb);
else
    list = reshape(string(opt.SourceNames), 1, []);
end

for n = list
    if ~isfield(inputDb, n)
        continue
    end
    if isa(inputDb, "Dictionary")
        field__ = retrieve(inputDb, n);
    else
        field__ = inputDb.(n);
    end
    if isa(field__, "TimeSubscriptable")
        if isequaln(freq, NaN) || getFrequencyAsNumeric(field__)==freq
            field__ = clip(field__, newStart, newEnd);
        end
    elseif validate.databank(field__)
        field__ = databank.clip(field__, newStart, newEnd, opt);
    end
    if isa(outputDb, "Dictionary")
        store(outputDb, n, field__);
    else
        outputDb.(n) = field__;
    end
end

end%

%
% Local Functions
%

function locallyValidateNames(input)
    if isa(input, "function_handle") || validate.list(input)
        return
    end
    error("Validation:Failed", "Input value must be a string array");
end%


function locallyValidateDb(input)
    if isa(input, "function_handle") || validate.databank(input)
        return
    end
    error("Validation:Failed", "Input value must be a struct or a Dictionary");
end%

