function [stdCorrReal, stdCorrImag, stdMultipliers] = varyStdCorr(this, range, j, opt, varargin)
% varyStdCorr  Convert time-varying std and corr to stdcorr vector
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

TYPE = @int8;

isClip = any(strcmpi(varargin, '--clip')); % Clip trailing NaNs.
isPresample = any(strcmpi(varargin, '--presample')); % Include one presample period.
isImag = nargout>1;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
nsx = ne + ne*(ne-1)/2;

if isempty(range)
    stdCorrReal = double.empty(nsx, 0);
    stdCorrImag = double.empty(nsx, 0);
    stdMultipliers = double.empty(ne, 0);
    return
end
range = DateWrapper.getSerial(range);
startOfRange = range(1);
endOfRange = range(end);
if isPresample 
    % Add one presample period if requested
    startOfRange = startOfRange - 1;
end
numOfPeriods = round(endOfRange - startOfRange + 1);

d = processTimeVaryingOption(j, opt);

stdCorrReal = nan(nsx, numOfPeriods);
if isImag
    stdCorrImag = nan(nsx, numOfPeriods);
end
if ~isempty(d)
    c = fieldnames(d);
    ell = lookup(this.Quantity, c);
    pos = ell.PosStdCorr;
    for i = find(~isnan(pos))
        x = d.(c{i});
        if isa(x, 'TimeSubscriptable')
            x = getDataFromTo(x, startOfRange, endOfRange);
            x = transpose(x(:, 1));
        end
        stdCorrReal(pos(i), :) = real(x);
        if isImag
            stdCorrImag(pos(i), :) = imag(x);
        end
    end
end

stdMultipliers = nan(ne, numOfPeriods);
if isfield(opt, 'Multiply') && isstruct(opt.Multiply)
    stdNames = getStdNames(this.Quantity);
    for i = 1 : ne
        name = stdNames{i};
        if ~isfield(opt.Multiply, name)
            continue
        end
        x = opt.Multiply.(name);
        if isa(x, 'TimeSubscriptable')
            x = getDataFromTo(opt.Multiply.(name), startOfRange, endOfRange);
            x = transpose(x(:, 1));
        end
        stdMultipliers(i, :) = real(x);
    end
end

% Remove trailing NaNs if requested
if isClip 
    stdCorrReal = clip(stdCorrReal);
    if isImag
        stdCorrImag = clip(stdCorrImag);
    end
    stdMultipliers = clip(stdMultipliers);
end

return


end%


%
% Local Functions
%


function d = processTimeVaryingOption(j, opt)
    d = [ ];
    if isfield(opt, 'TimeVarying') && ~isempty(opt.TimeVarying)
        d = opt.TimeVarying;
    end
    if ~isempty(j)
        if isempty(d)
            d = j;
        else
            ERROR_CANNOT_COMBINE = { 'Model:CannotCombineTuneAndOption' 
                                     'Cannot combine a nonempty conditioning databank and option TimeVarying=' };
            throw( exception.Base(ERROR_CANNOT_COMBINE, 'error') );
        end
    end
end%


function x = clip(x)
    inxOfNaN = isnan(x);
    if all(inxOfNaN(:))
        x = double.empty(size(x, 1), 0);
        return
    end
    last = find(any(~inxOfNaN, 1), 1, 'last');
    x = x(:, 1:last);
end%

