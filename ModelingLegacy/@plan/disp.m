function disp(this)
% disp  Display method for plan objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

nx = nnzexog(this);
[nn, nnReal, nnImag] = nnzendog(this); %#ok<ASGLU>
nc = nnzcond(this);

isEmpty = isnan(this.Start) || isnan(this.End);
if isEmpty
    fprintf('\tempty %s Object\n', ccn);
    fprintf('\tEmpty Range\n');
else
    fprintf('\t%s Object\n', ccn);
    fprintf( '\tRange: %s to %s\n', ...
             dat2char(this.Start), dat2char(this.End) );
end

fprintf('\tExogenized Data Points: [%g]\n',nx);
fprintf('\tEndogenized Data Points [real imag]: [%g %g]\n', nnReal, nnImag);
fprintf('\tConditioning Data Points: [%g]\n',nc);

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
textual.looseLine( );

end%

