function M = multipliers(S,YXAnch)
% multipliers  [Not a public function] Compute anticipated or unanticipated multipliers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

ny = size(S.Z,1);
nxi = size(S.T,1);
nb = size(S.T,2);
nf = nxi - nb;
ne = size(S.Eu,1);

try
    yAnch = YXAnch(1:ny,:);
    xAnch = YXAnch(ny+(1:nxi),:);
catch
    yAnch = S.Anch(1:ny,:);
    xAnch = S.Anch(ny+(1:nxi),:);
end

%--------------------------------------------------------------------------

eaAnch = S.Anch(ny+nxi+(1:ne),:);
euAnch = S.Anch(ny+nxi+ne+(1:ne),:);

% Last exogenized and endogenized data points.
lastExg = max([ 0, find(any([yAnch;xAnch],1), 1,'last') ]);
lastEndgA = max([ 0, find(any(eaAnch,1), 1,'last') ]);
lastEndgU = max([ 0, find(any(euAnch,1), 1,'last') ]);

% Ma := [May(1);Max(1);May(2);Max(2);...];
% Mu := [Muy(1);Mux(1);Muy(2);Mux(2);...];

nnzEa = nnz(eaAnch);
nnzEu = nnz(euAnch);

Tf = S.T(1:nf,:);
Ta = S.T(nf+1:end,:);

Ma = zeros(0,nnzEa);
if nnzEa > 0
    doMa( );
end

Mu = zeros(0,nnzEu);
if nnzEu > 0
    doMu( );
end

M = [Ma,Mu];

return

    
    
    function doMa( )
        maAlp = zeros(nb,ne*lastEndgA);
        eaAnch = eaAnch(:,1:lastEndgA);
        eaAnch = eaAnch(:).';
        r = S.R(:,1:ne*lastEndgA);
        for tt = 1 : lastExg
            maF = Tf*maAlp;
            maAlp = Ta*maAlp;
            if tt <= lastEndgA
                maF(:,(tt-1)*ne+1:end) = ...
                    maF(:,(tt-1)*ne+1:end) + r(1:nf,:);
                maAlp(:,(tt-1)*ne+1:end) = ...
                    maAlp(:,(tt-1)*ne+1:end) + r(nf+1:end,:);
                r = r(:,1:end-ne);
            end
            maY = S.Z*maAlp;
            if tt <= lastEndgA
                maY(:,(tt-1)*ne+(1:ne)) = maY(:,(tt-1)*ne+(1:ne)) + S.H;
            end
            Ma = [ ...
                Ma; ...
                maY( yAnch(:,tt), eaAnch ); ... Y
                maF( xAnch(1:nf,tt), eaAnch ); ... Xf
                S.U( xAnch(nf+1:end,tt), : ) * maAlp(:,eaAnch); ... Xb := U*Alp
                ]; %#ok<AGROW>
        end
    end % doMa( )



    function doMu( )
        muAlp = zeros(nb,ne*lastEndgU);
        euAnch = euAnch(:,1:lastEndgU);
        euAnch = euAnch(:).';
        r = S.R(:,1:ne);
        for tt = 1 : lastExg
            muF = Tf*muAlp;
            muAlp = Ta*muAlp;
            if tt <= lastEndgU
                muF(:,(tt-1)*ne+(1:ne)) = ...
                    muF(:,(tt-1)*ne+(1:ne)) + r(1:nf,:);
                muAlp(:,(tt-1)*ne+(1:ne)) = ...
                    muAlp(:,(tt-1)*ne+(1:ne)) + r(nf+1:end,:);
            end
            muY = S.Z*muAlp;
            if tt <= lastEndgU
                muY(:,(tt-1)*ne+(1:ne)) = muY(:,(tt-1)*ne+(1:ne)) + S.H;
            end
            Mu = [ ...
                Mu; ...
                muY( yAnch(:,tt), euAnch ); ... Y
                muF( xAnch(1:nf,tt), euAnch ); ... Xf
                S.U( xAnch(nf+1:end,tt), : ) * muAlp(:,euAnch); ... Xb := U*Alp
                ]; %#ok<AGROW>
        end
    end % doMu( )
end
