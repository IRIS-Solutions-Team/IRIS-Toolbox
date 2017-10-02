classdef InputParser < inputParser
    properties
        PrimaryParameterNames = cell.empty(1, 0)
        Options = struct( )
        Aliases = struct( )
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
    end
end
