% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function finish(varargin)

    shutup = any(strcmpi(varargin, '--shutup'));

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
