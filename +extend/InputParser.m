classdef InputParser < inputParser
    properties
        UsingDefaultsStruct struct = struct( )
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
            ix = cellfun(@(x) ischar(x) || (isstring(x) && isscalar(x)), varargin);
            varargin(ix) = cellfun(@(x) regexprep(x, '=$', ''), varargin(ix), 'UniformOutput', false);
            parse@inputParser(this, varargin{:});
            allNames = fieldnames(this.Results);
            for i = 1 : numel(allNames)
                ithName = allNames{i};
                this.UsingDefaultsStruct.(ithName) = any(strcmp(ithName, this.UsingDefaults));
            end
        end
    end
end
