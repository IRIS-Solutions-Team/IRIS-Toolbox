function [sxReal, sxImag, stdScale] = varyStdCorr(this, range, j, opt, varargin)
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
    sxReal = double.empty(nsx, 0);
    sxImag = double.empty(nsx, 0);
    stdScale = double.empty(ne, 0);
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

sxReal = nan(nsx, numOfPeriods);
if isImag
    sxImag = nan(nsx, numOfPeriods);
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
        sxReal(pos(i), :) = real(x);
        if isImag
            sxImag(pos(i), :) = imag(x);
        end
    end
end

stdScale = nan(ne, numOfPeriods);
if isfield(opt, 'StdScale') && isstruct(opt.StdScale)
    stdNames = getStdNames(this.Quantity);
    for i = 1 : ne
        name = stdNames{i};
        if ~isfield(opt.StdScale, name)
            continue
        end
        x = opt.StdScale.(name);
        if isa(x, 'TimeSubscriptable')
            x = getDataFromTo(opt.StdScale.(name), startOfRange, endOfRange);
            x = transpose(x(:, 1));
        end
        stdScale(i, :) = real(x);
    end
end

% Remove trailing NaNs if requested
if isClip 
    sxReal = clip(sxReal);
    if isImag
        sxImag = clip(sxImag);
    end
    stdScale = clip(stdScale);
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

