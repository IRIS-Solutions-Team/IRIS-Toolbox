function [Path,All] = irisgenpath(Root)
% irisgenpath  [Not a public function] Generate IRIS folder names that need to be added on Matlab search path.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Root; %#ok<VUNUS>
catch
    Root = irisroot( );
end

%--------------------------------------------------------------------------

% All first-level folders in IRIS root.
list = dir(Root);
list = list([list.isdir]);

Path = struct( );
Path.Begin = { }; % addpath -begin.
Path.End = { }; % addpath -end.
Path.OctBegin = { }; % addpath -begin in Octave.
Path.OctEnd = { }; % addpath -end in Octave.

for i = 1 : length(list)
    name = list(i).name;
    % Exclude folders starting with special characters + @ - ^.
    if strncmp(name,'.',1) ...
            || strncmp(name,'+',1) ...
            || strncmp(name,'@',1) ...
            || strncmp(name,'-',1) ...
            || strncmp(name,'^',1) ...
        continue
    end
    if strcmp(name,'octave')
        Path.OctBegin{end+1} = fullfile(Root,name);
        continue
    end
    if strcmp(name,'_octave')
        Path.OctEnd{end+1} = fullfile(Root,name);
        continue
    end
    if strncmp(name,'_',1)
        Path.End{end+1} = fullfile(Root,name);
    end
    Path.Begin{end+1} = fullfile(Root,name);
end

All = [Path.OctBegin,Path.Begin,Path.End,Path.OctEnd];

end
