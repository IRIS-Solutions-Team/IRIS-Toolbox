function disp(this)
% disp  Display method for VAR objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

CONFIG = iris.get( );
STR_VARIANT = 'parameter variant';

%--------------------------------------------------------------------------

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nv = size(this.A, 3);
isPanel = ispanel(this);

ccn = getClickableClassName(this);

if isempty(this.A)
    fprintf('%sEmpty %s Object', CONFIG.DispIndent, ccn);
else
    fprintf('%s', CONFIG.DispIndent);
    if isPanel
        fprintf('panel ');
    end
    fprintf('%s(%g) Object: ', ccn, p);
    fprintf('[%g %s(s)]', nv, STR_VARIANT);
    if isPanel
        nGrp = length(this.GroupNames);
        fprintf(' * [%g] group(s)', nGrp);
    end
end
fprintf('\n');

fprintf('%sEndogenous: ', CONFIG.DispIndent);
if ~isempty(this.NamesEndogenous)
    fprintf('[%g] %s', length(this.NamesEndogenous), textfun.displist(this.NamesEndogenous));
else
    fprintf('none');
end
fprintf('\n');

% Exogenous inputs
fprintf('%sExogenous: [%g] ', CONFIG.DispIndent, length(this.NamesExogenous));
if ~isempty(this.NamesExogenous)
    fprintf('%s', textfun.displist(this.NamesExogenous));
end
fprintf('\n');

% Conditioning instruments
fprintf('%sConditioning: [%g] ', CONFIG.DispIndent, length(this.NamesConditioning));
if ~isempty(this.NamesConditioning)
    fprintf('%s', textfun.displist(this.NamesConditioning));
end
fprintf('\n');

specdisp(this);

% Group names for panel objects
fprintf('%sGroups: ', CONFIG.DispIndent);
if ~isPanel
    fprintf('implicit');
else
    fprintf( '[%g] %s', length(this.GroupNames), ...
             textfun.displist(this.GroupNames) );
end
fprintf('\n');

disp@shared.CommentContainer(this, 1);
disp@shared.UserDataContainer(this, 1);
textual.looseLine( );

end%

