function disp(this)
% disp  Display method for model objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this.EqtnRhs)
    fprintf('\tEmpty %s Object\n', ccn);
else
    fprintf('\t%s object\n', ccn);
end
fprintf('\tNumber of Equations: [%g]\n',length(this.EqtnRhs));

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
disp(this.Export, 1);
textual.looseLine( );

end%

