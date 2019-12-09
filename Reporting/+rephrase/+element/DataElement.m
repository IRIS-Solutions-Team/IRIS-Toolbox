classdef (Abstract) DataElement < handle

    properties
        Data
    end


    methods
        function this = DataElement(data, varargin)
            if nargin==0
                return
            end
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('rephrase.element.DataElement');
                parser.addRequired('Data', @validateData);
            end
            parser.parse(data);
            this.Data = data;
        end%
    end
end


%
% Local Functions
%


function flag = validateData(value)
    flag = isa(value, 'Series');
end%

