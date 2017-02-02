% iriscleanup  Remove IRIS from Matlab and clean up.
%
% Syntax
% =======
%
%     iriscleanup
%
% Description
% ============
%
% This script removes IRIS folders, including the root folder, from both
% the Matlab search path, and clears persistent variables in some of the
% backend functions. A short message is displayed with the list of folders
% removed from the path.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Clear container.
try %#ok<TRYNC>
    clear(container( ));
end

% Clear persistent variables in |model/mysstatenonlin|.
clear model/mysstatenonlin;

% Clear optional input argument struct.
munlock passvalopt;
clear passvalopt;

% Clear iris config master file.
munlock irisconfigmaster;
clear irisconfigmaster;

% Remove IRIS from the permanent Matlab search path.
removed = irispathmanager('cleanup');

% Display report on paths removed.
if ~isempty(removed)
    fprintf('\n\tThe following IRIS roots have been removed from the Matlab search path:\n');
    for i = 1 : numel(removed)
        fprintf('\t* %s\n',removed{i});
    end
    fprintf('\n');
end
