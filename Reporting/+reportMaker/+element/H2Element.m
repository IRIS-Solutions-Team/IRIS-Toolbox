classdef (Abstract) H2Element < reportMaker.element.FootnotesElement
    methods
        function outputElement = createDivH2(this)
            resolveShowHeading(this);

            x = getReport(this, 'XmlDoc');
            outputElement = x.createElement('div');
            class = this.Class;
            if get(this, 'PageBreakAfter')
                class = [class, ' ', 'PageBreakAfter'];
            end
            outputElement.setAttribute('class', class);
            outputElement.setAttribute('id', this.Id);

            showHeading = get(this, 'ShowHeading');
            if showHeading
                h2 = x.createElement('h2');
                h2.appendChild(x.createTextNode(this.Caption));
                footnoteMarks = addFootnotes(this);
                for i = 1 : numel(footnoteMarks)
                    h2.appendChild(footnoteMarks(i));
                end
                outputElement.appendChild(h2);
            end
        end%


        function closeDivH2(this, inputElement)
            footnotes = dumpFootnotes(this);
            if isempty(footnotes)
                return
            end
            inputElement.appendChild(footnotes);
        end%


        function resolveShowHeading(this)
            showHeading = get(this, 'ShowHeading');
            if isequal(showHeading, @auto)
                showHeading = ~isempty(this.Caption);
            end
            set(this, 'ShowHeading', showHeading);
        end%
    end
end

