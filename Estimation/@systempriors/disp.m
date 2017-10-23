function disp(this)
% disp  Display method for systempriors objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ccn = getClickableClassName(this);

if isempty(this)
    fprintf('\tempty %s object\n', ccn);
else
    fprintf('\t%s object: [%g] prior(s)\n', ccn, length(this));
end

disp@shared.UserDataContainer(this, 1);
textual.looseLine( );

end
