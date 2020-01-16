function [overrideReal, overrideImag, multiply] = varyStdCorr(this, range, opt, varargin)
% varyStdCorr  Convert time-varying std and corr to stdcorr vector
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

clipTrailing = any(strcmpi(varargin, '--clip')); % Clip trailing NaNs
addPresample = any(strcmpi(varargin, '--presample')); % Include one presample period
includeOverrideImag = nargout>1;
includeMultiply = nargout>2;

%--------------------------------------------------------------------------

ixe = getIndexByType(this.Quantity, TYPE(31), TYPE(32));
ne = nnz(ixe);
nsx = ne + ne*(ne-1)/2;

if isempty(range)
    overrideReal = double.empty(nsx, 0);
    overrideImag = double.empty(nsx, 0);
    multiply = double.empty(ne, 0);
    return
end

range = reshape(double(range), 1, [ ]);
if addPresample 
    % Add one presample period if requested
    startDate = range(1);
    range = [DateWrapper.roundPlus(startDate, -1), range];
end
numPeriods = numel(range);

d = hereProcessOverrideOption(opt);

overrideReal = nan(numPeriods, nsx);
if includeOverrideImag
    overrideImag = nan(numPeriods, nsx);
end
if ~isempty(d) && validate.databank(d)
    names = fieldnames(d);
    ell = lookup(this.Quantity, names);
    pos = ell.PosStdCorr;
    inxValid = ~isnan(pos);
    names = names(inxValid);
    pos = pos(inxValid);
    overrideReal(:, pos) = databank.backend.toDoubleArrayNoFrills(d, names, range, 1, @real);
    if includeOverrideImag
        overrideImag(:, pos) = databank.backend.toDoubleArrayNoFrills(d, names, range, 1, @imag);
    end
end
overrideReal = transpose(overrideReal);
if includeOverrideImag
    overrideImag = transpose(overrideImag);
end

if includeMultiply
    if isfield(opt, 'Multiply') && validate.databank(opt.Multiply)
        names = getStdNames(this.Quantity);
        multiply = databank.backend.toDoubleArrayNoFrills(opt.Multiply, names, range, 1, @real);
    else
        multiply = nan(numPeriods, ne);
    end
    multiply = transpose(multiply);
end

%{
    for i = 1 : ne
        name = stdNames{i};
        if ~isfield(opt.Multiply, name)
            continue
        end
        x = opt.Multiply.(name);
        if isa(x, 'TimeSubscriptable')
            x = getDataFromTo(opt.Multiply.(name), startRange, endRange, @real);
            x = transpose(x(:, 1));
        end
        multiply(i, :) = real(x);
    end
end
%}

% Remove trailing NaNs if requested
if clipTrailing 
    overrideReal = hereClip(overrideReal);
    if includeOverrideImag
        overrideImag = hereClip(overrideImag);
    end
    if includeMultiply
        multiply = hereClip(multiply);
    end
end

end%


%
% Local Functions
%


function d = hereProcessOverrideOption(opt)
    d = [ ];
    if isfield(opt, 'Override') && ~isempty(opt.Override)
        d = opt.Override;
    end
end%


function x = hereClip(x)
    inxNaN = isnan(x);
    if all(inxNaN(:))
        x = double.empty(size(x, 1), 0);
        return
    end
    last = find(any(~inxNaN, 1), 1, 'last');
    x = x(:, 1:last);
end%

