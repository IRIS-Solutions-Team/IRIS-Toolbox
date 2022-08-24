classdef Matrix ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = string(rephrase.Type.MATRIX)
    end


    properties (Hidden)
        Settings_CellClasses (1, :) cell = cell.empty(1, 0)
    end


    methods
        function this = Matrix(title, input, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = input;
        end%
    end
end 

