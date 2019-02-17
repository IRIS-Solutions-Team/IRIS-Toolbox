classdef (Abstract) H2Element < handle
    methods
        function outputElement = createDivH2(this, x)
            outputElement = x.createElement('div');
            outputElement.setAttribute('class', this.Class);
            setStyle(this, outputElement);

            h2 = x.createElement('h2');
            h2.setAttribute('class', this.Class);
            h2.appendChild(x.createTextNode(this.Caption));
            outputElement.appendChild(h2);
        end%


        function style = setStyle(this, div)
            style = '';
            if get(this, 'PageBreakAfter')
                style = [style, ' page-break-after: always;'];
            end
            if ~isempty(style)
                div.setAttribute('style', style);
            end
        end%
    end
end
        
