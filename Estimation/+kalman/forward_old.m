function forward(s, inp, outp)

y = inp.y;
nAnt = size(y, 3)-1;
nAhead = max(outp.Ahead, nAnt);

nPer = size(y, 2);
[ny, ne] = size(s.H);
[nx, nb] = size(s.T);
nf = nx - nb;

Omg = covfun.stdcorr2cov(s.StdCorr, ne);
if nAnt==0
    ZZ = s.Z;
    HH = s.H;
    dd = s.d;
    OOmg = Omg;
else
    [ZZ, HH, dd] = stackTime( );
end
SgmWW = RR*OOmg*RR.';
SgmYY = HH*OOmg*HH.';
TTa = TT(ixa, :);
RRa = RR(ixa, :);

if outp.StoreSmooth
    outp.HH = HH;
    outp.Omg = Omg;
    outp.RRa = RRa;
end

% if nAhead>0
%     inp_ = kalman.InpData( );
%     outp_ = kalman.OutpData( );
%     outp_.StorePredict = true;
%     outp_.StoreFilter = true;
%     outp_.StoreSmooth = true;
% end

a1 = outp.aInit;
Pa1 = outp.PaInit;
e1 = [ ];
logDet = 0;
peFpe = 0;

for t = 1 : nPer
    w0 = TT*a1(1:nb) + kk;
    Pw0 = TT*Pa1(1:nb, 1:nb)*TT.' + SgmWW;
    Pw0 = (Pw0 + Pw0')/2;
    
    a0 = w0(ixa);
    Pa0 = Pw0(ixa, ixa);
    
    y1 = y(:, t, :);
    y1 = y1(:);
    ixyy = ~isnan(y1);
    pe = nan(length(ixyy), 1);
    
    if ~any(ixyy)
        % No observations at the time, updated=predicted.
        n = 1 + nAhead;
        y0j = zeros(0, 1);
        w1 = w0;
        Pw1 = Pw0;
        Zj = zeros(0, nb*n);        
        Fj = zeros(0);
        ZF = zeros(nb*n, 0);
        ZFZ = zeros(nb*n);
        ZFpe = zeros(nb*n, 1);
        Fpe = zeros(0, 1);
    else
        % Some observatations at the time, update.
        Zj = ZZ(ixyy, :);
        y0j = Zj*a0 + dd(ixyy);
        Fj = Zj*Pa0*Zj.' + SgmYY(ixyy, ixyy);
        Fj = (Fj + Fj')/2;
        
        pe(ixyy) = y1(ixyy) - y0j;
        pej = pe(ixyy);

        P = Pw0(:, ixa);
        invFj = inv(Fj);
        invFj = (invFj + invFj')/2;
        
        ZF = Zj.' * invFj;
        Fpe = invFj*pej;
        ZFZ = ZF*Zj;
        ZFpe = Zj.'*Fpe;
        
        logDet = logDet + log(det(Fj));
        peFpe = peFpe + pej.'*Fpe;
        
        w1 = w0 + P*ZFpe;
        Pw1 = Pw0 - P*ZFZ*P.';
        Pw1 = (Pw1 + Pw1')/2;
    end
    
    a1 = w1(ixa);
    Pa1 = Pw1(ixa, ixa);
    
    if outp.StoreAhead
        e1 = OOmg*( HH(ixyy, :).'*Fpe  +  RRa.'*ZFpe );
        y1 = ZZ*a1 + dd + HH*e1;
    elseif outp.StoreFilter
        e1 = Omg*( HH(ixyy, 1:ne).'*Fpe  +  RRa(:, 1:ne).'*ZFpe );
        y1 = s.Z*a1(1:nb) + s.d + s.H*e1(1:ne);
    end

    if outp.StoreSmooth
        outp.ixyy{t} = ixyy;
        outp.P{t} = Pw0(1:nx, ixa);
        outp.K{t} = TTa(1:nb, :)*Pa0(1:nb, :)*ZF;
        outp.ZFZ{t} = ZFZ;
        outp.ZFpe{t} = ZFpe;
        outp.Fpe{t} = Fpe;
        outp.L{t} = TTa - outp.K{t}*Zj;
    end
    
    if outp.StorePredict
        storePredict( );
    end
    
    if outp.StoreFilter
        storeFilter( );
    end
    
    if outp.StoreAhead
        storeAhead( );
    end    
end

nObs = sum( ~isnan(y(:)) );
V = 1;
if outp.RescaleVar
    V = peFpe / nObs;
    logDet = logDet + nObs*log(V);
    peFpe = peFpe / V;
end
minLogLik = 0.5*( nObs*log(2*pi) + logDet + peFpe );
outp.MinLogLik = minLogLik;
outp.VarScale = V;

return




    function [ZZ, HH, dd, OOmg] = stackTime( )
        TT = eye(nb);
        Ta = s.T(nf+1:end, :);
        RR = zeros(nb, (1+nAnt)*ne);
        kk = zeros(nb, 1);
        R_ = s.R(nf+1:end, 1:(1+nAnt)*ne);
        for i = 1 : nAnt
            TT = [ TT; Ta*TT(end-nb+1:end, :) ]; %#ok<AGROW>
            kk = [ kk; T*kk(end-nb+1:end)+s.k ]; %#ok<AGROW>
            R_ = [ zeros(nb, ne), R_(:, 1:end-ne) ];
            RR = [ RR; T*RR(end-nb+1:end, :) + R_ ]; %#ok<AGROW>
        end
        ZZ = kron(eye(1+nAnt), s.Z) * TT;
        dd = repmat(s.d, 1+nAnt, 1);
        HH = RR + kron(eye(1+nAnt, 1+nAnt), s.H);
        OOmg = kron(eye(1+nAnt), Omg);
    end




    function storeAhead( )
        n = 1 + outp.Ahead;
        outp.w00(:,t,:) = reshape(w1(1:n*nx), nx, 1, n);
        outp.y00(:,t,:) = reshape(y1(1:n*ny), ny, 1, n);
        if outp.Ahead<nAnt
            outp.e00(:,t,:) = reshape(e1(1:n*ne), ne, 1, n);
        else
            outp.e00(:,t,:) = 0;
            outp.e00(:,t,1:1+nAnt) = reshape(e1, ne, 1, 1+nAnt);
        end
    end
%     function runAhead( )
%         inp_.y = y1(:, 2:end);
%         if size(inp_.y, 2)<nAhead
%             inp_.y(:, end+1:nAhead) = NaN;
%         end
%         outp_.aInit = a1;
%         outp_.PaInit = Pa1;
%         prealloc(outp_, s, inp_);
%         kalman.forward(s, inp_, outp_);
%         kalman.backward(s, inp_, outp_);
%         outp.w00(:, t, 1:nAhead+1) = ...
%             permute([outp.w1(:,t), outp_.w2(:, 1:nAhead)], [1, 3, 2]);
%         outp.y00(:, t, 1:nAhead+1) = ...
%             permute([outp.y1(:,t), outp_.y2(:, 1:nAhead)], [1, 3, 2]);
%         outp.e00(:, t, 1:nAhead+1) = ...
%             permute([outp.e1(:,t), outp_.e2(:, 1:nAhead)], [1, 3, 2]);
%     end




    function storePredict( )
        outp.w0(:,t) = w0(1:nx);
        outp.Pw0(:,:,t) = Pw0(1:nx, 1:nx);
        if all( ixyy(1:ny) )
            outp.y0(:,t) = y0j(1:ny);
            outp.Py0(:,:,t) = Fj(1:ny, 1:ny);
        else
            outp.y0(:,t) = s.Z*a0(1:nb) + s.d;
            outp.Py0(:,:,t) = s.Z*Pa0(1:nb, 1:nb)*s.Z.' + SgmYY(1:ny, 1:ny);
        end
        outp.pe(:,t) = pe(1:ny);
        outp.e0(:,t) = 0;
    end




    function storeFilter( )
        outp.w1(:,t) = w1(1:nx);
        outp.Pw1(:,:,t) = Pw1(1:nx, 1:nx);
%         outp.y1(:,t) = y1(1:ny);
        
        outp.e1(:,t) = e1(1:ne);

        outp.y1(:,t) = y1(1:ny);
        % outp.Py1(:,:,t) = s.Z*Pa1(1:nb, 1:nb)*s.Z.' + SgmYY(1:ny, 1:ny);

%         outp.Py1(:,:,t) = 0;
%         ix1 = ~ixyy(1:ny);
%         if any(ix1)
%             Z1 = Z(ix1, :);
%             outp.y1(ix1, t) = Z1*a1 + d(ix1) + HH;
%             outp.Py1(ix1, ix1, t) = Z1*Pa1*Z1.' + SgmY(ix1, ix1);
%         end
        
    end
end
