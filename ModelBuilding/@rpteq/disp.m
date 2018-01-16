function disp(this)
% disp  Display method for model objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this.EqtnRhs)
    fprintf('\tempty %s object\n', ccn);
else
    fprintf('\t%s object\n', ccn);
end
fprintf('\tnumber of equations: [%g]\n',length(this.EqtnRhs));

disp@shared.UserDataContainer(this, 1);
disp(this.Export, 1);
textfun.loosespace( );

end
