classdef List < reportMaker.element.Element ...
              & reportMaker.element.H2Element 
    properties
        Class = 'List'
        CanBeAdded = { 'reportMaker.list.Item' }
    end


    properties
        Type 
    end


    methods
        function this = List(varargin)
            this = this@reportMaker.element.Element(varargin{1:end});
            assignOptions(this, varargin{2:end});
        end%


        function outputElement = xmlify(this)
            outputElement = createDivH2(this);
        end%
    end
end
