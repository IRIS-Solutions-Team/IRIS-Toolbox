function initialize(s, inp, outp, opt)

nPer = size(inp.y, 2);
[nx, nb] = size(s.T);
ne = size(s.H, 2);
nf = nx - nb;
nUnit = s.NUnit;
nStable = nb - nUnit;
ixStable = [ false(1, nUnit), true(1, nb-nUnit) ];
Ta = s.T(nf+1:end, :);
TStable = Ta(ixStable, ixStable);

if isempty(inp.aInit)
    asymptoticMedian( );
else
    outp.aInit = inp.aInit;
end

if isempty(inp.PaInit)
    asymptoticMse( );
else
    outp.PaInit = inp.PaInit;
end

return




    function asymptoticMedian( )
        ka = s.k(nf+1:end, :);
        kStable = ka(ixStable);
        aStable = zeros(nStable, 1);
        aUnit = zeros(nUnit, 1);
        if nStable>0
            aStable = (eye(nStable) - TStable) \ kStable;
        end
        if nUnit>0 && ~isequal(opt.UnitFromData, false)
            nt = opt.UnitFromData;
            if isequal(nt, @auto)
                nt = nUnit;
            end
            nt = min(nt, nPer);
            y0 = inp.y(:, 1:nt, 1);
            ixy = ~isnan(y0);
            Z = s.Z;
            ZT = [ ];
            Tak = Ta;
            for t = 1 : nt+1+5
                ZT = [ZT; Z*Tak]; %#ok<AGROW>
                if t<nt
                    Tak = Ta*Tak;
                end
            end
            ZT1 = ZT(ixy, 1:nUnit);
            ZT2 = ZT(ixy, nUnit+1:end);
            aUnit = pinv(ZT1)*(y0(ixy) - ZT2*aStable);
        end
        outp.aInit = [aUnit; aStable];
    end




    function asymptoticMse( )
        Ra = s.R(nf+1:end, 1:ne);
        RStable = Ra(ixStable, :);
        Omg = covfun.stdcorr2cov(s.StdCorr, ne);
        SgmStable = RStable*Omg*RStable.';
        PStable = zeros(nStable);
        maxVar = 1;
        if nStable>0
            PStable = covfun.lyapunov(TStable, SgmStable);
            PStable = (PStable + PStable.')/2;
            % maxVar = max( [1, diag(PStable).'] );
            maxVar = max( diag(PStable).' );
        end
        outp.PaInit = zeros(nb);
        outp.PaInit(~ixStable, ~ixStable) = maxVar*s.DIFFUSE_SCALE*eye(nUnit);
        outp.PaInit(ixStable, ixStable) = PStable;
    end
end