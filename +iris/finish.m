function finish(varargin)
% iris.finish  Close the current IRIS session.
%
% __Syntax__
%
%     iris.finish
%     iris.finish -shutup
%
%
% __Description__
%
% This function removes all IRIS subfolders from the temporary Matlab
% search path, and clears persistent variables in some of the backend
% functions. A short message is displayed with the list of subfolders
% removed from the path unless you call use the option `-shutup`.  The IRIS
% root folder stays on the permanent Matlab path.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

thisRoot = iris.configMaster('get', 'irisroot');
shutup = any(strcmpi(varargin, '--shutup'));

% Clear container.
try %#ok<TRYNC>
   clear(container( ));
end

% Clear optional input argument struct.
munlock passvalopt;
clear passvalopt;

% Clear iris config master file.
munlock iris.configMaster;
clear iris.configMaster;

% Clear Matlab path.
reportSubfoldersRemoved = iris.pathManager('removeCurrentSubs', thisRoot);

if shutup
   return
end

% Display report on subfolders removed.
if ~isempty(reportSubfoldersRemoved)
   fprintf('\n\tThese IRIS subfolders have been removed from Matlab path:');
   fprintf('\n\t* %s', reportSubfoldersRemoved{:});
   fprintf('\n\n');
end

end
