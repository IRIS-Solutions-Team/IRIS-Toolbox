function disp(this)
% disp  Display method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

STR_VARIANT = 'parameter variant';

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nAlt = size(this.A, 3);
isPanel = ispanel(this);

ccn = getClickableClassName(this);

if isempty(this.A)
    fprintf('\tempty %s object', ccn);
else
    fprintf('\t');
    if isPanel
        fprintf('panel ');
    end
    fprintf('%s(%g) object: ', ccn, p);
    fprintf('[%g %s(s)]', nAlt, STR_VARIANT);
    if isPanel
        nGrp = length(this.GroupNames);
        fprintf(' * [%g] group(s)', nGrp);
    end
end
fprintf('\n');

fprintf('\tvariables: ');
if ~isempty(this.YNames)
    fprintf('[%g] %s', length(this.YNames), textfun.displist(this.YNames));
else
    fprintf('none');
end
fprintf('\n');

specdisp(this);

% Group names for panel objects.
fprintf('\tgroups: ');
if ~isPanel
    fprintf('implicit');
else
    fprintf('[%g] %s', length(this.GroupNames), ...
        textfun.displist(this.GroupNames));
end
fprintf('\n');

disp@shared.UserDataContainer(this, 1);
textfun.loosespace( );

end
