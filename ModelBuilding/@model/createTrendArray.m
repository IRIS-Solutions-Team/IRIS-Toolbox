function X = createTrendArray(this, variantsRequested, needsDelog, id, vecTime)
% createTrendArray  Create row-oriented array with steady path for each variable.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : length(this);
end

if nargin<3
    needsDelog = true;
end

if nargin<4
    id = 1 : length(this.Quantity);
end

if nargin<5
    vecTime = this.Incidence.Dynamic.Shift;
end

%--------------------------------------------------------------------------

nv = length(this);
vecTime = vecTime(:).';
nPer = length(vecTime);
nId = length(id);
numOfVariantsRequested = numel(variantsRequested);

realId = real(id);
imagId = imag(id);
ixLog = this.Quantity.IxLog(realId);
sh = bsxfun(@plus, imagId(:), vecTime(:).');

X = zeros(nId, nPer, numOfVariantsRequested);
for i = 1 : numOfVariantsRequested
    v = min(variantsRequested(i), nv);
    a = this.Variant.Values(1, realId, v);
    X(:, :, i) = createTrendArrayForOneVariant(a);
end

return


    function x = createTrendArrayForOneVariant(a)
        lx = real(a);
        gx = imag(a);
        
        % Zero or no imag means zero growth also for log variables.
        gx(ixLog & gx==0) = 1;
        
        ixGrw = (~ixLog & gx~=0) | (ixLog & gx~=1);
        
        % Level can be negative and log(level) complex for log variables; growth
        % must be positive for log variables.
        lx(ixLog) = log( lx(ixLog) );
        gx(ixLog) = reallog( gx(ixLog) );
        
        lx = lx.';
        gx = gx.';
        
        x = repmat(lx, 1, nPer);
        if any(ixGrw)
            x(ixGrw, :) = x(ixGrw, :) + bsxfun(@times, gx(ixGrw), sh(ixGrw, :));
        end
        
        % Delog only if requested.
        if needsDelog
            x(ixLog, :) = real(exp( x(ixLog, :) ));
        end
    end
end
