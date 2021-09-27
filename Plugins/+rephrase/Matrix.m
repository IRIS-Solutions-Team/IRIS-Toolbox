classdef Matrix ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties % (Constant)
        Type = rephrase.Type.MATRIX
    end


    methods
        function this = Matrix(title, input, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = input;
        end%
    end
end 

