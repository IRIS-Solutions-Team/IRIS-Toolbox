
% Clean up appdata(0) and persistent workspaces
iris.cleanupPersistent();

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

