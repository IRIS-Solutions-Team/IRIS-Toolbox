function This = assign(This,A,Omg,XRange,Fitted)
% assign  [Not a public function] Manually assign system matrices to BaseVAR objects
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

A = A(:,:,:);
ny = length(This.EndogenousNames);
nAlt = size(A,3);
p = size(A,2) / ny;

if ~isfinite(p) || round(p) ~= p || size(A,1) ~= ny
    utils.error('BaseVAR:assign', ...
        'Invalid size of the transition matrix A.');
end

if size(Omg,1) ~= ny || size(Omg,2) ~= ny || size(Omg,3) ~= nAlt
    utils.error('BaseVAR:assign', ...
        'Invalid size of the covariance matrix Omg.');
end

This.A = A;
This.Omega = Omg;

This.Range = XRange;
if ~isempty(XRange) && ~isempty(Fitted)
    if length(Fitted) ~= nAlt
        utils.error('BaseVAR:assign', ...
            'Invalid size of array of fitted observation dates Fitted.');
    end
    for iAlt = 1 : nAlt
        pos = round(Fitted{iAlt} - XRange(1) + 1);
        This.IxFitted(1,pos,iAlt) = true;
    end
end

end
