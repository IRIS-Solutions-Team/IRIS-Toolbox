classdef Matrix ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = rephrase.Type.MATRIX
    end


    methods
        function this = Matrix(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%
    end
end 

