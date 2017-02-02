function disp(this)
% disp  Display method for plan objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

nx = nnzexog(this);
[nn, nnReal, nnImag] = nnzendog(this); %#ok<ASGLU>
nc = nnzcond(this);

isEmpty = isnan(this.Start) || isnan(this.End);
if isEmpty
    fprintf('\tempty %s object\n', ccn);
    fprintf('\tempty range\n');
else
    fprintf('\t%s object\n', ccn);
    fprintf('\trange: %s to %s\n', ...
        dat2char(this.Start), dat2char(this.End));
end

fprintf('\texogenized data points: [%g]\n',nx);
fprintf('\tendogenized data points [real imag]: [%g %g]\n', nnReal, nnImag);
fprintf('\tconditioning data points: [%g]\n',nc);

disp@shared.UserDataContainer(this, 1);
textfun.loosespace( );

end
