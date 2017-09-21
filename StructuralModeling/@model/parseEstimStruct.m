function itr = parseEstimStruct(this, priorStruct, sp, penalty, initVal)
% parseEstimStruct  Parse structure with parameter estimation specs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

itr = model.IterateOver( );

% Remove empty entries from `E`.
lsField = fieldnames(priorStruct).';
nList = length(lsField);
remove = false(1, nList);
for i = 1 : nList
    if isempty(priorStruct.(lsField{i}))
        remove(i) = true;
    end
end
priorStruct = rmfield(priorStruct, lsField(remove));
lsField(remove) = [ ];

ell = lookup(this.Quantity, lsField);
posAssign = ell.PosName;
posStdcorr = ell.PosStdCorr;

% Reset values of parameters and stdcorrs.
itr.Quantity = this.Variant.Values;
itr.StdCorr = this.Variant.StdCorr;

% Parameters to estimate and their positions; remove names that are not
% valid parameter names.
ixValidParName = ~isnan(posAssign) | ~isnan(posStdcorr);
% Total number of parameter names to estimate.
np = sum(ixValidParName);

% System priors
%---------------
if isempty(sp)
    itr.SystemPrior = [ ];
else
    itr.SystemPrior = sp;
end

% Parameter priors
%------------------
itr.LsParam = lsField(ixValidParName);
itr.PosQty  = posAssign(ixValidParName);
itr.PosStdCorr = posStdcorr(ixValidParName);

% Starting value
%----------------
% Prepare the value currently assigned in the model object; this is used
% when the starting value in the estimation struct is `NaN`.
startIfNan = nan(1, np);
for i = 1 : np
    if ~isnan(itr.PosQty(i))
        startIfNan(i) = this.Variant.Values(:, itr.PosQty(i), :);
    else
        startIfNan(i) = this.Variant.StdCorr(:, itr.PosStdCorr(i), :);
    end
end

% Estimation struct can include names that are not valid parameter names;
% throw a warning for them.
reportInvalidNames( );

itr = parseEstimStruct@shared.Estimation( ...
    this, priorStruct, itr, startIfNan, penalty, initVal ...
    );

return




    function reportInvalidNames( )
        if any(~ixValidParName)
            lsInvalidName = lsField(~ixValidParName);
            utils.warning('model:parseEstimStruct', ...
                ['This name in the estimation struct is not ', ...
                'a valid parameter name: ''%s''.'], ...
                lsInvalidName{:});
        end
    end
end
