function disp(this)
% disp  Display method for model objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

CONFIG = iris.get( );

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this.EqtnRhs)
    fprintf(CONFIG.DispIndent);
    fprintf('Empty %s Object\n', ccn);
else
    fprintf('%s Object\n', ccn);
end
fprintf(CONFIG.DispIndent);
fprintf('Number of Equations: [%g]\n',length(this.EqtnRhs));

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
implementDisp(this.Export);
textual.looseLine( );

end%

