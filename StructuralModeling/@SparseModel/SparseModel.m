classdef SparseModel < Model
    methods
        function this = SparseModel(varargin)
            this = this@Model(varargin{:});
        end%
    end


    methods (Access=protected, Hidden)
        function value = getPreallocateFunc(this)
            value = @(varargin) [];
        end%

        varargout = solveFirstOrder(varargin)
        %varargout = diffFirstOrder(varargin)
    end


    methods
        varargout = beenSolved(varargin)
    end


    methods (Static)
        function this = fromFile(varargin)
            this = SparseModel(varargin{:}, "linear", true, "makeBkw", @all, "symbDiff", ~true);
        end%
    end
end

