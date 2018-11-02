function backward(s, inp, outp)

nPer = size(inp.y, 2);
nAnt = size(inp.y, 3)-1;
[nx, nb] = size(s.T);
nf = nx - nb;
[ny, ne] = size(s.H);

% T = s.T;
% Ta = T(nf+1:end, :);
% Z = s.Z;
% H = s.H;

ixa = outp.ixa;
TT = outp.TT;
RRa = outp.RR(ixa, :);
OOmg = outp.OOmg;
HH = outp.HH;

outp.w2(:, nPer) = outp.w1(:, nPer);
outp.Pw2(:, :, nPer) = outp.Pw2(:, :, nPer);

r = zeros(nx*(1+nAnt), 1);
N = zeros(nx*(1+nAnt));
for t = nPer : -1 : 1
    % Measurement errors before updating r.
    ixyy = outp.ixyy{t};
    e2 = OOmg*HH(ixyy, :).'*(outp.Fpe{t} - outp.K{t}.'*r);

    % Update r and N.
    r = outp.ZFpe{t} + outp.L{t}.'*r;
    N = outp.ZFZ{t} + outp.L{t}.'*N*outp.L{t};

    P = outp.P{t}; %outp.Pw0(:, nf+1:end, t);    
    PNP = P*N*P.';

    w2 = outp.w0(:,t) + P(1:nx, :)*r;
    
    Pw2 = outp.Pw0(:,:,t) - PNP(1:nx, 1:nx);
    Pw2 = (Pw2 + Pw2')/2;
        
    % Transition shocks.
    e2 = e2 + OOmg*RRa.'*r(ixa);
    
%     ixy = ixyy(1:ny);
%     outp.y2(ixy, t) = inp.y(ixy, t, 1);
%     outp.Py2(ixy, ixy, t) = 0;
%     Zj = Z(~ixy, :);
%     Hj = H(~ixy, :);    
%     outp.y2(~ixy, t) = Zj*w2(nf+1:end) + Hj*e2;
%     outp.Py2(~ixy, ~ixy, t) = outp.Py0(~ixy, ~ixy, t) ...
%         - Zj * PNP(nf+1:end, nf+1:end) * Zj.';
    
    outp.w2(:,t) = w2(1:nx);
    outp.Pw2(:,:,t) = Pw2(1:nx, 1:nx);
    outp.e2(:,t) = e2(1:ne);
end

% Smooth initial condition.

a1 = outp.aInit;
Pa1 = outp.PaInit;

r = TT.'*r;
N = TT.'*N*TT;

outp.a2 = a1 + Pa1*r(nf+(1:nb));

Pa2 = Pa1 - Pa1*N(nf+(1:nb), nf+(1:nb))*Pa1;
outp.Pa2 = (Pa2 + Pa2')/2;

end
