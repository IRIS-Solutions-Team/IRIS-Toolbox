% epstopdf  [Not a public function] Run EPSTOPDF to convert EPS graphics to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

function epstopdf(List,CmdArgs,varargin)

try
    CmdArgs; %#ok<VUNUS>
catch %#ok<CTCH>
    CmdArgs = '';
end


%(
defaults = {
    'display', false, @(x) isequal(x, true) || isequal(x, false)
};
%)


opt = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'[^,;]+','match');
    List = strtrim(List);
end

thisDir = pwd( );
epstopdf = iris.get('epstopdfpath');
if isempty(epstopdf)
    utils.error('latex:epstopdf',...
        'EPSTOPDF path unknown. Cannot convert EPS to PDF files.');
end

% Try to make sure GhostScript is on the system path on Unix/Linus/Mac.
% Otherwise, it's up to the user to export the path at the beginning of the
% Matlab executable.
changePath = false;
if isunix( )
    try %#ok<TRYNC>
        path0 = getenv('PATH');
        [~,x0] = system('which gs');
        % This is the most likely location.
        [~,x1] = system('which /usr/local/bin/gs');
        if isempty(x0) && ~isempty(x1)
            setenv('PATH',[path0,':','/usr/local/bin']);
            changePath = true;
        end
    end
end

for i = 1 : length(List)
    [fPath,fTitle,fExt] = fileparts(List{i});
    fPath = strtrim(fPath);
    if ~isempty(fPath)
        cd(fPath);
    end
    tmp = dir([fTitle,fExt]);
    tmp([tmp.isdir]) = [ ];
    for j = 1 : length(tmp)
        jFile = tmp(j).name;
        if opt.display
            fprintf('Converting \% to PDF.\n',fullfile(fPath,jFile));
        end
        command = ['"',epstopdf,'" ',jFile,' ',CmdArgs];
        system(command);
    end
    cd(thisDir);
end

% Clean up.
if changePath
    try %#ok<TRYNC>
        setenv('PATH',path0);
    end
end

end
