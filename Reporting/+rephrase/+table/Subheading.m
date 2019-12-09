classdef Subheading < rephrase.element.Element ...
                    & rephrase.table.Row

    properties
        Class = 'table.Subheading'
        CanBeAdded = cell.empty(1, 0)
    end


    methods
        function this = Subheading(varargin)
            this = this@rephrase.element.Element(varargin{1:end});
        end%


        function outputElement = xmlify(this) 
            x = getReport(this, 'XmlDoc');
            outputElement = x.createElement('tr');
            subheading = x.createElement('td');
            subheading.setAttribute('colspan', sprintf('%g', this.NumOfColumns));
            subheading.setAttribute('class', 'Subheading');
            subheading.appendChild(x.createTextNode(this.Caption));
            outputElement.appendChild(subheading);
        end%
    end
end

