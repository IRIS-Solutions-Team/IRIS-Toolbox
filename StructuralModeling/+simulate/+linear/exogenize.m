function [ea, eu, addEa, addEu] = exogenize(s, M, yxi, ea, eu)
% exogenize  Compute add-factors to endogenised shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(s.Anch) || ~any(s.Anch(:))
    return
end

ny = size(s.Z,1);
nxi = size(s.T,1);
ne = size(ea,1);
nPer = size(ea,2);

yxiTune = s.Tune(1:ny+nxi,:);
yxiAnch = s.Anch(1:ny+nxi,:);
eaAnch = s.Anch(ny+nxi+(1:ne),:);
euAnch = s.Anch(ny+nxi+ne+(1:ne),:);
eaWght = s.Wght(1:ne,:);
euWght = s.Wght(ne+(1:ne),:);

% Last exogenized and endogenized data points.
% findLastFn = @(X) max([0,find(any(any(X,3),1),1,'last')]);
% lastExg = findLastFn( yxiAnch(1:ny+nxi,:) );
[lastEndgA,lastEndgU] = utils.findlast(eaAnch,euAnch);

% Compute prediction errors.
% pe : = [ype(1);xpe(1);ype(2);xpe(2);...].
pe = yxiTune(yxiAnch) - yxi(yxiAnch);

% Compute add-factors that need to be added to the current shocks.
if size(M,1)==size(M,2)
    
    % Exactly determined system
    %---------------------------
    upd = M \ pe;

else
    
    % Underdetermined system (larger number of shocks)
    %--------------------------------------------------
    d = [ ...
        eaWght(eaAnch); ...
        euWght(euAnch) ...
        ].^2;
    nd = length(d);
    P = spdiags(d,0,nd,nd);
    upd = simulate.linear.updatemean(M,P,pe);
    
end

nnzEa = nnz(eaAnch(:,1:lastEndgA));
ixEa = eaAnch(:,1:lastEndgA);
ixEu = euAnch(:,1:lastEndgU);

if issparse(ea)
    [row,col] = find(ixEa);
    addEa = sparse(row,col,upd(1:nnzEa),ne,nPer);
    ea = ea + addEa;
else
    addEa = zeros(ne,lastEndgA);
    addEa(ixEa) = upd(1:nnzEa);
    ea(:,1:lastEndgA) = ea(:,1:lastEndgA) + addEa;
end

addEu = zeros(ne,lastEndgU);
addEu(ixEu) = upd(nnzEa+1:end);
eu(:,1:lastEndgU) = eu(:,1:lastEndgU) + addEu;

end
