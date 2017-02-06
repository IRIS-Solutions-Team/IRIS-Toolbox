function [ppath, everything] = irisgenpath(root)
% irisgenpath  Generate IRIS folder names that need to be added on Matlab search path.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    root; %#ok<VUNUS>
catch
    root = irisroot( );
end

%--------------------------------------------------------------------------

% All first-level folders in IRIS root.
list = dir(root);
list = list([list.isdir]);

ppath = struct( );
ppath.Begin = { }; % addpath -begin.
ppath.End = { }; % addpath -end.
ppath.OctBegin = { }; % addpath -begin in Octave.
ppath.OctEnd = { }; % addpath -end in Octave.

for i = 1 : length(list)
    name = list(i).name;
    % Exclude folders starting with special characters + @ - $.
    if strncmp(name, '.', 1) ...
            || strncmp(name, '+', 1) ...
            || strncmp(name, '@', 1) ...
            || strncmp(name, '-', 1) ...
            || strncmp(name, '#', 1)
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

end
