function [lsValid, lsInvalid] = verifyEstimStruct(this, estimStruct)
% verifyEstimStruct  Verify estimation struct.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

lsField = fieldnames(estimStruct).';
validFn = @(X) ~isempty(X) && length(X)<=4 && (isnumeric(X) || iscell(X));
ixArray = structfun(validFn, estimStruct);
ixArray = ixArray(:).';

ell = lookup(this.Quantity, lsField);
posName = ell.PosName;
posStdCorr = ell.PosStdCorr;
ixValidName = ~isnan(posName) | ~isnan(posStdCorr);

ixValid = ixArray & ixValidName;
lsValid = lsField(ixValid);
lsInvalid = lsField(~ixValid);

end
