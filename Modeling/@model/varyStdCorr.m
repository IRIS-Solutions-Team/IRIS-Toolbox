function [sxReal, sxImag] = varyStdCorr(this, range, j, opt, varargin)
% varyStdCorr  Convert time-varying std and corr to stdcorr vector
%
% Backend IRIS function.
% No help provided.

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
    sxReal = nan(nsx, 0);
    sxImag = nan(nsx, 0);
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

d = processTimeVaryingOption( );

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
            x = x(:, 1);
            x = x(:).';
        end
        sxReal(pos(i), :) = real(x);
        if isImag
            sxImag(pos(i), :) = imag(x);
        end
    end
end
 
% Remove trailing NaNs if requested
if isClip 
    ixSxReal = ~isnan(sxReal);
    if isImag
        ixScImag = ~isnan(sxImag);
    end
    last = find(any(ixSxReal, 1), 1, 'last');
    sxReal = sxReal(:, 1:last);
    if isImag
        last = find(any(ixScImag, 1), 1, 'last');
        sxImag = sxImag(:, 1:last);
    end
end

return


    function d = processTimeVaryingOption( )
        d = [ ];
        if isfield(opt, 'TimeVarying') && ~isempty(opt.TimeVarying)
            d = opt.TimeVarying;
        end
        if ~isempty(j)
            if isempty(d)
                d = j;
            else
                utils.error( 'model:varyStdCorr', ...
                             'Cannot combine a conditioning database and the option TimeVarying=' );
            end
        end
    end%
end%

