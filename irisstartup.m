function irisstartup(varargin)
% irisstartup  Start an IRIS session.
%
% Syntax
% =======
%
%     irisstartup
%     irisstartup -shutup
%
% Description
% ============
%
% We recommend that you keep the IRIS root directory on the permanent
% Matlab search path. Each time you wish to start working with IRIS, you
% run `irisstartup` form the command line. At the end of the session, you
% can run [`irisfinish`](config/irisfinish) to remove IRIS
% subfolders from the temporary Matlab search path, and to clear persistent
% variables in some of the backend functions.
%
% The [`irisstartup`](config/irisstartup) performs the following steps:
%
% * Adds necessary IRIS subdirectories to the temporary Matlab search
% path.
%
% * Removes redundant IRIS folders (e.g. other or older installations) from
% the Matlab search path.
%
% * Resets IRIS configuration options to default, updates the location of
% TeX/LaTeX executables, and calls
% [`irisuserconfig`](config/irisuserconfighelp) to modify the configuration
% option.
%
% * Associates the default IRIS extensions with the Matlab Editor. If they
% had not been associated before, Matlab must be re-started for the
% association to take effect.
%
% * Prints an introductory message on the screen unless `irisstartup` is
% called with the `-shutup` input argument.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

MATLAB_RELEASE_OR_HIGHER = 'R2014b';

%--------------------------------------------------------------------------

% Runs in Matlab R2014b and higher.
if true % ##### MOSW
    if getMatlabRelease( )<release2num(MATLAB_RELEASE_OR_HIGHER)
        error( ...
            'IRIS:Config:IrisStartup',...
            'Sorry, Matlab <strong>%s</strong> or later is needed to run this version of the <a href="http://www.iris-toolbox.com">IRIS Macroeconomic Modeling Toolbox</a>.', ...
            MATLAB_RELEASE_OR_HIGHER ...
            );
    end
else
    % Do nothing.
end

shutup = any(strcmpi(varargin,'-shutup'));
isIdChk = ~any(strcmpi(varargin,'-noidchk'));

if ~shutup
    progress = 'Starting up an IRIS session...';
    fprintf('\n');
    fprintf(progress);
end

% Get the whole IRIS folder structure. Exclude directories starting with an
% _ (on top of +, @, and private, which are excluded by default). The
% current IRIS root is always returned last in `removed`.
lsRemoved = irispathmanager('cleanup');
root = lsRemoved{end};
lsRemoved(end) = [ ];

% Add the current IRIS folder structure to the temporary search path.
addpath(root, '-begin');
irispathmanager('addroot', root);
irispathmanager('addcurrentsubs');

% Reset default options in `passvalopt`.
try %#ok<TRYNC>
    munlock('passvalopt');
end
try %#ok<TRYNC>
    munlock('irisconfigmaster');
end

% Reset m-files with persistent variables.
munlock irisconfigmaster;
munlock passvalopt;
irisconfigmaster( );
irisreset(varargin{:});
icfg = irisget( );
passvalopt( );

version = irisget('version');
if isIdChk
    chkId( );
end

if ~shutup
    % Delete progress message.
    deleteProgress( );
    displayMessage( );
end

return




    function deleteProgress( )
        progress(1:end) = sprintf('\b');
        fprintf(progress);
    end




    function displayMessage( )
        % Intro message.
        mosw.fprintf('\t<a href="http://www.iris-toolbox.com">IRIS Macroeconomic Modeling Toolbox</a> ');
        fprintf('Release %s.',version);
        fprintf('\n');
        fprintf('\tCopyright (c) 2007-%s ',datestr(now,'YYYY'));
        mosw.fprintf('<a href="https://code.google.com/p/iris-toolbox-project/wiki/ist">');
        mosw.fprintf('IRIS Solutions Team</a>.');
        fprintf('\n\n');
        
        % IRIS root folder.
        mosw.fprintf('\tIRIS root: <a href="file:///%s">%s</a>.\n',root,root);
        
        % Report user config file used.
        fprintf('\tUser config file: ');
        if isempty(icfg.userconfigpath)
            mosw.fprintf('<a href="matlab: idoc config/irisuserconfighelp">');
            mosw.fprintf('No user config file found</a>.');
        else
            mosw.fprintf('<a href="matlab: edit %s">%s</a>.', ...
                icfg.userconfigpath,icfg.userconfigpath);
        end
        fprintf('\n');
        
        % LaTeX engine.
        fprintf('\tLaTeX engine: ');
        if isempty(icfg.PdfLaTeXPath)
            fprintf('No PDF LaTeX engine found.');
        else
            if true % ##### MOSW
                fprintf( ...
                    '<a href="file:///%s">%s</a>.', ...
                    fileparts(icfg.PdfLaTeXPath), ...
                    icfg.PdfLaTeXPath ...
                    );
            else
                fprintf('%s.',config.PdfLaTeXPath); %#ok<UNRCH>
            end
        end
        fprintf('\n');
        
        % Report the X12 version integrated with IRIS.
        mosw.fprintf('\t<a href="http://www.census.gov/srd/www/x13as/">');
        mosw.fprintf('X13-ARIMA-SEATS</a>: ');
        fprintf('Version 1.1 Build 19 (April 2, 2015).');
        fprintf('\n');
        
        % Report IRIS folders removed.
        if ~isempty(lsRemoved)
            q = warning('query', 'backtrace');
            warning('off', 'backtrace');
            msg = 'Some other IRIS versions or root folders have been found and removed from Matlab path:';
            for i = 1 : numel(lsRemoved)
                msg = [msg, sprintf('\n'), '*** ', lsRemoved{i}]; %#ok<AGROW>
            end
            fprintf('\n');
            warning(msg);
            warning(q);
        end
        
        fprintf('\n');
    end




    function chkId( )
        list = dir(fullfile(root,'iristbx*'));
        if length(list) == 1
            idFileVersion = strrep(list.name,'iristbx','');
            if ~strcmp(version,idFileVersion)
                deleteProgress( );
                utils.error('config:irisstartup', ...
                    ['The IRIS version check file (%s) does not match ', ...
                    'the current version of IRIS (%s). ', ...
                    'Delete everything from the IRIS root folder, ', ...
                    'and reinstall IRIS.'], ...
                    idFileVersion,version);
            end
        elseif isempty(list)
            deleteProgress( );
            utils.error('config:irisstartup', ...
                ['The IRIS version check file is missing. ', ...
                'Delete everything from the IRIS root folder, ', ...
                'and reinstall IRIS.']);
        else
            deleteProgress( );
            utils.error('config:irisstartup', ...
                ['There are mutliple IRIS version check files ', ...
                'found in the IRIS root folder. This is because ', ...
                'you installed a new IRIS in a folder with an old ', ...
                'version, without deleting the old version first. ', ...
                'Delete everything from the IRIS root folder, ', ...
                'and reinstall IRIS.']);
        end
    end
end




function r = getMatlabRelease( )
r = uint16(0);
try %#ok<TRYNC>
    s = ver('MATLAB');
    ixMatlab = strcmpi({s.Name},'MATLAB');
    if any(ixMatlab)
        s = s(find(ixMatlab,1));
        r = regexp(s.Release, 'R\d{4}[ab]', 'match', 'once');
        if ~isempty(r)
            r = release2num(r);
        end
    end
end
end




function n = release2num(r)
n = uint16(0);
r = lower(r);
if length(r)~=6 || r(1)~='r' || ~any(r(6)=='ab')
    return
end
year = sscanf(r(2:5), '%i', 1);
if length(year)~=1
    return
end
ab = 1 + double(r(6)) - double('a');
n = uint16(10*year + ab);
end
