% iris.startup  Start an [IrisToolbox] session
%{
% Syntax
%--------------------------------------------------------------------------
%
%     iris.startup
%     iris.startup('--option')
%
%
% Description
%--------------------------------------------------------------------------
%
% We recommend that you keep the IRIS root directory on the permanent
% Matlab search path. Each time you wish to start working with IRIS, you
% run `iris.startup` form the command line. At the end of the session, you
% can run [`iris.finish`](config/irisfinish) to remove IRIS
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
% * Resets IRIS configuration options to default and updates the location
% of TeX/LaTeX executables.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`silent`__ 
%
%>    Do not print introductory message on the screen.
%
%
% __`tseries`__ 
%
%>    Use the old `tseries` class as the default time series class.
%
%
% __`Series`__
%
%>    Use the regular `Series` class as the default time series class (this
%>    is the default behavior and does not need to be explicitly stated).
%
%
% __`noIdCheck`__
%
%>    Do not verify the IrisT release check file
%
%
% __`noTeX`__
%
%>    Do not try to look up TeX executables
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function startup(varargin)

MINIMUM_MATLAB = 'R2016b';

%--------------------------------------------------------------------------

if locallyGetMatlabRelease( )<locallyReleaseToNum(MINIMUM_MATLAB)
    error( ...
        "IrisToolbox:StartupError" ...
        , "Matlab %s or later is needed to run this [IrisToolbox] release" ...
        , MINIMUM_MATLAB ...
    );
end

options = locallyResolveInputOptions(varargin{:});

% Reset path, remove other root folders
[root, ~, rootsRemoved] = iris.path( );

% Reset default function options and configuration options
% Check [IrisToolbox] release and id file
config = iris.reset(options);

if ~options.Silent
    if config.DesktopStatus
        fprintfx = @(varargin) fprintf(varargin{:});       
    else
        fprintfx = @(varargin) fprintf('%s', locallyRemoveTags(sprintf(varargin{:})));
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
            fprintf('No PDF LaTeX engine configured');
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
            fprintf('No Ghostscript engine configured');
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


function r = locallyGetMatlabRelease( )
    r = uint16(0);
    try %#ok<TRYNC>
        s = ver('MATLAB');
        ixMatlab = strcmpi({s.Name}, 'MATLAB');
        if any(ixMatlab)
            s = s(find(ixMatlab, 1));
            r = regexp(s.Release, 'R\d{4}[ab]', 'match', 'once');
            if ~isempty(r)
                r = locallyReleaseToNum(r);
            end
        end
    end
end%


function n = locallyReleaseToNum(r)
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


function options = locallyResolveInputOptions(varargin)
    options = struct( );
    options.Silent = false;
    options.SeriesConstructor = @Series;
    options.CheckId = true;
    options.TeX = true;
    if nargin==0
        return
    end

    inputOptions = cellfun(@string, varargin);
    inputOptions = strip(erase(inputOptions, "-"));
    for n = inputOptions
        if matches(n, ["Shutup", "Silent"], "ignoreCase", true)
            options.Silent = true;
        elseif matches(n, "tseries", "ignoreCase", true);
            options.SeriesConstructor = @tseries;
        elseif matches(n, "Series", "ignoreCase", true);
            options.SeriesConstructor = @Series;
        elseif matches(n, ["NoIdChk", "NoIdCheck"], "ignoreCase", true)
            options.CheckId = false;
        elseif matches(n, ["NoTex"], "ignoreCase", true)
            options.TeX = false;
        end
    end
end%


function msg = locallyRemoveTags(msg)
    msg = regexprep(msg, '<a[^<]*>', '');
    msg = strrep(msg, '</a>', '');
    msg = strrep(msg, '<strong>', '');
    msg = strrep(msg, '</strong>', '');
end%

