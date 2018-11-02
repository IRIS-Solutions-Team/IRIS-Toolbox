function forward(s, inp, outp)

y = inp.y;
numOfAnt = size(y, 3)-1;

numOfPeriods = size(y, 2);
[ny, ne] = size(s.H);
[nx, nb] = size(s.T);
nf = nx - nb;

Omg = covfun.stdcorr2cov(s.StdCorr, ne);
if numOfAnt==0
    TT = [zeros(nx, nf), s.T];
    RR = s.R(:, 1:ne*(1+numOfAnt));
    kk = s.k;
    ZZ = [zeros(ny, nf), s.Z];
    HH = s.H;
    dd = s.d;
    OOmg = Omg;
    ixa = [ false(nf, 1); true(nb, 1) ];
else
    [TT, RR, kk, ZZ, HH, dd, OOmg, ixa] = stackTime( );
end
SgmWW = RR*OOmg*RR.';
SgmYY = HH*OOmg*HH.';
SgmWW = (SgmWW + SgmWW')/2;
SgmYY = (SgmYY + SgmYY')/2;
% TTa = TT(ixa, :);
% RRa = RR(ixa, :);

if outp.StoreSmooth
    outp.TT = TT;
    outp.RR = RR;
    outp.HH = HH;
    outp.OOmg = OOmg;
    outp.ixa = ixa;
end

a1 = outp.aInit;
Pa1 = outp.PaInit;

w1 = zeros(nx*(1+numOfAnt), 1);
Pw1 = zeros(nx*(1+numOfAnt));
w1(nf+(1:nb)) = a1;
Pw1(nf+(1:nb), nf+(1:nb)) = Pa1;

e1 = [ ];
logDet = 0;
peFpe = 0;

for t = 1 : numOfPeriods
    w0 = TT(:, ixa)*w1(ixa) + kk;
    Pw0 = TT(:, ixa)*Pw1(ixa, ixa)*TT(:, ixa).' + SgmWW;
    Pw0 = (Pw0 + Pw0')/2;
    
%     a0 = w0(ixa);
%     Pa0 = Pw0(ixa, ixa);
    
    y1 = y(:, t, :);
    y1 = y1(:);
    ixyy = ~isnan(y1);
    pe = nan(length(ixyy), 1);
    
    if ~any(ixyy)
        % No observations at the time, updated=predicted.
        n = 1 + numOfAnt;
        y0j = zeros(0, 1);
        w1 = w0;
        Pw1 = Pw0;
        Zj = zeros(0, nx*n);        
        Fj = zeros(0);
        ZF = zeros(nx*n, 0);
        ZFZ = zeros(nx*n);
        ZFpe = zeros(nx*n, 1);
        Fpe = zeros(0, 1);
    else
        % Some observatations at the time, update.
        Zj = ZZ(ixyy, :);
        y0j = Zj(:, ixa)*w0(ixa) + dd(ixyy);
        Fj = Zj(:, ixa)*Pw0(ixa, ixa)*Zj(:, ixa).' + SgmYY(ixyy, ixyy);
        Fj = (Fj + Fj')/2;
        
        pe(ixyy) = y1(ixyy) - y0j;
        pej = pe(ixyy);

        P = Pw0;
        invFj = inv(Fj);
        invFj = (invFj + invFj')/2;
        
        ZF = Zj.'*invFj;
        Fpe = invFj*pej;
        ZFZ = ZF*Zj;
        ZFpe = Zj.'*Fpe;
        
        logDet = logDet + log(det(Fj));
        peFpe = peFpe + pej.'*Fpe;
        
        w1 = w0 + P*ZFpe;
        Pw1 = Pw0 - P*ZFZ*P.';
        Pw1 = (Pw1 + Pw1')/2;
    end
    
%     a1 = w1(ixa);
%     Pa1 = Pw1(ixa, ixa);
    
    if outp.StoreFilter || outp.StoreAhead
%         e1 = OOmg*( HH(ixyy, :).'*Fpe  +  RRa.'*ZFpe );
%         y1 = ZZ*a1 + dd + HH*e1;
        e1 = OOmg*( HH(ixyy, :).'*Fpe  +  RR.'*ZFpe );
        y1 = ZZ*w1 + dd + HH*e1;
%     elseif outp.StoreFilter
%         e1 = Omg*( HH(ixyy, 1:ne).'*Fpe  +  RRa(:, 1:ne).'*ZFpe );
%         y1 = s.Z*a1(1:nb) + s.d + s.H*e1(1:ne);
    end

    if outp.StoreSmooth
        outp.ixyy{t} = ixyy;
        outp.P{t} = Pw0;
        outp.K{t} = TT*Pw0*ZF;
        outp.ZFZ{t} = ZFZ;
        outp.ZFpe{t} = ZFpe;
        outp.Fpe{t} = Fpe;
        outp.L{t} = TT - outp.K{t}*Zj;
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




    function [TT, RR, kk, ZZ, HH, dd, OOmg, ixa] = stackTime( )
        T = [zeros(nx, nf), s.T];
        R = s.R(:, 1:(1+numOfAnt)*ne);
        TT = T;
        RR = R;
        kk = s.k;
        for i = 1 : numOfAnt
            TT = [ TT; T*TT(end-nx+1:end, :) ]; %#ok<AGROW>
            kk = [ kk; T*kk(end-nx+1:end)+s.k ]; %#ok<AGROW>
            R = [ zeros(nx, ne), R(:, 1:end-ne) ];
            RR = [ RR; T*RR(end-nx+1:end, :) + R ]; %#ok<AGROW>
        end
        TT = [TT, zeros(nx*(1+numOfAnt), nx*numOfAnt)];
        Z = [zeros(ny, nf), s.Z];
        ZZ = kron(eye(1+numOfAnt), Z);
        dd = repmat(s.d, 1+numOfAnt, 1);
        HH = kron(eye(1+numOfAnt), s.H);
        OOmg = kron(eye(1+numOfAnt), Omg);
        ixa = [ false(nf, 1); true(nb, 1) ];
        ixa = repmat(ixa, 1+numOfAnt, 1);
    end




    function storeAhead( )
        n = 1 + outp.Ahead;
        outp.ww1(:,t,:) = reshape(w1(1:n*nx), nx, 1, n);
%         outp.yy1(:,t,:) = reshape(y1(1:n*ny), ny, 1, n);
        outp.ee1(:,t,:) = reshape(e1(1:n*ne), ne, 1, n);
%         if outp.Ahead<numOfAnt
%             outp.ee1(:,t,:) = reshape(e1(1:n*ne), ne, 1, n);
%         else
%             outp.ee1(:,t,:) = 0;
%             outp.ee1(:,t,1:1+numOfAnt) = reshape(e1, ne, 1, 1+numOfAnt);
%         end
    end




    function storePredict( )
        outp.w0(:,t) = w0(1:nx);
        outp.Pw0(:,:,t) = Pw0(1:nx, 1:nx);
        if all( ixyy(1:ny) )
            outp.y0(:,t) = y0j(1:ny);
            outp.Py0(:,:,t) = Fj(1:ny, 1:ny);
        else
            outp.y0(:,t) = ZZ(1:ny, :)*w0 + dd(1:ny);
            outp.Py0(:,:,t) = ZZ(1:ny, :)*Pw0*ZZ(1:ny, :).' + SgmYY(1:ny, 1:ny);
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
