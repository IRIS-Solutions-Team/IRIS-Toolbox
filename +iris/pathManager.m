% irispathManager  [IrisToolbox] path manager
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = pathManager(req, root, options)

if strcmpi(req, 'cleanUp')
    % Remove all IRIS roots and subs found on the Matlab temporary
    % and permanent search paths.
    currentFolder = pwd( );
    folderOfThisFile = fileparts(mfilename('fullpath'));
    cd(fullfile(folderOfThisFile, '..'));
    root = pwd();
    cd(currentFolder);

    listRoots = unique([
        which('irisstartup.m', '-all')
        which('irisping.m', '-all')
    ]);

    reportRootsRemoved = { };
    for i = 1 : numel(listRoots)
        ithRoot = fileparts(listRoots{i});
        allp = local_generatePath(ithRoot);
        local_removePath(allp{:}, ithRoot);
        if ~strcmpi(ithRoot, root)
            reportRootsRemoved{end+1} = ithRoot; %#ok<AGROW>
        end
    end
    varargout = cell(1, 2);
    varargout{1} = reportRootsRemoved;
    varargout{2} = root;
    rehash path;


elseif strcmpi(req, 'addRoot')
    % Add the specified root to the temporary search paths.
    addpath(root, '-begin');


elseif strcmpi(req, 'addCurrentSubs')
    % Add subfolders within the current root to the temporary
    % search path.
    allp = local_generatePath(root);
    if ~options.NumericDailyDates
        allp{end+1} = fullfile(root, 'dates', 'DaterConstructors');
    else
        allp{end+1} = fullfile(root, 'dates', 'NumericConstructors');
    end
    addpath(allp{:}, '-begin');
    varargout{1} = allp;


elseif strcmpi(req, 'removeCurrentSubs');
    % Remove subfolders within the current root from the temporary
    % and permanent search paths.
    allp = local_generatePath(root);
    local_removePath(allp{:});
    varargout{1} = allp;

end

end%

%
% Local functions
%

function local_removePath(varargin)
    if isempty(varargin)
        return
    end
    status = warning('query', 'all');
    warning('off', 'MATLAB:rmpath:DirNotFound');
    rmpath(varargin{:});
    warning(status);
end%


function allp = local_generatePath(root)
    %(
    % All first-level folders in IrisT root
    list = dir(root);
    list = list([list.isdir]);

    allp = {};
    for i = 1 : numel(list)
        name = list(i).name;
        % Exclude folders starting with special characters
        if startsWith(string(name), ["+", ".", "*", "@", "-", "#"])
            continue
        end
        allp{end+1} = fullfile(root, char(name));
    end
    %)
end%

