function This = backward(This)
% backward  Backward VAR process.
%
% Syntax
% =======
%
%     B = backward(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `B` [ VAR ] - VAR object with the VAR process reversed in time.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

ixStat = isstationary(This);
for iAlt = 1 : nAlt
    if ixStat(iAlt)
        [T,R,~,~,~,~,U,Omg] = sspace(This,iAlt);
        % 0th and 1st order autocovariance matrices of stacked y vector.
        C = covfun.acovf(T,R,[ ],[ ],[ ],[ ],U,Omg,This.EigVal(1,:,iAlt),1);
        AOld = This.A(:,:,iAlt);
        ANew = transpose(C(:,:,2)) / C(:,:,1);
        Q = ANew*C(:,:,2);
        Omg = C(:,:,1) + ANew*C(:,:,1)*transpose(ANew) - Q - transpose(Q);
        ANew = ANew(end-ny+1:end,:);
        ANew = reshape(ANew,[ny,ny,p]);
        ANew = ANew(:,:,end:-1:1);
        ANew = ANew(:,:);
        This.A(:,:,iAlt) = ANew;
        This.Omega(:,:,iAlt) = Omg(end-ny+1:end,end-ny+1:end);
        R = sum(polyn.var2polyn(ANew),3) / sum(polyn.var2polyn(AOld),3);
        This.K(:,:,iAlt) = R * This.K(:,:,iAlt);
        This.J(:,:,iAlt) = R * This.J(:,:,iAlt);
    else
        % Non-stationary parameterisations.
        This.A(:,:,iAlt) = NaN;
        This.Omega(:,:,iAlt) = NaN;
        This.K(:,:,iAlt) = NaN;
        This.J(:,:,iAlt) = NaN;
    end
end

if any(~ixStat)
    utils.warning('VAR', ...
        ['Cannot compute backward VAR ', ...
        'for non-stationary parameterisations %s.'], ...
        exception.Base.alt2str(~ixStat) );
end

This = schur(This);

end
