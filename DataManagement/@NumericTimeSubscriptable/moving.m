% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

% >=R2019b
%(
function this = moving(this, range, opt)

arguments
    this NumericTimeSubscriptable
    range {validate.mustBeRange(range)} = Inf

    opt.Window {locallyValidateWindow(opt.Window)} = @auto
    opt.Function {validate.mustBeA(opt.Function, "function_handle")} = @mean
    opt.Period (1, 1) logical = false
    opt.Range (1, :) {validate.mustBeRange} = Inf
end
%)
% >=R2019b

% <=R2019a
%{
function this = moving(this, varargin)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@Series/moving');
    pp.addRequired('inputSeries', @(x) isa(x, 'NumericTimeSubscriptable'));
    pp.addOptional('range', Inf, @Dater.validateRangeInput);
    pp.addParameter('Function', @mean, @(x) isa(x, 'function_handle'));
    pp.addParameter('Window', @auto, @(x) isequal(x, @auto) || isnumeric(x));
    pp.addParameter('Period', false, @validate.logicalScalar);
    pp.addParameter('Range', Inf, @validate.range);
end
opt = pp.parse(this, varargin{:});
range = pp.Results.range;
%}
% <=R2019a

opt.Window = locallyResolveWindow(opt.Window, this);

% Legacy input argument
if ~isequal(range, Inf)
    opt.Range = range;
    exception.warning([
        "Legacy"
        "Date range as a second input argument is obsolete, and will be"
        "disabled in a future version. Use the option Range= instead."
    ]);
end

if ~isequal(opt.Range, @all) && ~isequal(opt.Range, Inf)
    this = clip(this, opt.Range);
end

if ~isempty(opt.Window)
    this.Data = locallyMoving(this.Data, opt.Window, opt.Function, this.MissingValue, this.MissingTest, opt.Period);
    this = trim(this);
else
    this = emptyData(this);
end

end%

%
% Local functions
%

function inputData = locallyMoving(inputData, window, func, missingValue, missingTest, period)
    %(
    sizeData = size(inputData);
    numRows = sizeData(1);
    numColumns = prod(sizeData(2:end));

    for column = 1 : numColumns
        if ~isreal(window)
            inxMissing = missingTest(inputData(:, column));
            windowLength = imag(window);
            windowOffset = real(window);
            if windowLength~=0 || ~all(inxMissing)
                outputData = inputData;
                for row = 1 : numRows
                    selectData = locallySelectNonmissingData(inputData(:, column), inxMissing, row, windowLength, windowOffset);
                    if ~isempty(selectData)
                        outputData(row, column) = feval(func, selectData);
                    else
                        outputData(row, column) = missingValue;
                    end
                end
            else
                outputData = repmat(missingValue, size(inputData));
            end
        else
            shiftedData = series.shift(inputData(:, column), window);
            if ~period
                outputData(:, column) = transpose(feval(func, transpose(shiftedData), 1));
            else
                % Use a for loop to make sure only the respective moving window of
                % observations shaped as a column vector enters the function
                for row = 1 : numRows
                    outputData(row, column) = feval(func, reshape(shiftedData(row, :), [], 1));
                end
            end
        end
    end
    inputData = outputData;
    %)
end%


function selectData = locallySelectNonmissingData(data, inxMissing, row, windowLength, windowOffset)
    %(
    direction = sign(windowLength);
    windowLength = abs(windowLength);
    if direction>0
        selectData = data(row+windowOffset:end);
        inxMissing = inxMissing(row+windowOffset:end);
    else
        selectData = data(1:row+windowOffset);
        inxMissing = inxMissing(1:row+windowOffset);
    end

    selectData(inxMissing) = [];
    if numel(selectData)<windowLength
        selectData = [];
        return
    end

    if direction>0
        selectData = selectData(1:windowLength);
    else
        selectData = selectData(end-windowLength+1:end);
    end
    %)
end%

%
% Local Validators
%

function window = locallyResolveWindow(window, inputSeries)
    %(
    AUTO_WINDOW_FREQUENCIES = Frequency([1, 2, 4, 12]);
    if isnumeric(window) 
        window = reshape(window, 1, []);
        return
    end
    freq = dater.getFrequency(inputSeries.Start);
    if ismember(freq, AUTO_WINDOW_FREQUENCIES)
        window = (-freq+1) : 0;
        return
    end
    exception.error([
        "Series:InvalidMovingWindow"
        "Option Window=@auto is not allowed for time series of %s frequency. "
    ], string(Frequency(freq)));
    %)
end%


function locallyValidateWindow(input)
    %(
    if isa(input, "function_handle")
        return
    end
    isInteger = isnumeric(input) && all(input==round(input));
    if isInteger && isreal(input)
        return
    end
    if isInteger && ~isreal(input) && isscalar(input)
        return
    end
    error("Validation:Failed", "Input value must be an array of integers or a complex integer scalar");
    %)
end%

