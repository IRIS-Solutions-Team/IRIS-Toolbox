classdef (Abstract) DatesElement < handle
    properties
        Dates
    end


    methods
        function this = DatesElement(dates, varargin)
            if nargin==0
                return
            end
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('reportMaker.element.DatesElement');
                parser.addRequired('Dates', @DateWrapper.validateProperDateInput);
            end
            parser.parse(dates);
            this.Dates = dates;
        end%
    end
end

