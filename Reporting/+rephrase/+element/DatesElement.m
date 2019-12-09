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
                parser = extend.InputParser('rephrase.element.DatesElement');
                parser.addRequired('Dates', @DateWrapper.validateProperDateInput);
            end
            parser.parse(dates);
            this.Dates = dates;
        end%
    end
end

