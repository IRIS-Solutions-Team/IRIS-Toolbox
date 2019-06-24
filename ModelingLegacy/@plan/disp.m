function disp(this)
% disp  Display method for plan objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

CONFIG = iris.get( );

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

nx = nnzexog(this);
[nn, nnReal, nnImag] = nnzendog(this); %#ok<ASGLU>
nc = nnzcond(this);

isEmpty = isnan(this.Start) || isnan(this.End);
if isEmpty
    fprintf('%sEmpty %s Object\n', CONFIG.DispIndent, ccn);
    fprintf('%sEmpty Range\n', CONFIG.DispIndent);
else
    fprintf('%s%s Object\n', CONFIG.DispIndent, ccn);
    fprintf( '%sRange: %s to %s\n', ...
             CONFIG.DispIndent, ...
             dat2char(this.Start), dat2char(this.End) );
end

fprintf('%sExogenized Data Points: [%g]\n', CONFIG.DispIndent, nx);
fprintf('%sEndogenized Data Points [real imag]: [%g %g]\n', CONFIG.DispIndent, nnReal, nnImag);
fprintf('%sConditioning Data Points: [%g]\n', CONFIG.DispIndent, nc);

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
textual.looseLine( );

end%

