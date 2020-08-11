classdef (CaseInsensitiveProperties=true) Configuration 
    properties (SetAccess=protected)
        %(
        % IrisRoot  IrisToolbox root folder (not customizable)
        IrisRoot = iris.Configuration.getIrisRoot( )

        % Release  IrisToolbox release (not customizable)
        Release = iris.Configuration.getIrisRelease( )

        % DesktopStatus  True if Matlab is running in Java desktop
        DesktopStatus = iris.Configuration.getDesktopStatus( )

        % Ellipsis  Ellipsis character
        Ellipsis = iris.Configuration.getEllipsis( )

        % Freq  Numeric representation of date frequencies (not customizable)
        Freq = iris.Configuration.DEFAULT_FREQ

        % FreqNames  Names of date frequencies (not customizable)
        FreqNames = containers.Map(uint8(iris.Configuration.DEFAULT_FREQ), iris.Configuration.DEFAULT_FREQ_NAMES)

        % RegularFrequencies  Vector of regular frequencies
        RegularFrequencies = [ Frequency.YEARLY
                               Frequency.HALFYEARLY
                               Frequency.QUARTERLY
                               Frequency.MONTHLY
                               Frequency.WEEKLY ]

        % UserConfigPath  Path to the user config file (not customizable)
        UserConfigPath = ''

        % Fred API 
        FredApiKey = "951f01181da86ccb9045ce8716f82f43"
        %)
    end
        

    properties
        %(
        % FreqLetters  One-letter representation of each regular frequency
        FreqLetters = iris.Configuration.DEFAULT_FREQ_LETTERS

        % DateFormat  Default date format
        DateFormat = iris.Configuration.DEFAULT_DATE_FORMAT

        % PlotDateFormat  Default date format in tseries
        PlotDateFormat = iris.Configuration.DEFAULT_PLOT_DATE_FORMAT

        % PlotDateTimeFormat
        PlotDateTimeFormat = iris.Configuration.DEFAULT_PLOT_DATETIME_FORMAT

        % BaseYear  Base year for linear trends
        BaseYear = iris.Configuration.DEFAULT_BASE_YEAR

        % Months  Names of calendar months
        Months = iris.Configuration.DEFAULT_MONTHS

        % ConversionMonth  Month representing a low-frequency date when being converted to higher-frequency date
        ConversionMonth = iris.Configuration.DEFAULT_CONVERSION_MONTH

        % ConversionDay  Day representing a low-frequency date when being converted to daily dates
        ConversionDay = iris.Configuration.DEFAULT_CONVERSION_DAY

        % WDay  Day of the week representing a weekly date
        WDay = iris.Configuration.DEFAULT_WEEK_DAY

        % DispIndent  Indentation at the beginning of class display
        DispIndent = iris.Configuration.DEFAULT_DISP_INDENT

        % SeriesFormat  Format for displaying numeric time series data
        SeriesFormat = iris.Configuration.DEFAULT_SERIES_FORMAT

        % SeriesMaxWSpace  Maximum number of spaces between time series columns when being displayed
        SeriesMaxWSpace = iris.Configuration.DEFAULT_SERIES_MAX_WSPACE

        % PdfLatexPath  Path to the PDFLATEX executable
        PdfLatexPath = [ ]

        % EpsToPdfpath  Path to the EPSTOPDF executable
        EpsToPdfPath = [ ] 

        % PsToPdfPath  Path to the PSTOPDF executable
        PsToPdfPath = [ ] 

        % GhostscriptPath  Path to the GS executable
        GhostscriptPath = iris.Configuration.DEFAULT_GHOSTSCRIPT_PATH

        % DefaultTimeSeriesConstructor  Function handle to default time series constructor
        DefaultTimeSeriesConstructor = @Series

        % DisplayFullStack  Display full stack in error and warning messages thrown by IrisToolbox
        DisplayFullStack = false

        % UserData  Any kind of user data
        UserData = [ ]
        %)
    end


    properties (Dependent, Hidden)
        Version
        TSeriesFormat
    end


    properties (Dependent)
        NumOfFrequencies
        ConvertPsToPdf
    end


    properties (Constant, Hidden)
        %(
        DEFAULT_FREQ = [ Frequency.INTEGER
                         Frequency.YEARLY
                         Frequency.HALFYEARLY
                         Frequency.QUARTERLY
                         Frequency.MONTHLY
                         Frequency.WEEKLY
                         Frequency.DAILY ]

        DEFAULT_FREQ_NAMES = { 'Integer'
                               'Yearly'
                               'Half-Yearly'
                               'Quarterly'
                               'Monthly'
                               'Weekly'
                               'Daily'       } 

        DEFAULT_FREQ_LETTERS = 'YHQMW'

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

        DEFAULT_BASE_YEAR = 2000

        DEFAULT_MONTHS = { 'January'
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
                           'December' } 
        
        DEFAULT_CONVERSION_MONTH = 1
        
        DEFAULT_CONVERSION_DAY = 1

        DEFAULT_WEEK_DAY = 'Thu'

        DEFAULT_DISP_INDENT = '    '

        DEFAULT_SERIES_FORMAT = ''

        DEFAULT_SERIES_MAX_WSPACE = 5

        DEFAULT_GHOSTSCRIPT_PATH = iris.Configuration.findGhostscript( )

        NUM_FREQUENCIES = numel(iris.Configuration.DEFAULT_FREQ)

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
            this.UserConfigPath = which("irisuserconfig.m");

            if isempty(varargin) || ~isa(varargin{1}, "struct") || varargin{1}.TeX
                paths = iris.Configuration.findTexFiles( );
                [this.PdfLatexPath, this.EpsToPdfPath, this.PsToPdfPath] = paths{:};
            end

            if ~isempty(this.UserConfigPath)
                this = irisuserconfig(this);
                thisWarning = [ 
                    "IrisToolbox:Deprecated"
                    "Using <irisuserconfig.m> file to modify IrisToolbox configuration "
                    "is deprecated and will be discontinued in a future release. "
                    "Use the standard Matlab <startup.m> file with iris.set( ) instead. "
                ];
                warning(thisWarning(1), join(thisWarning(2:end), newline));
            end
        end%


        function save(this)
            setappdata(0, this.APPDATA_FIELD_NAME, this);
        end%
    end


    methods (Static)
        function this = load( )
            this = getappdata(0, iris.Configuration.APPDATA_FIELD_NAME);
            if ~isa(this, 'iris.Configuration')
                thisWarning = [ 
                    "IrisToolbox:ConfigurationDamaged"
                    "Configuration data for [IrisToolbox] need to be reset."
                ];
                warning(thisWarning(1), join(thisWarning(2:end), newline));
                this = iris.reset( );
            end
        end%


        function clear( )
            try
                rmappdata(0, iris.Configuration.APPDATA_FIELD_NAME);
            end
        end%
    end


    methods
        function this = set.FreqLetters(this, newValue)
            try
                flag = iris.Configuration.validateFreqLetters(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: FreqLetters' );
            end
            this.FreqLetters = newValue;
        end%


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
     

        function this = set.Months(this, newValue)
            try
                flag = iris.Configuration.validateMonths(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: Months' );
            end
            this.Months = newValue;
        end%
     

        function this = set.ConversionMonth(this, newValue)
            try
                flag = iris.Configuration.validateConversionMonth(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: ConversionMonth' );
            end
            this.ConversionMonth = newValue;
        end%
     

        function this = set.ConversionDay(this, newValue)
            try
                flag = iris.Configuration.validateConversionDay(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: ConversionDay' );
            end
            this.ConversionDay = newValue;
        end%
     

        function this = set.WDay(this, newValue)
            try
                flag = iris.Configuration.validateWDay(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                       'Value being assigned to this [IrisToolbox] configuration option is invalid: WDay' );
            end
            this.WDay = newValue;
        end%
     

        function this = set.SeriesFormat(this, newValue)
            try
                if iris.Configuration.validateSeriesFormat(newValue)
                    this.SeriesFormat = newValue;
                    return
                end
            end
            error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                   'Value being assigned to this [IrisToolbox] configuration option is invalid: SeriesFormat' );
        end%


        function this = set.TSeriesFormat(this, value)
            this.SeriesFormat = value;
        end%
     

        function this = set.SeriesMaxWSpace(this, newValue)
            try
                if iris.Configuration.validateSeriesMaxWSpace(newValue)
                    this.SeriesMaxWSpace = newValue;
                end
            end
            error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                   'Value being assigned to this [IrisToolbox] configuration option is invalid: SeriesMaxWSpace' );
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


        function this = set.DisplayFullStack(this, value)
            if validate.logicalScalar(value)
                this.DisplayFullStack = value;
                return
            end
            error( 'IrisToolbox:ConfigurationOptionFailedValidation', ...
                   'Value assigned to this [IrisToolbox] configuration option is invalid: DisplayFullStack' );
        end%
     

        function value = get.Version(this)
            value = this.Release;
        end%


        function n = get.NumOfFrequencies(this)
            n = numel(iris.Configuration.DEFAULT_FREQ);
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
        function paths = findTexFiles( )
            [pdfLatexPath, folder] = iris.Configuration.findTexMf('pdflatex');
            epstopdfPath = iris.Configuration.findPath(folder, 'epstopdf');
            pstopdfPath = iris.Configuration.findPath(folder, 'pstopdf');
            paths = {pdfLatexPath, epstopdfPath, pstopdfPath};
        end%


        function [path, folder] = findTexMf(file)
            path = '';
            folder = '';
            try
                if ispc( )
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
            if ispc( )
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


        function ghostscriptPath = findGhostscript( )
            ghostscriptPath = '';
            try
                if ispc( )
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


        function irisRoot = getIrisRoot( )
            irisRoot = fileparts(which('irisping.m'));
        end%


        function irisRelease = getIrisRelease( )
            x = ver( );
            inxIris = startsWith({x.Name}, '[IrisToolbox]');
            if any(inxIris)
                if sum(inxIris)>1
                    disp(' ');
                    thisError = { 'IrisToolbox:Fatal'
                                  'Cannot start up [IrisToolbox] because '
                                  'there are conflicting root folders '
                                  'or versions on the Matlab path. '
                                  'Remove *ALL* [IrisToolbox] versions and folders from the Matlab path, '
                                  'and try again.' };
                    error(thisError{1}, [thisError{2:end}]);
                end
                irisRelease = regexp(x(inxIris).Version, '\d+\-?\w+', 'match', 'once');
            else
                % Do not use utils.warning because it calls back iris.get and results
                % in infinite recursion.
                warning( 'IrisToolbox:CannotDetermineRelease', ...
                         'Cannot determine the release of [IrisToolbox] currently running.' );
                irisRelease = '???';
            end
        end%


        function isDesktop = getDesktopStatus( )
            try
                jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
                isDesktop = ~isempty(jDesktop.getClient('Command Window'));
            catch
                isDesktop = false;
            end
        end%


        function ellipsis = getEllipsis( )
            if iris.Configuration.getDesktopStatus( )
                ellipsis = char(8230);
            else
                ellipsis = '~';
            end
        end%


        function flag = validateFreqLetters(x)
            numFrequencies = iris.Configuration.NUM_FREQUENCIES;
            numX = numel(x);
            flag = isequal(x, @config) || ( ...
                ((ischar(x) || isa(x, 'string')) && isequal(x, unique(x, 'stable')) ) && numX==numFrequencies-2 ...
            );
        end%


        function flag = validateDateFormat(x)
            flag =  isequal(x, @config) || isequal(x, @excel) ...
                || ischar(x) || iscellstr(x) || isa(x, 'string') ...
                || iris.Configuration.validateDateFormatStruct(x);
        end%


        function flag = validatePlotDateFormat(x)
            flag =  isequal(x, @config) ...
                || ischar(x) || iscellstr(x) || isa(x, 'string') ...
                || iris.Configuration.validateDateFormatStruct(x);
        end%


        function flag = validateDateFormatStruct(x)
            dateFormatStructFields = iris.Configuration.DATE_FORMAT_STRUCT_FIELDS;
            flag = isstruct(x) && numel(x)==1  && all(isfield(x, dateFormatStructFields));
        end%


        function flag = validateBaseYear(x)
            flag = isequal(x, @config) || (isnumeric(x) && isscalar(x) && x==round(x));
        end%


        function flag = validateMonths(x)
            flag = isequal(x, @config) || (iscellstr(x) && numel(x)==12 && isequal(x, unique(x, 'stable')));
        end%


        function flag = validateConversionMonth(x)
            flag = isequal(x, @config) ...
                || (isnumeric(x) && isscalar(x)  && x==round(x) && x>0) ...
                || strcmpi(x, 'first') || strcmpi(x, 'last');
        end%


        function flag = validateConversionDay(x)
            flag = isequal(x, @config) ...
                || (isnumeric(x) && isscalar(x)  && x==round(x) && x>0) ...
                || strcmpi(x, 'first') || strcmpi(x, 'last');
        end%


        function flag = validateWDay(x)
            flag = any(strcmpi(x, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'}));
        end%


        function flag = validateSeriesFormat(x)
            flag = ischar(x) || isa(x, 'string');
        end%


        function flag = validateSeriesMaxWSpace(x)
            flag = isnumeric(x) && isscalar(x) && x==round(x) && x>0;
        end%


        function flag = validatePdfLatexPath(x)
            flag = ischar(x) || isa(x, 'string');
        end%


        function flag = validateEpsToPdfPath(x)
            flag = ischar(x) || isa(x, 'string');
        end%
    end
end
