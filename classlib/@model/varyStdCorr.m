function [stdcorrReal, stdcorrImag] = varyStdCorr(this, range, j, opt, varargin)
% varyStdCorr  Convert the option 'vary=' or a tune database to stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

isClip = any(strcmpi(varargin, 'clip'));
isImag = nargout>1;

%--------------------------------------------------------------------------

% We do not include pre-sample.

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ne = sum(ixe);
nStdcorr = ne + ne*(ne-1)/2;

if isempty(range)
    stdcorrReal = nan(nStdcorr, 0);
    stdcorrImag = nan(nStdcorr, 0);
    return
end

d = [ ];
processTimeVarying( );

range = range(1) : range(end);
nPer = length(range);
stdcorrReal = nan(nStdcorr, nPer);

if ~isempty(d)
    c = fieldnames(d);
    ell = lookup(this.Quantity, c);
    posStdCorr = ell.PosStdCorr;
    for i = find(~isnan(posStdCorr))
        x = d.(c{i});
        if isa(x, 'tseries')
            x = rangedata(x, range);
            x = x(:,1);
            x = x(:).';
        end
        stdcorrReal(posStdCorr(i), :) = x;
    end
end

if isImag
    stdcorrImag = imag(stdcorrReal);
end
stdcorrReal = real(stdcorrReal);

% Vector of non-NaN variances/stdevs.
scRealInx = ~isnan(stdcorrReal);

if isImag
    scImagInx = ~isnan(stdcorrImag);
end

% If requested, remove all periods behind the last user-supplied data
% point.
if isClip
    last = find(any(scRealInx,1), 1, 'last');
    stdcorrReal = stdcorrReal(:, 1:last);
    if isImag
        last = find(any(scImagInx, 1), 1, 'last');
        stdcorrImag = stdcorrImag(:,1:last);
    end
end

return




    function processTimeVarying( )
        if isfield(opt, 'vary') && ~isempty(opt.vary)
            d = opt.vary;
        end
        if ~isempty(j)
            if isempty(d)
                d = j;
            else
                utils.error('model:varyStdCorr', ...
                    ['Cannot combine a tune database and ', ...
                    'the option vary=.']);
            end
        end
    end
end
        
