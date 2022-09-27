
classdef Pager ...
    < rephrase.Container

    properties % (Constant)
        Type = string(rephrase.Type.PAGER)
    end


    properties (Hidden)
        Settings_StartPage = 0
    end


    properties (Constant, Hidden)
        PossibleChildren = [
            string(rephrase.Type.CHART)
            string(rephrase.Type.CURVECHART)
            string(rephrase.Type.GRID)
            string(rephrase.Type.MATRIX)
            string(rephrase.Type.PAGER)
            string(rephrase.Type.SECTION)
            string(rephrase.Type.SERIESCHART)
            string(rephrase.Type.TABLE)
            string(rephrase.Type.TEXT)
        ]
    end


    methods
        function this = Pager(title, varargin)
            this = this@rephrase.Container(title, varargin{:});
            this.Content = cell.empty(1, 0);
        end%
    end
end 

