classdef InputParser < inputParser
    properties
        PrimaryParameterNames = cell.empty(1, 0)
        Options = struct( )
        Aliases = struct( )
        HasDateOptions = false
    end


    properties (Dependent)
        UnmatchedInCell
        UsingDefaultsInStruct
    end


    methods
        function this = InputParser(functionName)
            this = this@inputParser( );
            this.CaseSensitive = false;
            if nargin>0
                this.FunctionName = char(functionName);
            end
        end


        function parse(this, varargin)
            ix = cellfun(@(x) ischar(x) || (isa(x, 'string') && isscalar(x)), varargin);
            varargin(ix) = cellfun(@(x) regexprep(x, '=$', ''), varargin(ix), 'UniformOutput', false);
            parse@inputParser(this, varargin{:});
            for i = 1 : numel(this.PrimaryParameterNames)
                ithName = this.PrimaryParameterNames{i};
                this.Options.(ithName) = this.Results.(ithName);
            end
            listOfAliases = fieldnames(this.Aliases);
            for i = 1 : numel(listOfAliases)
                ithAlias = listOfAliases{i};
                ithPrimaryName = this.Aliases.(ithAlias);
                if any(strcmp(ithPrimaryName, this.UsingDefaults)) ...
                    && ~any(strcmp(ithAlias, this.UsingDefaults))
                    this.Options.(ithPrimaryName) = this.Results.(ithAlias);
                end
            end
            if this.HasDateOptions
                resolveDateOptions(this);
            end
        end


        function addParameter(this, name, varargin)
            if ischar(name) || (isa(name, 'string') && numel(name)==1)
                addParameter@inputParser(this, name, varargin{:});
                this.PrimaryParameterNames{end+1} = name;
                return
            end
            if isa(name, 'string')
                name = cellstr(name);
            end
            primaryName = name{1};
            addParameter@inputParser(this, primaryName, varargin{:});
            this.PrimaryParameterNames{end+1} = primaryName;
            for i = 2 : numel(name)
                ithName = name{i};
                this.Aliases.(ithName) = primaryName;
                addParameter@inputParser(this, ithName, varargin{:});
            end
        end


        function unmatched = get.UnmatchedInCell(this)
            names = fieldnames(this.Unmatched);
            numUnmatched = numel(names);
            unmatched = cell(2, numUnmatched);
            for i = 1 : numUnmatched
                unmatched{1, i} = names{i};
                unmatched{2, i} = this.Unmatched.(names{i});
            end
            unmatched = unmatched(:);
        end


        function usingDefaults = get.UsingDefaultsInStruct(this)
            usingDefaults = struct( );
            for i = 1 : numel(this.PrimaryParameterNames)
                ithName = this.PrimaryParameterNames{i};
                usingDefaults.(ithName) = any(strcmp(this.UsingDefaults, ithName));
            end
        end


        function addDateOptions(this)
            configStruct = iris.get( );
            this.addParameter('DateFormat', @config, configStruct.validate.DateFormat);
            this.addParameter({'FreqLetters', 'FreqLetter'}, @config, configStruct.validate.FreqLetters);
            this.addParameter({'Months', 'Month'}, @config, configStruct.validate.Months);
            this.addParameter({'ConversionMonth', 'StandInMonth'}, @config, configStruct.validate.ConversionMonth);
            this.addParameter('WDay', @config, configStruct.validate.WDay);
            this.HasDateOptions = true;
        end


        function addBaseYearOption(this)
            configStruct = iris.get( );
            this.addParameter('BaseYear', @config, configStruct.validate.BaseYear);
        end


        function addUserDataOption(this)
            this.addParameter('UserData', double.empty(1, 0));
        end


        function resolveDateOptions(this, isPlot)
            if nargin<2
                isPlot = false;
            end

            configStruct = iris.get( );

            if isequal(this.Options.DateFormat, @config)
                if ~isPlot
                    this.Options.DateFormat = configStruct.DateFormat;
                else
                    this.Options.DateFormat = configStruct.plotDateFormat;
                end
            end

            if isequal(this.Options.FreqLetters, @config)
                this.Options.FreqLetters = configStruct.FreqLetters;
            end

            if isequal(this.Options.Months, @config)
                this.Options.Months = configStruct.Months;
            end

            if isequal(this.Options.ConversionMonth, @config)
                this.Options.ConversionMonth = configStruct.ConversionMonth;
            end

            if isequal(this.Options.WDay, @config)
                this.Options.WDay = configStruct.WDay;
            end
        end
    end
end
