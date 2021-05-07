% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

function startup(varargin)

MINIMUM_MATLAB = 'R2019b';

options = locallyResolveInputOptions(varargin{:});

if options.CheckMatlab ...
        && locallyGetMatlabRelease()<locallyReleaseToNum(MINIMUM_MATLAB)
    error( ...
        "IrisToolbox:StartupError" ...
        , "Matlab %s or later is needed to run this [IrisToolbox] release" ...
        , MINIMUM_MATLAB ...
    );
end

% Reset path, remove other root folders
[root, ~, rootsRemoved] = iris.path();

% Reset default function options and configuration options
% Check [IrisToolbox] release and id file
config = iris.reset( ...
    "silent", options.Silent ...
    , "seriesConstructor", options.SeriesConstructor ...
    , "checkId", options.CheckId ...
    , "tex", options.TeX ...
);

if ~options.Silent
    hereDisplayIntro();
    hereDisplayDetails();
end

return

    function hereDisplayIntro()
        release = config.Release;
        % Intro message
        fprintf('\n');
        fprintf('\t[IrisToolbox] for Macroeconomic Modeling ');
        fprintf('Release %s', release);
        fprintf('\n');
        % Copyright
        fprintf('\tCopyright (c) 2007-%s ', datestr(now, 'YYYY'));
        fprintf('IRIS Solutions Team');
        fprintf('\n\n');
    end%
        

    function hereDisplayDetails()
        % Matlab requirements
        fprintf("\tMatlab requirements: %s or later", MINIMUM_MATLAB);
        fprintf("\n");

        % IRIS root folder
        fprintf('\tRoot folder: %s', root);
        fprintf('\n');
        
        % Default time series constructor
        defaultTimeSeriesConstructor = config.DefaultTimeSeriesConstructor;
        defaultTimeSeriesConstructor = func2str(defaultTimeSeriesConstructor);
        fprintf('\tDefault time series constructor: @%s', defaultTimeSeriesConstructor);
        fprintf('\n');
        
        % LaTeX engine
        latex = config.PdfLaTeXPath;
        if strlength(config.PdfLaTeXPath)==0
            latex = 'No PDF LaTeX engine configured';
        end
        fprintf('\tLaTeX Engine: %s', latex);
        fprintf('\n');

        % Ghostscript
        ghost = config.GhostscriptPath;
        if strlength(ghost)==0
            ghost = 'No Ghostscript engine configured';
        end
        fprintf('\tGhostscript engine: %s', ghost);
        fprintf('\n');
        
        % X12/X13 version
        fprintf('\tX13-ARIMA-SEATS: Version 1.1 Build 39 (March 10, 2017)');
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


function r = locallyGetMatlabRelease()
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
    options = struct();
    options.CheckMatlab = true;
    options.Silent = false;
    options.SeriesConstructor = @Series;
    options.CheckId = true;
    options.TeX = true;
    if nargin==0
        return
    end

    inputOptions = string(varargin);
    inputOptions = strip(erase(inputOptions, "-"));
    for n = inputOptions
        if contains(n, ["Shutup", "Silent"], "ignoreCase", true)
            options.Silent = true;
        elseif contains(n, "tseries")
            options.SeriesConstructor = @tseries;
        elseif contains(n, "Series")
            options.SeriesConstructor = @Series;
        elseif contains(n, ["NoIdChk", "NoIdCheck"], "ignoreCase", true)
            options.CheckId = false;
        elseif contains(n, "NoTex", "ignoreCase", true)
            options.TeX = false;
        elseif contains(n, "NoMatlabCheck", "ignoreCase", true)
            options.CheckMatlab = false;
        end
    end
end%

