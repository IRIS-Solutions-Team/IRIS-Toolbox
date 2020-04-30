function [X, inxLog, allNames] = createTrendArray(this, variantsRequested, needsDelog, id, vecTime)
% createTrendArray  Create row-oriented array with steady path for each variable
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
    variantsRequested = 1 : length(this);
end

if nargin<3
    needsDelog = true;
end

if nargin<4 || isequal(id, @all)
    id = 1 : numel(this.Quantity);
end

if nargin<5
    vecTime = this.Incidence.Dynamic.Shift;
end

%--------------------------------------------------------------------------

nv = countVariants(this);
vecTime = vecTime(:).';
numPeriods = length(vecTime);
nId = length(id);
numVariantsRequested = numel(variantsRequested);

realId = real(id);
imagId = imag(id);
inxLog = this.Quantity.IxLog(realId);
sh = bsxfun(@plus, imagId(:), vecTime(:).');

X = zeros(nId, numPeriods, numVariantsRequested);
for i = 1 : numVariantsRequested
    v = min(variantsRequested(i), nv);
    a = this.Variant.Values(1, realId, v);
    X(:, :, i) = createTrendArrayForOneVariant(a);
end

if nargout>=3
    allNames = string(this.Quantity.Name);
end

return


    function x = createTrendArrayForOneVariant(a)
        lx = real(a);
        gx = imag(a);
        
        % Zero or no imag means zero growth also for log variables
        gx(inxLog & gx==0) = 1;
        
        ixGrw = (~inxLog & gx~=0) | (inxLog & gx~=1);
        
        % Level can be negative and log(level) complex for log variables; growth
        % must be positive for log variables
        lx(inxLog) = log( lx(inxLog) );
        gx(inxLog) = reallog( gx(inxLog) );
        
        lx = lx.';
        gx = gx.';
        
        x = repmat(lx, 1, numPeriods);
        if any(ixGrw)
            x(ixGrw, :) = x(ixGrw, :) + bsxfun(@times, gx(ixGrw), sh(ixGrw, :));
        end
        
        % Delog only if requested
        if needsDelog
            x(inxLog, :) = real(exp( x(inxLog, :) ));
        end
    end%
end%

