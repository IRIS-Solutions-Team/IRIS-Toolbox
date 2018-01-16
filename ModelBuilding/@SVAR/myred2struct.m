function outp = myred2struct(this, inp, opt)
% myred2struct  Convert reduced-form VAR residuals to structural VAR shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Panel SVARs.
if ispanel(this)
    outp = mygroupmethod(@myred2struct, this, inp, opt);
    return
end

%--------------------------------------------------------------------------

ny = size(this.A, 1);
nAlt = size(this.A, 3);

% Input data.
req = datarequest('y*, e', this, inp, Inf);
range = req.Range;
e = req.E;

if size(e, 3)==1 && nAlt>1
    e = e(:, :, ones(1, nAlt));
end

for iAlt = 1 : nAlt
    if this.Rank<ny
        e(:,:,iAlt) = pinv(this.B(:,:,iAlt)) * e(:,:,iAlt);
    else
        e(:,:,iAlt) = this.B(:,:,iAlt) \ e(:,:,iAlt);
    end
end

% Create output database by replacing reduced-form residuals in input data
% with structural residuals.
lse = get(this, 'eList');
outp = myoutpdata(this, range, e, [ ], lse, inp);

end
