% varyStdCorr  Convert time-varying std and corr to stdcorr vector
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function ...
    [overrideReal, overrideImag, multiply] = ...
    varyStdCorr(this, range, userOverride, userMultiply, options)

% options.Clip=true  Clip trailing NaNs
% options.Presample=true  Add one presample period

includeOverrideImag = nargout>1;
includeMultiply = nargout>2;

inxE = getIndexByType(this.Quantity, 31, 32);
numE = nnz(inxE);
numSX = numE + numE*(numE-1)/2;

if isempty(range)
    overrideReal = double.empty(numSX, 0);
    overrideImag = double.empty(numSX, 0);
    multiply = double.empty(numE, 0);
    return
end

hereResolveRange( );
numPeriods = numel(range);

overrideReal = nan(numPeriods, numSX);
if includeOverrideImag
    overrideImag = nan(numPeriods, numSX);
end
if ~isempty(userOverride) && validate.databank(userOverride)
    names = fieldnames(userOverride);
    ell = lookup(this.Quantity, names);
    pos = ell.PosStdCorr;
    inxValid = ~isnan(pos);
    names = names(inxValid);
    pos = pos(inxValid);
    overrideReal(:, pos) = databank.backend.toDoubleArrayNoFrills(userOverride, names, range, 1, @real);
    if includeOverrideImag
        overrideImag(:, pos) = databank.backend.toDoubleArrayNoFrills(userOverride, names, range, 1, @imag);
    end
end
overrideReal = transpose(overrideReal);
if includeOverrideImag
    overrideImag = transpose(overrideImag);
end

if includeMultiply
    if ~isempty(userMultiply) && validate.databank(userMultiply)
        names = getStdNames(this.Quantity);
        multiply = databank.backend.toDoubleArrayNoFrills(userMultiply, names, range, 1, @real);
    else
        multiply = nan(numPeriods, numE);
    end
    multiply = transpose(multiply);
end

% Remove trailing NaNs if requested
if options.Clip 
    overrideReal = hereClip(overrideReal);
    if includeOverrideImag
        overrideImag = hereClip(overrideImag);
    end
    if includeMultiply
        multiply = hereClip(multiply);
    end
end

return

    function hereResolveRange( )
        range = reshape(double(range), 1, [ ]);
        startDate = range(1);
        endDate = range(end);
        if options.Presample 
            % Add one presample period if requested
            startDate = dater.plus(startDate, -1);
        end
        range = dater.colon(startDate, endDate);
    end%
end%


%
% Local Functions
%


function x = hereClip(x)
    last = find(any(~isnan(x), 1), 1, 'last');
    if isempty(last)
        last = 0;
    end
    x = x(:, 1:last);
end%

