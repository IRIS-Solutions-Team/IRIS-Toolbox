function startup(varargin)
% iris.startup  Start IRIS session.
%
% __Syntax__
%
%     iris.startup
%     iris.startup --option
%
%
% __Description__
%
% We recommend that you keep the IRIS root directory on the permanent
% Matlab search path. Each time you wish to start working with IRIS, you
% run `iris.startup` form the command line. At the end of the session, you
% can run [`irisfinish`](config/irisfinish) to remove IRIS
% subfolders from the temporary Matlab search path, and to clear persistent
% variables in some of the backend functions.
%
% The [`iris.startup`](config/iris.startup) performs the following steps:
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
%
% __Options__
%
% * `--shutup` - Do not print introductory message on the screen.
%
% * `--tseries` - Use the `tseries` class as the default time series class.
%
% * `--Series` - Use the `Series` class as the default time series class.
%
% * `--TimeSeries` - Use the `TimeSeries` class as the default time series
% class.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

MATLAB_RELEASE_OR_HIGHER = 'R2014b';

%--------------------------------------------------------------------------

% Runs in Matlab R2014b and higher.
if getMatlabRelease( )<release2num(MATLAB_RELEASE_OR_HIGHER)
    error( ...
        'IRIS:Config:IrisStartup', ...
        'Matlab %s or later is needed to run this version of the IRIS Macroeconomic Modeling Toolbox', ...
        MATLAB_RELEASE_OR_HIGHER ...
        );
end

options = resolveInputOptions(varargin{:});

isIdChk = ~any(strcmpi(varargin, '-noidchk'));

if ~options.shutup
    progress = 'Starting up an IRIS session...';
    fprintf('\n');
    fprintf(progress);
end

% Get the whole IRIS folder structure. Exclude directories starting with an
% _ (on top of +, @, and private, which are excluded by default). The
% current IRIS root is always returned last in `removed`.
[reportRootsRemoved, thisRoot] = iris.pathManager('cleanup');

% Add the current IRIS folder structure to the temporary search path.
addpath(thisRoot, '-begin');
iris.pathManager('addroot', thisRoot);
iris.pathManager('addcurrentsubs', thisRoot);

try %#ok<TRYNC>
    munlock passvalopt
end
try %#ok<TRYNC>
    munlock iris.configMaster
end

setEnvironment( );

% Reset m-files with persistent variables.
munlock iris.configMaster;
munlock passvalopt;
iris.configMaster( );
iris.reset( );
icfg = iris.get( );
passvalopt( );

version = iris.get('version');
if isIdChk
    chkId( );
end

if ~options.shutup
    % Delete progress message.
    deleteProgress( );
    displayMessage( );
end

return


    function setEnvironment( )
        try
            jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            isDesktop = ~isempty(jDesktop.getClient('Command Window'));
        catch
            isDesktop = false;
        end
        setappdata(0, 'IRIS_IsDesktop', isDesktop);

        if isDesktop
            scm = char(8230);
        else
            scm = ' etc...';
        end
        setappdata(0, 'IRIS_StringContinuationMark', scm);

        if options.TimeSeries
            timeSeriesConstructor = @TimeSeries;
            dateFromSerial = @Date.fromSerial;
        elseif options.tseries
            timeSeriesConstructor = @tseries;
            dateFromSerial = @DateWrapper.fromSerial;
        else
            timeSeriesConstructor = @Series;
            dateFromSerial = @DateWrapper.fromSerial;
        end
        setappdata(0, 'IRIS_TimeSeriesConstructor', timeSeriesConstructor);
        setappdata(0, 'IRIS_DateFromSerial', dateFromSerial);
    end


    function deleteProgress( )
        if getappdata(0, 'IRIS_IsDesktop')
            progress(1:end) = sprintf('\b');
            fprintf(progress);
        else
            fprintf('\n\n');
        end
    end


    function displayMessage( )
        if getappdata(0, 'IRIS_IsDesktop')
            fprintfx = @(varargin) fprintf(varargin{:});       
        else
            fprintfx = @(varargin) fprintf('%s', textfun.removeTags(sprintf(varargin{:})));
        end
        % Intro message
        fprintfx('\t<a href="http://www.iris-toolbox.com">IRIS Macroeconomic Modeling Toolbox</a> ');
        fprintf('Release %s', version);
        fprintf('\n');
        fprintf('\tCopyright (c) 2007-%s ', datestr(now, 'YYYY'));
        fprintfx('<a href="https://code.google.com/p/iris-toolbox-project/wiki/ist">');
        fprintfx('IRIS Solutions Team</a>');
        fprintf('\n\n');
        
        % IRIS root folder
        fprintfx('\tIRIS Root: <a href="file:///%s">%s</a>\n', thisRoot, thisRoot);
        
        % User config file used
        fprintf('\tUser Config File: ');
        if isempty(icfg.userconfigpath)
            fprintfx('<a href="matlab: idoc config/irisuserconfighelp">');
            fprintfx('No user config file found</a>');
        else
            fprintfx('<a href="matlab: edit %s">%s</a>', ...
                icfg.userconfigpath, icfg.userconfigpath);
        end
        fprintf('\n');
        
        % Default Time Series constructor
        defaultTimeSeriesConstructor = getappdata(0, 'IRIS_TimeSeriesConstructor');
        defaultTimeSeriesConstructor = func2str(defaultTimeSeriesConstructor);
        fprintf('\tDefault Time Series Constructor: @%s', defaultTimeSeriesConstructor);
        fprintf('\n');
        
        % LaTeX engine
        fprintf('\tLaTeX Engine: ');
        if isempty(icfg.PdfLaTeXPath)
            fprintf('No PDF LaTeX engine found');
        else
            if true % ##### MOSW
                fprintfx( ...
                    '<a href="file:///%s">%s</a>', ...
                    fileparts(icfg.PdfLaTeXPath), ...
                    icfg.PdfLaTeXPath ...
                    );
            else
                fprintf('%s', config.PdfLaTeXPath); %#ok<UNRCH>
            end
        end
        fprintf('\n');
        
        % X12/X13 version
        fprintfx('\t<a href="http://www.census.gov/srd/www/x13as/">');
        fprintfx('X13-ARIMA-SEATS</a>: ');
        fprintf('Version 1.1 Build 39 (March 10, 2017)');
        fprintf('\n');

        % IRIS folders removed
        if ~isempty(reportRootsRemoved)
            q = warning('query', 'backtrace');
            warning('off', 'backtrace');
            msg = 'Some other IRIS versions or root folders have been found and removed from Matlab path:';
            for i = 1 : numel(reportRootsRemoved)
                msg = [msg, sprintf('\n'), '*** ', reportRootsRemoved{i}]; %#ok<AGROW>
            end
            fprintf('\n');
            warning(msg);
            warning(q);
        end
        
        fprintf('\n');
    end




    function chkId( )
        list = dir(fullfile(thisRoot, 'iristbx*'));
        if length(list)==1
            idFileVersion = regexp(list.name, '(?<=iristbx)\d+\-?\w+', 'match', 'once');
            if ~strcmp(version, idFileVersion)
                deleteProgress( );
                utils.error('config:iris:startup', ...
                    ['The IRIS version check file (%s) does not match ', ...
                    'the current version of IRIS (%s). ', ...
                    'Delete everything from the IRIS root folder, ', ...
                    'and reinstall IRIS.'], ...
                    idFileVersion, version);
            end
        elseif isempty(list)
            deleteProgress( );
            utils.error('config:iris:startup', ...
                ['The IRIS version check file is missing. ', ...
                'Delete everything from the IRIS root folder, ', ...
                'and reinstall IRIS.']);
        else
            deleteProgress( );
            utils.error('config:iris:startup', ...
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
        ixMatlab = strcmpi({s.Name}, 'MATLAB');
        if any(ixMatlab)
            s = s(find(ixMatlab, 1));
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


function options = resolveInputOptions(varargin)
    options = struct( ...
        'shutup',     false, ...
        'tseries',    false, ...
        'Series',     false, ...
        'TimeSeries', false...
    );
    for i = 1 : numel(varargin)
        ithInput = lower(strtrim(varargin{i}));
        ithInput = strrep(ithInput, '-', '');
        switch ithInput
            case 'shutup'
                options.shutup = true;
            case 'tseries'
                options.tseries = true;
                options.Series = false;
                options.TimeSeries = false;
            case 'Series'
                options.tseries = false;
                options.Series = true;
                options.TimeSeries = false;
            case 'TimeSeries'
                options.tseries = false;
                options.Series = false;
                options.TimeSeries = true;
        end
    end
    if ~options.tseries && ~options.Series && ~options.TimeSeries
        options.Series = true;
    end
end
