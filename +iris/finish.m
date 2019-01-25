function finish(varargin)
% iris.finish  Close the current IRIS session
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

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

shutup = any(strcmpi(varargin, '--shutup'));

%--------------------------------------------------------------------------

irisRoot = iris.get('IRISRoot');

% Clear appdata(0) and container
iris.cleanupPersistent( )

% Clear Matlab path
reportSubfoldersRemoved = iris.pathManager('removeCurrentSubs', irisRoot);

if shutup
   return
end

% Display report on subfolders removed.
if ~isempty(reportSubfoldersRemoved)
   fprintf('\n\tThese IRIS subfolders have been removed from Matlab path:');
   fprintf('\n\t* %s', reportSubfoldersRemoved{:});
   fprintf('\n\n');
end

end%
