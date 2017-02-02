function X = createTrendArray(this, vecAlt, needsDelog, id, vecTime)
% createTrendArray  Create row-oriented array with steady path for each variable.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try, vecAlt;     catch, vecAlt = Inf; end %#ok<VUNUS,NOCOM>
try, needsDelog; catch, needsDelog = true; end %#ok<NOCOM>
try, id;         catch, id = 1 : length(this.Quantity); end %#ok<VUNUS,NOCOM>
try, vecTime;    catch, vecTime = this.Incidence.Dynamic.Shift; end %#ok<VUNUS,NOCOM>

%--------------------------------------------------------------------------

vecTime = vecTime(:).';
nAlt = length(this);
nPer = length(vecTime);
nId = length(id);
if isequal(vecAlt, Inf) || isequal(vecAlt, @all)
    vecAlt = 1 : nAlt;
end
nVecAlt = numel(vecAlt);

realId = real(id);
imagId = imag(id);
ixLog = this.Quantity.IxLog(realId);
sh = bsxfun(@plus, imagId(:), vecTime(:).');

X = zeros(nId, nPer, nVecAlt);
for i = 1 : nVecAlt
    X(:, :, i) = createTrendArrayForOneAlt( vecAlt(i) );
end

return




    function x = createTrendArrayForOneAlt(iAlt)
        a = this.Variant{ min(iAlt, nAlt) }.Quantity(1, realId);
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
