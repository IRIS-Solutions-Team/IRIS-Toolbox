classdef Section < rephrase.element.Element ...
                 & rephrase.element.H2Element 

    properties
        Class = 'Section'
        CanBeAdded = cell.empty(1, 0)
    end


    methods
        function this = Section(varargin)
            this = this@rephrase.element.Element(varargin{1:end});
            assignOptions(this, varargin{2:end});
        end%


        function outputElement = xmlify(this)
            outputElement = createDivH2(this);
        end%
    end
end
