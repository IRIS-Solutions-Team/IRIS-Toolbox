function [F, Pe, V, delta, PDelta, sampleCov, this] ...
    = kalmanFilterRegOutp(this, regOutp, xRange, likOpt, opt)
% kalmanFilterRegOutp  Postprocess regular (non-hdata) output arguments from the Kalman filter or FD lik.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    isNamedMat = strcmpi(opt.MatrixFmt, 'namedmat');
catch
    isNamedMat = false;
end

TYPE = @int8;
TEMPLATE_SERIES = Series( );

%--------------------------------------------------------------------------

ixy = this.Quantity.Type==TYPE(1);
ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

startDate = xRange(1);

F = [ ];
if isfield(regOutp, 'F')
    F = TEMPLATE_SERIES;
    F = replace(F, permute(regOutp.F, [3, 1, 2, 4]), startDate);
end

Pe = [ ];
if isfield(regOutp, 'Pe')
    Pe = struct( );
    for iName = find(ixy)
        name = this.Quantity.Name{iName};
        data = permute(regOutp.Pe(iName, :, :), [2, 3, 1]);
        if this.Quantity.IxLog(iName)
            data = real(exp(data));
        end
        Pe.(name) = TEMPLATE_SERIES;
        Pe.(name) = replace(Pe.(name), data, startDate, name);
    end
end

V = [ ];
if isfield(regOutp, 'V')
    V = regOutp.V;
end

% Update out-of-lik parameters in the model object.
delta = struct( );
lsDelta = this.Quantity.Name(likOpt.outoflik);
if isfield(regOutp, 'Delta')
    for i = 1 : length(likOpt.outoflik)
        name = lsDelta{i};
        posQty = likOpt.outoflik(i);
        this.Variant = model.Variant.assignQuantity( ...
            this.Variant, posQty, ':', regOutp.Delta(i, :) ...
            );
        delta.(name) = regOutp.Delta(i, :);
    end
end

PDelta = [ ];
if isfield(regOutp, 'PDelta')
    PDelta = regOutp.PDelta;
    if isNamedMat
        PDelta = namedmat(PDelta, lsDelta, lsDelta);
    end
end

sampleCov = [ ];
if isfield(regOutp, 'SampleCov')
    sampleCov = regOutp.SampleCov;
    if isNamedMat
        eList = this.Quantity.Name(ixe);
        sampleCov = namedmat(sampleCov, eList, eList);
    end
end

% Update the std parameters in the model object.
if likOpt.relative && nargout>6
    ne = sum(ixe);
    nAlt = length(this);
    se = sqrt(V);
    for iAlt = 1 : nAlt
        this.Variant{iAlt}.StdCorr(1, 1:ne) = ...
            this.Variant{iAlt}.StdCorr(1, 1:ne)*se(iAlt);
    end
    % Refresh dynamic links after we change std deviations because std devs are
    % allowed in dynamic links.
    if any(this.Link)
        this = refresh(this);
    end
end

end
