classdef DataProcessor
    properties
        Preprocessor ExplanatoryEquation = ExplanatoryEquation.empty(0)
        Postprocessor ExplanatoryEquation = ExplanatoryEquation.empty(0)
    end


    methods
        function pre = accessPreprocessor(this)
            pre = this.Preprocessor;
        end%


        function post = accessPostprocessor(this)
            post = this.Postprocessor;
        end%


        function this = assignPreprocessor(this, pre)
            this.Preprocessor = pre;
        end%


        function this = assignPostprocessor(this, post)
            this.Postprocessor = post;
        end%


        function varargout = preprocess(this, varargin)
            [varargout{1:nargout}] = simulate(this.Preprocessor, varargin{:});
        end%


        function varargout = postprocess(this, varargin)
            [varargout{1:nargout}] = simulate(this.Postprocessor, varargin{:});
        end%
    end

end

