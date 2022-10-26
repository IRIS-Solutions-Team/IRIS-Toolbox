% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function startup(varargin)

% >=R2019b
%{
MINIMUM_MATLAB = 'R2019b';
%}
% >=R2019b


% <=R2019a
%(
MINIMUM_MATLAB = 'R2018a';
%)
% <=R2019a


    options = local_resolveInputOptions(varargin{:});

    matlabRelease = local_getMatlabRelease();
    if options.CheckMatlab && string(matlabRelease)<string(MINIMUM_MATLAB)
        error( ...
            "IrisToolbox:StartupError" ...
            , "Matlab %s or later is needed to run this Iris Toolbox release" ...
            , MINIMUM_MATLAB ...
        );
    end

    % Reset path, remove other root folders
    [root, ~, rootsRemoved] = iris.path(options);

    % Reset default function options and configuration options
    % Check [IrisToolbox] release and id file
    config = iris.reset( ...
        "silent", options.Silent ...
        , "checkId", options.CheckId ...
        , "tex", options.TeX ...
    );

    if ~options.Silent
        here_displayIntro();
        here_displayDetails();
    end

return

    function here_displayIntro()
        %(
        release = config.Release;
        fprintf('\n\t[IrisToolbox] for Macroeconomic Modeling Release %s', release);
        fprintf('\n\tCopyright (c) 2007-%s [IrisToolbox] Solutions Team', datestr(now, 'YYYY'));
        fprintf('\n\n');
        %)
    end%


    function here_displayDetails()
        %(
        % Matlab requirements
        fprintf("\tMatlab requirements: %s or later", MINIMUM_MATLAB);
        fprintf("\n");

        % IrisT root folder
        fprintf('\tRoot folder: %s', root);
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

        % IrisT folders removed
        if ~isempty(rootsRemoved)
            q = warning('query', 'backtrace');
            warning('off', 'backtrace');
            msg = 'Some other [IrisToolbox] releases have been found and removed from Matlab path:';
            list = cellfun(@(x) sprintf('\n*** %s', x), rootsRemoved, 'UniformOutput', false);
            fprintf('\n');
            warning([msg, list{:}]);
            warning(q);
        end

        fprintf('\n');
        %)
    end%
end%


function r = local_getMatlabRelease()
    %(
    r = uint16(0);
    try %#ok<TRYNC>
        s = ver('MATLAB');
        ixMatlab = strcmpi({s.Name}, 'MATLAB');
        if any(ixMatlab)
            s = s(find(ixMatlab, 1));
            r = regexp(s.Release, 'R\d{4}[ab]', 'match', 'once');
        end
    end
    %)
end%


function options = local_resolveInputOptions(varargin)
    %(
    options = struct();
    options.CheckMatlab = true;
    options.Silent = false;
    options.CheckId = true;
    options.TeX = true;
    options.LegacyWarning = true;
    options.NumericDailyDates = false;
    if nargin==0
        return
    end

    inputOptions = string(varargin);
    inputOptions = strip(erase(inputOptions, ["-", "_"]));
    for n = inputOptions
        if contains(n, ["shutup", "silent"], "ignoreCase", true)
            options.Silent = true;
        elseif contains(n, ["noIdChk", "noIdCheck"], "ignoreCase", true)
            options.CheckId = false;
        elseif contains(n, "noTex", "ignoreCase", true)
            options.TeX = false;
        elseif contains(n, "noMatlabCheck", "ignoreCase", true)
            options.CheckMatlab = false;
        elseif contains(n, "noLegacyWarning", "ignoreCase", true)
            options.LegacyWarning = false;
        elseif contains(n, "numericDailyDates", "ignoreCase", true)
            options.NumericDailyDates = true;
        end
    end
    %)
end%

