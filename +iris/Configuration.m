classdef (CaseInsensitiveProperties=true) Configuration

    properties (Constant)
        Months = { 
            'January'
            'February'
            'March'
            'April'
            'May'
            'June'
            'July'
            'August'
            'September'
            'October'
            'November'
            'December' 
        }

        ConversionMonth (1, 1) double = 1

        ConversionDay (1, 1) double = 1

        WDay = 'Thu'
    end


    properties (SetAccess=protected)
        % IrisRoot  IrisToolbox root folder (not customizable)
        IrisRoot = iris.Configuration.getIrisRoot()

        % Release  IrisToolbox release (not customizable)
        Release = iris.Configuration.getIrisRelease()
    end


    properties
        %(
        % DateFormat  Default date format
        DateFormat = iris.Configuration.DEFAULT_DATE_FORMAT

        % FreqLetters  Default frequency letters
        FreqLetters = struct( ...
            'ii', "I", ...
            'yy', "Y", ...
            'hh', "H", ...
            'qq', "Q", ...
            'mm', "M", ...
            'ww', "W", ...
            'dd', "D" ...
        )

        % PlotDateFormat  Default date format in legacy tseries
        PlotDateFormat = iris.Configuration.DEFAULT_PLOT_DATE_FORMAT

        % PlotDateTimeFormat
        PlotDateTimeFormat = iris.Configuration.DEFAULT_PLOT_DATETIME_FORMAT

        % BaseYear  Base year for linear trends
        BaseYear = iris.Configuration.DEFAULT_BASE_YEAR

        % DispIndent  Indentation at the beginning of class display
        DispIndent = iris.Configuration.DEFAULT_DISP_INDENT

        % X13Path  Path to the X13 executable
        X13Path = @auto

        % PdfLatexPath  Path to the PDFLATEX executable
        PdfLatexPath = [ ]

        % EpsToPdfpath  Path to the EPSTOPDF executable
        EpsToPdfPath = [ ]

        % PsToPdfPath  Path to the PSTOPDF executable
        PsToPdfPath = [ ]

        % GhostscriptPath  Path to the GS executable
        GhostscriptPath = [ ]
        %)
    end


    properties (Dependent)
        Version
    end


    properties (Dependent)
        ConvertPsToPdf
    end


    properties (Constant, Hidden)
        %(
        DEFAULT_DATE_FORMAT = struct( 'ii', 'P', ...
                                      'yy', 'YF', ...
                                      'hh', 'YFP', ...
                                      'qq', 'YFP', ...
                                      'mm', 'YFP', ...
                                      'ww', 'YFP', ...
                                      'dd', '$YYYY-Mmm-DD' )

        DEFAULT_PLOT_DATE_FORMAT = struct( 'ii','P', ...
                                           'yy', 'Y', ...
                                           'hh', 'Y:P', ...
                                           'qq', 'Y:P', ...
                                           'mm', 'Y:P', ...
                                           'ww', 'Y:P', ...
                                           'dd', '$YYYY-Mmm-DD' )

        DEFAULT_PLOT_DATETIME_FORMAT = struct( 'INTEGER', '', ...
                                               'YEARLY', 'uuuu''Y''', ...
                                               'HALFYEARLY', 'uuuu''M''MM', ...
                                               'QUARTERLY', 'uuuu:Q', ...
                                               'MONTHLY', 'uuuu:MM', ...
                                               'WEEKLY', 'uuuu-MM-dd', ...
                                               'DAILY', 'uuuu-MM-dd' )

        DEFAULT_BASE_YEAR = 2020

        DEFAULT_DISP_INDENT = '    '

        DATE_FORMAT_STRUCT_FIELDS = { 'ii'
                                      'yy'
                                      'hh'
                                      'qq'
                                      'mm'
                                      'ww'
                                      'dd' }

        CONFIGURATION_MAT_FILE_NAME = 'Configuration.mat'

        APPDATA_FIELD_NAME = 'IRIS_Configuration'
        %)
    end


    methods function this = Configuration(varargin)
            if nargin==0
                return
            end

            if ~isempty(varargin) && isa(varargin{1}, 'struct') ...
                && (isfield(varargin{1}, "TeX") && isequal(varargin{1}.TeX, true))
                paths = iris.Configuration.findTexFiles();
                [this.PdfLatexPath, this.EpsToPdfPath, this.PsToPdfPath] = paths{:};
                this.GhostscriptPath = iris.Configuration.findGhostscript();
            end
        end%


        function save(this)
            setappdata(0, this.APPDATA_FIELD_NAME, this);
        end%
    end


    methods (Static)
        function this = load()
            try
                this = getappdata(0, iris.Configuration.APPDATA_FIELD_NAME);
            catch
                warning("IrisT:Configuration", "Cannot load iris.Configuration from app data");
                this = [];
            end
            if ~isa(this, 'iris.Configuration')
                this = iris.reset("silent", true, "checkId", false, "tex", false);
            end
        end%


        function clear()
            try
                rmappdata(0, iris.Configuration.APPDATA_FIELD_NAME);
            end
        end%
    end


    methods
        function this = set.DateFormat(this, newValue)
            try
                flag = iris.Configuration.validateDateFormat(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: DateFormat' );
            end
            this.DateFormat = newValue;
        end%


        function this = set.PlotDateFormat(this, newValue)
            try
                flag = iris.Configuration.validatePlotDateFormat(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: PlotDateFormat' );
            end
            this.PlotDateFormat = newValue;
        end%


        function this = set.FreqLetters(this, x)
            try
                flag = iris.Configuration.validateFreqLetters(x);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this IrisT configuration option is invalid: FreqLetters' );
            end
            this.FreqLetters = x;
        end%


        function this = set.BaseYear(this, newValue)
            try
                flag = iris.Configuration.validateBaseYear(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: BaseYear' );
            end
            this.BaseYear = newValue;
        end%


        function this = set.X13Path(this, value)
            try
                if iris.Configuration.validateX13Path(value)
                    this.X13Path = string(value);
                    return
                end
            end
            error( ...
                "IrisToolbox:ConfigurationOptionFailedValidation" ...
                , "Value being assigned to this [IrisToolbox] configuration option is invalid: PdfLatexPath" ...
            );
        end%


        function value = get.X13Path(this)
            if isequal(this.X13Path, @auto) || strlength(this.X13Path)==0
                value = string(fullfile(iris.root(), "+thirdparty", "x13"));
            else
                value = string(this.X13Path);
            end
        end%


        function this = set.PdfLatexPath(this, newValue)
            try
                if iris.Configuration.validatePdfLatexPath(newValue)
                    this.PdfLatexPath = newValue;
                    return
                end
            end
            error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                   'Value being assigned to this [IrisToolbox] configuration option is invalid: PdfLatexPath' );
        end%


        function this = set.EpsToPdfPath(this, newValue)
            try
                flag = iris.Configuration.validateEpsToPdfPath(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: EpsToPdfPath' );
            end
            this.EpsToPdfPath = newValue;
        end%


        function value = get.Version(this)
            value = this.Release;
        end%


        function conversionFunction = get.ConvertPsToPdf(this)
            if ~isempty(this.PsToPdfPath)
                pstopdfPath = this.PsToPdfPath;
                conversionFunction = @pstopdf;
            elseif ~isempty(this.GhostscriptPath)
                ghostscriptPath = this.GhostscriptPath;
                conversionFunction = @gs;
            else
                conversionFunction = [ ];
            end

            return

                function pstopdf(inputFile, outputFile)
                    command = sprintf( '"%s" "%s" -o "%s"', ...
                                       char(pstopdfPath), ...
                                       char(inputFile), ...
                                       char(outputFile) );
                    system(command);
                end%

                function gs(inputFile, outputFile)
                    command = sprintf('"%s" -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="%s" -f "%s"', ...
                                       char(ghostscriptPath), ...
                                       char(outputFile), ...
                                       char(inputFile) );
                    system(command);
                end%
        end%
    end


    methods (Static)
        function paths = findTexFiles()
            [pdfLatexPath, folder] = iris.Configuration.findTexMf('pdflatex');
            epstopdfPath = iris.Configuration.findPath(folder, 'epstopdf');
            pstopdfPath = iris.Configuration.findPath(folder, 'pstopdf');
            paths = {pdfLatexPath, epstopdfPath, pstopdfPath};
        end%


        function [path, folder] = findTexMf(file)
            path = '';
            folder = '';
            try
                if ispc()
                    % __Windows__
                    [flag, path] = system(['findtexmf ', file, '.exe']);
                    if flag~=0
                        [flag, path] = system(['findtexmf --file-type=exe ', file]);
                    end
                    if flag==0
                        path = strtrim(path);
                        lastEOL = find(path==char(10) | path==char(13), 1, 'last');
                        if ~isempty(lastEOL)
                            path = path(lastEOL+1:end);
                        end
                    end
                else
                    % __Unix, macOS__
                    tryThese = { '/Library/TeX/texbin', '/usr/texbin', '/usr/local/bin' };
                    flag = NaN;
                    for i = 1 : numel(tryThese)
                        [flag, path] = iris.Configuration.tryFolder(tryThese{i}, file);
                        if flag==0
                            break
                        end
                    end
                    if flag~=0
                        [flag, path] = system(['which ', file]);
                    end
                end
                if flag==0
                    % Use the correctly spelled path and the right file separators
                    path = strtrim(path);
                    [folder, ttl, ext] = fileparts(path);
                    path = fullfile(folder, [ttl, ext]);
                else
                    path = '';
                    folder = '';
                end
            end
        end%


        function [flag, path] = tryFolder(folder, file)
            x = dir(fullfile(folder, file));
            if length(x)==1
                flag = 0;
                path = fullfile(folder, file);
            else
                flag = -1;
                path = '';
            end
        end%


        function fPath = findPath(folder, whatToFind)
            if ispc()
                list = dir(fullfile(folder, [whatToFind, '.exe']));
            else
                list = dir(fullfile(folder, whatToFind));
            end
            if length(list)==1
                fPath = fullfile(folder, list.name);
            else
                fPath = iris.Configuration.findTexMf(whatToFind);
            end
        end%


        function ghostscriptPath = findGhostscript()
            ghostscriptPath = '';
            try
                if ispc()
                    list = dir('C:\Program Files\gs');
                    if numel(list)<3
                        list = dir('C:\Program Files (x86)\gs');
                        if numel(list)<3
                            return
                        end
                    end
                    lenOfList = numel(list);
                    versions = zeros(1, lenOfList);
                    for i = 1 : lenOfList
                        temp = sscanf(list(i).name, 'gs%g');
                        if isnumeric(temp) && isscalar(temp)
                            versions(i) = temp;
                        end
                    end
                    [~, sorted] = sort(versions, 'descend');
                    for pos = sorted(:)'
                        if versions(pos)==0
                            continue
                        end
                        latestDir = fullfile(list(pos).folder, list(pos).name, 'bin');
                        latestExe = fullfile(latestDir, 'gswin64c.exe');
                        if ~isempty(dir(latestExe))
                            ghostscriptPath = latestExe;
                            return
                        else
                            latestExe = fullfile(latestDir, 'gswin32c.exe');
                            if ~isempty(dir(latestExe))
                                ghostscriptPath = latestExe;
                                return
                            end
                        end
                    end
                    % Failed to find gs, return
                    return
                else
                    ghostscriptPath = '/usr/bin/gs';
                    list = dir(ghostscriptPath);
                    if ~isempty(list)
                        return
                    end
                    ghostscriptPath = '/usr/local/bin/gs';
                    list = dir(ghostscriptPath);
                    if ~isempty(list)
                        return
                    end
                    % Failed to find gs, return
                    ghostscriptPath = '';
                    return
                end
            end
        end%


        function irisRoot = getIrisRoot()
            irisRoot = fileparts(which('irisping.m'));
        end%


        function irisRelease = getIrisRelease()
            x = ver();
            inxIris = startsWith(strip(string({x.Name})), '[Iris');
            numIris = nnz(inxIris);
            if numIris==1
                irisRelease = regexp(x(inxIris).Version, '\d+\-?\w+', 'match', 'once');
            elseif numIris==0
                %
                % Do not use utils.warning because it calls back iris.get and results
                % in an infinite recursion
                %
                warning( ...
                    'IrisToolbox:CannotDetermineRelease', ...
                    'Cannot determine the release of [IrisToolbox] currently running.' ...
                )
                irisRelease = '???';
            else
                %
                % Look up all Contents.m files that have the string
                % "[IrisToolbox]" in them and report their folders
                %
                allContentsFiles = which("-all", "Contents.m");
                irisContentsFolders = string.empty(0, 1);
                for fileName = reshape(string(allContentsFiles), 1, [])
                    f = fileread(fileName);
                    if contains(f, "[IrisToolbox]")
                        irisContentsFolders(end+1, 1) = "    * " + string(fileparts(fileName)); %#ok<AGROW>
                    end
                end

                disp(' ');
                thisError = [
                    "IrisToolbox:ConflictingVersionsOrFolders"
                    ""
                    "Cannot start up [IrisToolbox] because there are conflicting [IrisToolbox] root folders or [IrisToolbox] versions on the Matlab path: "
                    irisContentsFolders
                    "Remove all the above [IrisToolbox] versions and folders from the Matlab path, use addpath to add the right one, and start [IrisToolbox] up again."
                    ""
                ];
                error(thisError(1), join(thisError(2:end), string(newline)));
            end
        end%


        function flag = validateDateFormat(x)
            flag =  isequal(x, @auto) || isequal(x, @excel) ...
                || ischar(x) || iscellstr(x) || isstring(x) ...
                || iris.Configuration.validateDateFormatStruct(x);
        end%


        function flag = validatePlotDateFormat(x)
            flag =  isequal(x, @auto) ...
                || ischar(x) || iscellstr(x) || isstring(x) ...
                || iris.Configuration.validateDateFormatStruct(x);
        end%


        function flag = validateDateFormatStruct(x)
            dateFormatStructFields = iris.Configuration.DATE_FORMAT_STRUCT_FIELDS;
            flag = isstruct(x) && numel(x)==1  && all(isfield(x, dateFormatStructFields));
        end%


        function flag = validateFreqLetters(x)
            flag = iris.Configuration.validateDateFormatStruct(x);
            if ~flag
                return
            end
            for n = textual.stringify(iris.Configuration.DATE_FORMAT_STRUCT_FIELDS)
                flag = isstring(x.(n)) && isscalar(x.(n));
                if ~flag
                    return
                end
            end
        end%


        function flag = validateBaseYear(x)
            flag = isequal(x, @auto) || (isnumeric(x) && isscalar(x) && x==round(x));
        end%


        function flag = validateMonths(x)
            flag = isequal(x, @auto) || (iscellstr(x) && numel(x)==12 && isequal(x, unique(x, 'stable')));
        end%


        function flag = validateConversionMonth(x)
            flag = ...
                (isnumeric(x) && isscalar(x)  && x==round(x) && x>0) ...
                || strcmpi(x, 'first') || strcmpi(x, 'last');
        end%


        function flag = validateConversionDay(x)
            flag = ...
                (isnumeric(x) && isscalar(x)  && x==round(x) && x>0) ...
                || strcmpi(x, 'first') || strcmpi(x, 'last');
        end%


        function flag = validateWDay(x)
            flag = any(strcmpi(x, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'}));
        end%


        function flag = validateX13Path(x)
            flag = isequal(x, @auto) || ischar(x) || (isstring(x) && isscalar(x));
        end%


        function flag = validatePdfLatexPath(x)
            flag = ischar(x) || isstring(x);
        end%


        function flag = validateEpsToPdfPath(x)
            flag = ischar(x) || isstring(x);
        end%
    end
end
