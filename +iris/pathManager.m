function varargout = pathManager(req, varargin)
% irispathManager  IRIS path manager
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if strcmpi(req, 'CleanUp')
    % Remove all IRIS roots and subs found on the Matlab temporary
    % and permanent search paths.
    currentFolder = pwd( );
    folderOfThisFile = fileparts(mfilename('fullpath'));
    cd(fullfile(folderOfThisFile, '..'));
    thisRoot = pwd( );
    cd(currentFolder);

    listOfRoots = [ which('irisstartup.m', '-all')
                    which('irisping.m', '-all') ];
    listOfRoots = unique(listOfRoots);

    reportRootsRemoved = { };
    for i = 1 : numel(listOfRoots)
        ithRoot = fileparts(listOfRoots{i});
        [~, allp] = generatePath(ithRoot);
        removePath(allp{:}, ithRoot);
        if ~strcmpi(ithRoot, thisRoot)
            reportRootsRemoved{end+1} = ithRoot; %#ok<AGROW>
        end
    end
    varargout = cell(1, 2);
    varargout{1} = reportRootsRemoved;
    varargout{2} = thisRoot;
    
elseif strcmpi(req, 'AddRoot')
    % Add the specified root to the temporary search paths.
    thisRoot = varargin{1};
    addpath(thisRoot, '-begin');
    
elseif strcmpi(req, 'AddCurrentSubs')
    % Add subfolders within the current root to the temporary
    % search path.
    thisRoot = varargin{1};
    [p, allp] = generatePath(thisRoot);
    if ~isempty(p.Begin)
        addpath(p.Begin{:}, '-begin');
    end
    if ~isempty(p.End)
        addpath(p.End{:}, '-end');
    end
    varargout{1} = allp;
        
elseif strcmpi(req, 'RemoveCurrentSubs');
    % Remove subfolders within the current root from the temporary
    % and permanent search paths.
    thisRoot = varargin{1};
    [~, allp] = generatePath(thisRoot);
    removePath(allp{:});
    varargout{1} = allp;

end

end%


%
% Local Functions
%


function removePath(varargin)
    if isempty(varargin)
        return
    end
    status = warning('query', 'all');
    warning('off', 'MATLAB:rmpath:DirNotFound');
    rmpath(varargin{:});
    warning(status);
end%




function [ppath, everything] = generatePath(root)
    try
        root; %#ok<VUNUS>
    catch
        root = irisroot( );
    end

    % All first-level folders in IRIS root.
    list = dir(root);
    list = list([list.isdir]);

    ppath = struct( );
    ppath.Begin = { }; % addpath -begin.
    ppath.End = { }; % addpath -end.
    ppath.OctBegin = { }; % addpath -begin in Octave.
    ppath.OctEnd = { }; % addpath -end in Octave.

    for i = 1 : numel(list)
        name = list(i).name;
        % Exclude folders starting with special characters + @ - $.
        if strncmp(name, '.', 1) ...
                || strncmp(name, '+', 1) ...
                || strncmp(name, '@', 1) ...
                || strncmp(name, '-', 1) ...
                || strncmp(name, '#', 1)
            continue
        end

        if ~isempty(strfind(name, 'resources'))
            continue
        end

        if strcmp(name, 'octave')
            ppath.OctBegin{end+1} = fullfile(root, name);
            continue
        end
        if strcmp(name, '_octave')
            ppath.OctEnd{end+1} = fullfile(root, name);
            continue
        end
        if strncmp(name, '_', 1)
            ppath.End{end+1} = fullfile(root, name);
        end
        ppath.Begin{end+1} = fullfile(root, name);
    end

    everything = [ppath.OctBegin, ppath.Begin, ppath.End, ppath.OctEnd];
end%

