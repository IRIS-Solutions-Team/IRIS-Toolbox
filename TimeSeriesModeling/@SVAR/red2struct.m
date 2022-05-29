% red2struct  Convert reduced-form VAR residuals to structural VAR shocks
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function outp = red2struct(this, inp, opt)

if this.IsPanel
    outp = runGroups(@red2struct, this, inp, opt);
    return
end

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nv = size(this.A, 3);

% Input data
req = datarequest('y*, e', this, inp, Inf);
range = req.Range;
e = req.E;

if size(e, 3)==1 && nv>1
    e = repmat(e, 1, 1, nv);
end

for v = 1 : nv
    if this.Rank(v)<ny
        e(:,:,v) = pinv(this.B(:,:,v)) * e(:,:,v);
    else
        e(:,:,v) = this.B(:,:,v) \ e(:,:,v);
    end
end

% Create output database by replacing reduced-form residuals in input data
% with structural residuals.
lse = get(this, 'eList');
outp = myoutpdata(this, range, e, [ ], lse, inp);

end%

