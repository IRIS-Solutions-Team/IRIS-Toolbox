classdef InputParser ...
    < inputParser 

    properties
        PrimaryParameterNames = cell.empty(1, 0)
        Options = struct( )
        Aliases = struct( )
        Conditional = inputParser.empty(0)
        ParameterArguments = struct()
        Cast = struct()

        HasDateOptions (1, 1) logical = false
        DateOptionsContext = ''
        HasSwapFixOptions (1, 1) logical = false
        HasOptionalRangeStartEnd (1, 1) logical = false
        HasStartEndOptions (1, 1) logical = false

        Nested = struct( )
        DefaultOptions = struct( )
        KeepDefaultOptions (1, 1) logical = false
    end


    properties (Constant)
        REPLACE = @(x) replace(x, ["=", "."], ["", "_"]);
    end


    properties (Dependent)
        UnmatchedInCell
        PrimaryOptionsInCell
        UsingDefaultsInStruct
    end


    methods
        function this = InputParser(functionName)
            this = this@inputParser( );
            this.CaseSensitive = false;
            if nargin<1
                stack = dbstack(1, '-completenames');
                functionName = stack(1).file;
            end
            this.FunctionName = char(functionName);
        end%


        function opt = parse(this, varargin)
            % Remove = and . from option names
            for i = numel(varargin)-1 : -2 : 1
                if ~( ischar(varargin{i}) || (isstring(varargin{i}) && isscalar(varargin{i})) )
                    break
                end
                if endsWith(varargin{i}, '=')
                    varargin{i} = this.REPLACE(varargin{i});
                end
            end

            parse@inputParser(this, varargin{:});

            for n = textual.stringify(this.PrimaryParameterNames)
                if isfield(this.Nested, n)
                    super__ = this.Nested.(n)(1);
                    nested__ = this.Nested.(n)(2);
                    if ~isfield(this.Options, super__)
                        this.Options.(super__) = struct( );
                    end
                    this.Options.(super__).(nested__) = this.Results.(n);
                else
                    this.Options.(n) = this.Results.(n);
                end
            end

            for alias = textual.fields(this.Aliases)
                currPrimaryName = this.Aliases.(alias);
                if any(strcmp(currPrimaryName, this.UsingDefaults)) ...
                    && ~any(strcmp(alias, this.UsingDefaults))
                    this.Options.(currPrimaryName) = this.Results.(alias);
                end
            end

            if this.HasDateOptions
                this.Options = this.resolveDateOptions(this.Options, this.DateOptionsContext);
            end
            if this.HasOptionalRangeStartEnd
                resolveOptionalRangeStartEnd(this);
            end
            if this.HasStartEndOptions
                resolveStartEndOptions(this);
            end
            if this.HasSwapFixOptions
                resolveSwapFixOptions(this);
            end

            if ~isempty(this.Conditional)
                numParameters = numel(this.Conditional.Parameters);
                args = cell(1, 2*numParameters);
                args(1:2:end) = this.Conditional.Parameters;
                args(2:2:end) = { this.Results };
                parse(this.Conditional, args{:});
            end

            % Remove aliases from this.Options
            allFields = textual.fields(this.Options);
            fieldsToRemove = setdiff(allFields, textual.stringify(this.PrimaryParameterNames));
            this.Options = rmfield(this.Options, fieldsToRemove);

            % Cast options as user specified types
            for n = textual.fields(this.Cast)
                this.Options.(n) = this.Cast.(n)(this.Options.(n));
            end

            if nargout>=1
                opt = this.Options;
            end
        end%


        function [skipped, opt] = maybeSkip(this, varargin)
            %(
            skipped = this.KeepDefaultOptions && ~isempty(varargin) ...
                && isstring(varargin{end}) && isscalar(varargin{end}) ...
                && startsWith(varargin{end}, "--skip", "ignoreCase", true);
            if ~skipped
                opt = [ ];
                return
            end
            varargin(end) = [ ];
            opt = this.DefaultOptions;
            if ~isempty(varargin)
                for i = 1 : 2 : numel(varargin)-1
                    name = this.REPLACE(varargin{i});
                    opt.(name) = varargin{i+1};
                end
            end
            if this.HasDateOptions
                opt = this.resolveDateOptions(opt, this.DateOptionsContext);
            end
            %)
        end%


        function addParameter(this, name, varargin)
            name = textual.stringify(name);
            if numel(name)==1
                nameToRegister = name;
                isPrimaryName = true;
                aliases = [];
            elseif numel(name)==2 && strlength(name(1))==0
                nameToRegister = name(2);
                isPrimaryName = false;
                aliases = [];
            else
                nameToRegister = name(1);
                isPrimaryName = true;
                aliases = name(2:end);
            end

            cast = [];
            if numel(varargin)>=3
                cast = varargin{3};
                varargin(3) = [];
            end

            nameToRegister = this.REPLACE(nameToRegister);
            addParameter@inputParser(this, nameToRegister, varargin{:});

            if isPrimaryName
                this.ParameterArguments.(nameToRegister) = varargin;
                this.PrimaryParameterNames{end+1} = char(nameToRegister);
                if this.KeepDefaultOptions
                    this.DefaultOptions.(nameToRegister) = varargin{1};
                end
                addCast(this, nameToRegister, cast);
            end

            if ~isempty(aliases)
                addAlias(this, nameToRegister, aliases);
            end
        end%


        function addCast(this, name, cast)
            if isa(cast, 'function_handle')
                this.Cast.(name) = cast;
            end
        end%


        function addAlias(this, primaryName, aliases)
            if nargin<3 || isempty(aliases)
                return
            end
            args = this.ParameterArguments.(primaryName);
            for n = textual.stringify(aliases)
                this.Aliases.(n) = primaryName;
                addParameter(this, ["", n], args{:});
            end
        end%


        function addNested(this, super, nested, varargin)
            primaryName = string(super) + string(nested);
            addParameter(this, primaryName, varargin{:});
            this.Nested.(primaryName) = [string(super), string(nested)];
        end%


        function addConditional(this, name, default, validator)
            addParameter(this, name, default);
            if isempty(this.Conditional)
                this.Conditional = extend.InputParser(this.FunctionName);
            end
            addParameter(this.Conditional, name, default, validator);
        end%


        function unmatched = get.UnmatchedInCell(this)
            names = fieldnames(this.Unmatched);
            numUnmatched = numel(names);
            unmatched = cell(2, numUnmatched);
            for i = 1 : numUnmatched
                unmatched{1, i} = names{i};
                unmatched{2, i} = this.Unmatched.(names{i});
            end
            unmatched = unmatched(:).';
        end%


        function usingDefaults = get.UsingDefaultsInStruct(this)
            usingDefaults = struct( );
            for i = 1 : numel(this.PrimaryParameterNames)
                name__ = this.PrimaryParameterNames{i};
                usingDefaults.(name__) = any(strcmp(this.UsingDefaults, name__));
            end
        end%


        function value = get.PrimaryOptionsInCell(this)
            listPrimaryOptions = fieldnames(this.Options);
            numPrimaryOptions = numel(listPrimaryOptions);
            value = cell(1, 2*numPrimaryOptions);
            value(1:2:end) = listPrimaryOptions;
            value(2:2:end) = struct2cell(this.Options);
        end%


        function addDateOptions(this, context)
            configStruct = iris.get( );
            addParameter(this, 'DateFormat', @auto, @(x) iris.Configuration.validateDateFormat(x) || isequal(x, @datetime) || isequal(x, @auto) || isequal(x, @iso));
            addParameter(this, {'EnforceFrequency', 'Frequency', 'Freq'}, false, @(x) isequal(x, false) || isempty(x) || isa(Frequency(x), 'Frequency'));
            addParameter(this, {'Months', 'Month'}, iris.Configuration.Months, @iris.Configuration.validateMonths);
            addParameter(this, {'ConversionMonth', 'StandInMonth'}, iris.Configuration.ConversionMonth, @iris.Configuration.validateConversionMonth);
            addParameter(this, 'ConversionDay', iris.Configuration.ConversionDay, @iris.Configuration.validateConversionDay);
            addParameter(this, 'WDay', iris.Configuration.WDay, @iris.Configuration.validateWDay);
            addParameter(this, 'DatePosition', 'c', @(x) (ischar(x) || isstring(x)) && startsWith(lower(string(x)), ["s", "e", "c"]));

            this.HasDateOptions = true;
            if nargin>1
                this.DateOptionsContext = context;
            end
        end%


        function addPlotOptions(this)
            addParameter(this, 'Function', [ ], @(x) isempty(x) || isa(x, 'function_handle'));
            addParameter(this, 'Tight', false, @(x) isequal(x, true) || isequal(x, false));
            addParameter(this, 'XLimMargins', @auto, @(x) isequal(x, true) || isequal(x, false) || isequal(x, @auto));
        end%


        function addBaseYearOption(this)
            addParameter(this, 'BaseYear', @auto, @iris.Configuration.validateBaseYear);
        end%


        function addUserDataOption(this)
            addParameter(this, 'UserData', double.empty(1, 0));
        end%


        function addSwapFixOptions(this)
            addParameter(this, 'Exogenize', cell.empty(1, 0), @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @auto));
            addParameter(this, 'Endogenize', cell.empty(1, 0), @(x) isempty(x) || ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @auto));
            addParameter(this, 'Fix', string.empty(1, 0), @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x) || isstring(x));
            addParameter(this, 'FixLevel', string.empty(1, 0), @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x) || isstring(x));
            addParameter(this, {'FixChange', 'FixGrowth'}, string.empty(1, 0), @(x) isempty(x) || isa(x, 'Except') || iscellstr(x) || ischar(x) || isstring(x));
            this.HasSwapFixOptions = true;
        end%


        function addOptionalRangeStartEnd(this)
            addOptional(this, 'Range', @auto, @(x) isequal(x, @auto) || isequal(x, Inf) || validate.range(x));
            this.addStartEndOptions( );
            this.HasOptionalRangeStartEnd = true;
        end%


        function addStartEndOptions(this)
            addParameter(this, 'Start', -Inf, @(x) isequal(x, -Inf) || validate.date(x));
            addParameter(this, 'End', Inf, @(x) isequal(x, Inf) || validate.date(x));
            this.HasStartEndOptions = true;
        end%


        function addDisplayOption(this, defaultDisplay)
            addParameter(this, 'Display', defaultDisplay, @solver.Options.validateDisplay);
        end%


        function resolveOptionalRangeStartEnd(this)
            if isequal(this.Results.Range, @auto)
                return
            end
            if isequal(this.Results.Range, Inf)
                this.Options.Start = -Inf;
                this.Options.End = Inf;
                return
            end
            this.Options.Start = this.Results.Range(1);
            this.Options.End = this.Results.Range(end);
        end


        function resolveStartEndOptions(this)
            if isfield(this.Results, 'InputSeries')
                if ~validateFrequencyOrInf(this.Results.InputSeries, this.Options.Start)
                    throw( exception.Base('InputParser:InvalidStartOption', 'error') );
                end
                if ~validateFrequencyOrInf(this.Results.InputSeries, this.Options.End)
                    throw( exception.Base('InputParser:InvalidEndOption', 'error') );
                end
            end
            this.Options.SerialOfStart = dater.getSerial(this.Options.Start);
            this.Options.SerialOfEnd = dater.getSerial(this.Options.End);
        end%


        function resolveSwapFixOptions(this)
            if ~isa(this.Options.Exogenize, 'function_handle')
                if ischar(this.Options.Exogenize)
                    this.Options.Exogenize = regexp(this.Options.Exogenize, '\w+', 'match');
                else
                    this.Options.Exogenize = cellstr(this.Options.Exogenize);
                end
                inxToExclude = strncmp(this.Options.Exogenize, '~', 1);
                if any(inxToExclude)
                    this.Options.Exogenize(inxToExclude) = [ ];
                end
            end
            if ~isa(this.Options.Endogenize, 'function_handle')
                if ischar(this.Options.Endogenize)
                    this.Options.Endogenize = regexp(this.Options.Endogenize, '\w+', 'match');
                else
                    this.Options.Endogenize = cellstr(this.Options.Endogenize);
                end
                inxToExclude = strncmp(this.Options.Endogenize, '~', 1);
                if any(inxToExclude)
                    this.Options.Endogenize(inxToExclude) = [ ];
                end
            end
        end%
    end


    methods (Static)
        function dateOptionsInCell = extractDateOptionsFromStruct(opt)
            %(
            listFields = fieldnames(opt);
            dateOptionsInCell = cell.empty(1, 0);
            index = strcmpi(listFields, 'DateFormat');
            if any(index)
                pos = find(index, 1, 'last');
                dateOptionsInCell = [dateOptionsInCell, {'DateFormat', opt.(listFields{pos})}];
            end
            index = strncmpi(listFields, 'Month', 5);
            if any(index)
                pos = find(index, 1, 'last');
                dateOptionsInCell = [dateOptionsInCell, {'Months', opt.(listFields{pos})}];
            end
            index = strcmpi(listFields, 'ConversionMonth') | strcmpi(listFields, 'StandInMonth');
            if any(index)
                pos = find(index, 1, 'last');
                dateOptionsInCell = [dateOptionsInCell, {'ConversionMonth', opt.(listFields{pos})}];
            end
            index = strcmpi(listFields, 'WDay');
            if any(index)
                pos = find(index, 1, 'last');
                dateOptionsInCell = [dateOptionsInCell, {'WDay', opt.(listFields{pos})}];
            end
            %)
        end%


        function opt = resolveDateOptions(opt, context)
            %(
            if isequal(opt.DateFormat, @auto)
                if strcmpi(context, 'Series')
                    opt.DateFormat = iris.get('PlotDateTimeFormat');
                else
                    opt.DateFormat = iris.get('DateFormat');
                end
            end
            %)
        end%
    end
end

