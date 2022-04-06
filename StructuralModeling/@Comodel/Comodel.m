classdef Comodel ...
    < Model

    methods % Public interface
        varargout = access(varargin)
    end % methods


    methods (Access=protected, Hidden)
        varargout = postparse(varargin)
        varargout = build(varargin)
    end % methods


    methods (Hidden)
        varargout = prepareZeroSteady(varargin)
    end


    methods % Interface for iris.mixin.Plan
        %(
        function slackPairs = getSlackPairsForPlan(this)
            stringify = @(x) reshape(string(x), 1, []);
            ptr = this.Pairing.Slacks;
            names = stringify(this.Quantity.Name);
            inx = ptr>0;
            slackPairs = [ ...
                reshape(names(inx), [], 1) ...
                , reshape(names(ptr(inx)), [], 1) ...
            ];
        end%
        %)
    end % methods


    methods (Static) % Static constructors
        varargout = fromFile(varargin)
    end % methods
end % classdef

