classdef (CaseInsensitiveProperties=true) Configuration 
    properties (SetAccess=protected)
        % IrisRoot  IRIS root folder (not customizable)
        IrisRoot = fileparts(which('irisping.m'))

        % Version  IRIS version (not customizable)
        Version = iris.Configuration.getIrisVersion( )

        % Freq  Numeric representation of date frequencies (not customizable)
        Freq = iris.Configuration.DEFAULT_FREQ

        % FreqNames  Names of date frequencies (not customizable)
        FreqNames = containers.Map(iris.Configuration.DEFAULT_FREQ, iris.Configuration.DEFAULT_FREQ_NAMES)

        % UserConfigPath  Path to the user config file (not customizable)
        UserConfigPath = ''

        % Fred API 
        FredApiKey = '951f01181da86ccb9045ce8716f82f43'
    end
        

    properties
        % FreqLetters  One-letter representation of each date frequency
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

        % WDay  Day of the week representing a weekly date
        WDay = iris.Configuration.DEFAULT_WEEK_DAY

        % TSeriesFormat  Format for displaying numeric time series data
        TSeriesFormat = iris.Configuration.DEFAULT_TSERIES_FORMAT

        % TSeriesMaxWSpace  Maximum number of spaces between time series columns when being displayed
        TSeriesMaxWSpace = iris.Configuration.DEFAULT_TSERIES_MAX_WSPACE

        % PdfLatexPath  Path to the PDFLATEX executable
        PdfLatexPath = iris.Configuration.DEFAULT_LATEX_PATHS{1} 

        % EpsToPdfpath  Path to the EPSTOPDF executable
        EpsToPdfPath = iris.Configuration.DEFAULT_LATEX_PATHS{2}

        % UserData  Any kind of user data
        UserData = [ ]
    end


    properties (Dependent)
        NumFrequencies
    end


    properties (Constant, Hidden)
        DEFAULT_FREQ = [0, 1, 2, 4, 6, 12, 52, 365]

        DEFAULT_FREQ_NAMES = {
            'Integer'
            'Yearly'
            'Half-Yearly'
            'Quarterly'
            'Bimonthly'
            'Monthly'
            'Weekly'
            'Daily' 
        } 

        DEFAULT_FREQ_LETTERS = 'YHQBMW'

        DEFAULT_DATE_FORMAT = struct( ...
            'integer', 'P', ...
            'yy', 'YF', ...
            'hh', 'YFP', ...
            'qq', 'YFP', ...
            'bb', 'YFP', ...
            'mm', 'YFP', ...
            'ww', 'YFP', ...
            'dd', '$YYYY-Mmm-DD' ...
        )

        DEFAULT_PLOT_DATE_FORMAT = struct( ...
            'integer','P', ...    
            'yy', 'Y', ...
            'hh', 'Y:P', ...
            'qq', 'Y:P', ...
            'bb', 'Y:P', ...
            'mm', 'Y:P', ...
            'ww', 'Y:P', ...
            'dd', '$YYYY-Mmm-DD' ...
        )

        DEFAULT_PLOT_DATETIME_FORMAT = struct( ...
            'INTEGER', '', ...    
            'YEARLY', 'uuuu''Y''', ...
            'HALFYEARLY', 'uuuu''M''MM', ...
            'QUARTERLY', 'uuuu:Q', ...
            'MONTHLY', 'uuuu:MM', ...
            'WEEKLY', 'uuuu-MM-dd', ...
            'DAILY', 'uuuu-MM-dd' ...
        )

        DEFAULT_BASE_YEAR = 2000

        DEFAULT_MONTHS = {
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
        
        DEFAULT_CONVERSION_MONTH = 'first'

        DEFAULT_WEEK_DAY = 'Thu'

        DEFAULT_TSERIES_FORMAT = ''

        DEFAULT_TSERIES_MAX_WSPACE = 5

        DEFAULT_LATEX_PATHS = iris.Configuration.findTexFiles( )

        NUM_FREQUENCIES = numel(iris.Configuration.DEFAULT_FREQ)

        DATE_FORMAT_STRUCT_FIELDS = {
            'integer'
            'yy'
            'hh'
            'qq'
            'bb'
            'mm'
            'ww'
            'dd'
        }
    end


    methods
        function this = Configuration( )
            this.UserConfigPath = which('irisuserconfig.m');
            if ~isempty(this.UserConfigPath)
                this = irisuserconfig(this);
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: FreqLetters' ...
                );
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: DateFormat' ...
                );
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: PlotDateFormat' ...
                );
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: BaseYear' ...
                );
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: Months' ...
                );
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
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: ConversionMonth' ...
                );
            end
            this.ConversionMonth = newValue;
        end%
     

        function this = set.WDay(this, newValue)
            try
                flag = iris.Configuration.validateWDay(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: WDay' ...
                );
            end
            this.WDay = newValue;
        end%
     

        function this = set.TSeriesFormat(this, newValue)
            try
                flag = iris.Configuration.validateTSeriesFormat(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: TSeriesFormat' ...
                );
            end
            this.TSeriesFormat = newValue;
        end%
     

        function this = set.TSeriesMaxWSpace(this, newValue)
            try
                flag = iris.Configuration.validateTSeriesMaxWSpace(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: TSeriesMaxWSpace' ...
                );
            end
            this.TSeriesMaxWSpace = newValue;
        end%
     

        function this = set.PdfLatexPath(this, newValue)
            try
                flag = iris.Configuration.validatePdfLatexPath(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: PdfLatexPath' ...
                );
            end
            this.PdfLatexPath = newValue;
        end%
     

        function this = set.EpsToPdfPath(this, newValue)
            try
                flag = iris.Configuration.validateEpsToPdfPath(newValue);
            catch
                flag = false;
            end
            if ~flag
                error( ...
                    'IRIS:Config:NewOptionFailedValidation', ...
                    'The value being assigned to this configuration option is invalid: EpsToPdfPath' ...
                );
            end
            this.EpsToPdfPath = newValue;
        end%
     

        function n = get.NumFrequencies(this)
            n = numel(iris.Configuration.DEFAULT_FREQ);
        end%
    end


    methods (Static)
        function paths = findTexFiles( )
            [pdfLatexPath, folder] = iris.Configuration.findTexMf('pdflatex');
            epsToPdfPath = iris.Configuration.findEpsToPdf(folder);
            paths = {pdfLatexPath, epsToPdfPath};
        end

        function [path, folder] = findTexMf(file)
            % Try FINDTEXMF first.
            [flag, path] = system(['findtexmf --file-type=exe ', file]);
            if flag~=0
                [flag, path] = system(['findtexmf ', file, '.exe']);
            end       
            % If FINDTEXMF fails, try to run WHICH on Unix platforms.
            if flag~=0 && isunix( )
                % Unix, macOS
                [flag, path] = iris.Configuration.tryFolder('/usr/texbin', file);
                if flag~=0
                    [flag, path] = iris.Configuration.tryFolder('/Library/TeX/texbin', file);
                    if flag~=0
                        [flag, path] = system(['which ', file]);
                    end
                end
            end
            if flag==0
                % Use the correctly spelled path and the right file separators.
                path = strtrim(path);
                [folder, ttl, ext] = fileparts(path);
                path = fullfile(folder, [ttl, ext]);
            else
                path = '';
                folder = '';
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


        function fPath = findEpsToPdf(folder)
            file = 'epstopdf';
            if ispc( )
                list = dir(fullfile(folder, [file, '.exe']));
            else
                list = dir(fullfile(folder, file));
            end
            if length(list)==1
                fPath = fullfile(folder, list.name);
            else
                fPath = iris.Configuration.findTexMf(file);
            end
        end%


        function irisVersion = getIrisVersion( )
            x = ver( );
            indexIris = strcmp('IRIS Macroeconomic Modeling Toolbox', {x.Name});
            if any(indexIris)
                if sum(indexIris)>1
                    disp(' ');
                    error('IRIS:Fatal', [ ...
                        'Cannot start IRIS up properly ', ...
                        'because there are conflicting IRIS root folders or versions on the Matlab path. ', ...
                        'Remove *ALL* IRIS versions and folders from the Matlab path, ', ...
                        'and try again.', ...
                    ]);
                end
                irisVersion = regexp(x(indexIris).Version, '\d+\-?\w+', 'match', 'once');
            else
                % Do not use utils.warning because it calls back iris.get and results
                % in infinite recursion.
                warning( ...
                    'IRIS:Config:CannotDetermineIRISVersion', ...
                    'Cannot determine the current version of IRIS.' ...
                );
                irisVersion = '???';
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
                || ischar(x) || iscellstr(x) ...
                || iris.Configuration.validateDateFormatStruct(x);
        end%


        function flag = validatePlotDateFormat(x)
            flag =  isequal(x, @config) ...
                || ischar(x) || iscellstr(x) ...
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
                || isequal(x, 'first') || isequal(x, 'last');
        end%


        function flag = validateWDay(x)
            flag = any(strcmpi(x, {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'}));
        end%


        function flag = validateTSeriesFormat(x)
            flag = ischar(x) || isa(x, 'string');
        end%


        function flag = validateTSeriesMaxWSpace(x)
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
