function [YA, XA, Ea, Eu, YC, XC, wReal, wImag] = myanchors(this, p, rng, isAnt)
% myanchors  Get simulation plan anchors for model variables
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


% Check date frequencies
rng = double(rng);
if dater.getFrequency(p.Start)~=dater.getFrequency(rng(1)) ...
   || dater.getFrequency(p.End)~=dater.getFrequency(rng(end))
    utils.error('model:myanchors', ...
        'Simulation range and plan range must be the same frequency.');
end

% Adjust plan range to simulation range if not equal.
if ~dater.eq(p.Start, rng(1)) || ~dater.eq(p.End, rng(end))
    p = p(rng);
end

%--------------------------------------------------------------------------

ixx = this.Quantity.Type==2;
[ny, nxx] = sizeSolution(this.Vector);
nPer = round(rng(end) - rng(1) + 1);

% Anchors for exogenized measurement variables, and conditioning measurement
% variables.
YA = p.XAnch(1:ny, :);
YC = p.CAnch(1:ny, :);

% Anchors for exogenized transition variables, and conditioning transition
% variables.
realId = real(this.Vector.Solution{2});
imagId = imag(this.Vector.Solution{2});
XA = false(nxx, nPer);
XC = false(nxx, nPer);
for j = find(ixx)
    ixId = realId==j & imagId==0;
    XA(ixId, :) = p.XAnch(j, :);
    XC(ixId, :) = p.CAnch(j, :);
end

% Anchors for endogenized shocks.
if isAnt
    Ea = p.NAnchReal;
    Eu = p.NAnchImag;
    wReal = p.NWghtReal;
    wImag = p.NWghtImag;
else
    Ea = p.NAnchImag;
    Eu = p.NAnchReal;
    wReal = p.NWghtImag;
    wImag = p.NWghtReal;
end

end
