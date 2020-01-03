% iriscleanup  Remove IRIS from Matlab and clean up
%
% __Syntax__
%
%     iris.cleanup
%
%
% __Description__
%
% This script removes IRIS folders, including the root folder, from both
% the Matlab search path, and clears persistent variables in some of the
% backend functions. A short message is displayed with the list of folders
% removed from the path.
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

% Clean up appdata(0) and persistent workspaces
iris.cleanupPersistent( )

% Remove IRIS from the permanent Matlab search path
[reportRootsRemoved, thisRoot] = iris.pathManager('cleanup');
reportRootsRemoved = [reportRootsRemoved, thisRoot];

% Display report on paths removed.
if ~isempty(reportRootsRemoved)
    fprintf('\n\tThe following IRIS roots have been removed from the Matlab search path:\n');
    for i = 1 : numel(reportRootsRemoved)
        fprintf('\t* %s\n',reportRootsRemoved{i});
    end
    fprintf('\n');
end

