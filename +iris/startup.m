function startup(varargin)
% iris.startup  Start IRIS session
%
% __Syntax__
%
%     iris.startup
%     iris.startup('--option')
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
% * `--Silent` - Do not print introductory message on the screen.
%
% * `--tseries` - Use the `tseries` class as the default time series class.
%
% * `--Series` - Use the `Series` class as the default time series class.
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

MATLAB_RELEASE_OR_HIGHER = 'R2016b';

%--------------------------------------------------------------------------

if getMatlabRelease( )<release2num(MATLAB_RELEASE_OR_HIGHER)
    thisError = { 'IrisToolbox:StartupError'
                  'Matlab %s or later is needed to run this [IrisToolbox] release' };
    error(thisError{1}, [thisError{2:end}], MATLAB_RELEASE_OR_HIGHER);
end

options = resolveInputOptions(varargin{:});

% Reset path, remove other root folders
[root, ~, rootsRemoved] = iris.path( );

% Reset default function options and configuration options
% Check [IrisToolbox] release and id file
config = iris.reset(options);

if ~options.Silent
    if config.DesktopStatus
        fprintfx = @(varargin) fprintf(varargin{:});       
    else
        fprintfx = @(varargin) fprintf('%s', removeTags(sprintf(varargin{:})));
    end
    hereDisplayIntro( );
    hereDisplayDetails( );
end

return


    function hereDisplayIntro( )
        release = config.Release;
        % Intro message
        fprintf('\n');
        fprintfx('\t<a href="http://www.iris-toolbox.com">[IrisToolbox] for Macroeconomic Modeling</a> ');
        fprintf('Release %s', release);
        fprintf('\n');
        % Copyright
        fprintf('\tCopyright (c) 2007-%s ', datestr(now, 'YYYY'));
        fprintfx('IRIS Solutions Team');
        fprintf('\n\n');
    end%
        



    function hereDisplayDetails( )
        % IRIS root folder
        fprintfx('\tRoot Folder: <a href="file:///%s">%s</a>\n', root, root);
        
        % Default time series constructor
        defaultTimeSeriesConstructor = config.DefaultTimeSeriesConstructor;
        defaultTimeSeriesConstructor = func2str(defaultTimeSeriesConstructor);
        fprintf('\tDefault Time Series Constructor: @%s', defaultTimeSeriesConstructor);
        fprintf('\n');
        
        % LaTeX engine
        fprintf('\tLaTeX Engine: ');
        if isempty(config.PdfLaTeXPath)
            fprintf('No PDF LaTeX engine found');
        else
            fprintfx( ...
                '<a href="file:///%s">%s</a>', ...
                fileparts(config.PdfLaTeXPath), ...
                config.PdfLaTeXPath ...
            );
        end
        fprintf('\n');

        % Ghostscript
        fprintf('\tGhostscript Engine: ');
        if isempty(config.GhostscriptPath)
            fprintf('No Ghostscript engine found');
        else
            fprintfx( ...
                '<a href="file:///%s">%s</a>', ...
                fileparts(config.GhostscriptPath), ...
                config.GhostscriptPath ...
            );
        end
        fprintf('\n');
        
        % X12/X13 version
        fprintfx('\t<a href="http://www.census.gov/srd/www/x13as/">');
        fprintfx('X13-ARIMA-SEATS</a>: ');
        fprintf('Version 1.1 Build 39 (March 10, 2017)');
        fprintf('\n');

        % IRIS folders removed
        if ~isempty(rootsRemoved)
            q = warning('query', 'backtrace');
            warning('off', 'backtrace');
            msg = 'Some other IRIS releases have been found and removed from Matlab path:';
            list = cellfun(@(x) sprintf('\n*** %s', x), rootsRemoved, 'UniformOutput', false);
            fprintf('\n');
            warning([msg, list{:}]);
            warning(q);
        end

        fprintf('\n');
    end%
end%




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
end%




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
end%




function options = resolveInputOptions(varargin)
    options = struct( );
    options.Silent = false;
    options.SeriesConstructor = @Series;
    options.CheckId = true;

    varargin = strtrim(varargin);
    varargin = strrep(varargin, '-', '');
    for i = 1 : numel(varargin)
        ithArg = varargin{i};
        if strcmpi(ithArg, 'Shutup') || strcmpi(ithArg, 'Silent')
            options.Silent = true;
        elseif strcmpi(ithArg, 'tseries')
            options.SeriesConstructor = @tseries;
        elseif strcmpi(ithArg, 'Series')
            options.SeriesConstructor = @Series;
        elseif strcmpi(ithArg, 'NoIdChk') || strcmpi(ithArg, 'NoIdCheck')
            options.CheckId = false;
        end
    end
    options.CheckId = ~any(strcmpi(varargin, '-noidchk'));
end%




function msg = removeTags(msg)
    msg = regexprep(msg, '<a[^<]*>', '');
    msg = strrep(msg, '</a>', '');
    msg = strrep(msg, '<strong>', '');
    msg = strrep(msg, '</strong>', '');
end%

