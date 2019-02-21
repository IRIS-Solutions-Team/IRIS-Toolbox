classdef FootnotesElement < handle
    methods
        function outputElements = addFootnotes(this)
            newFootnotes = get(this, 'Footnote');
            if isempty(newFootnotes)
                outputElements = [ ];
                return
            end
            report = getReport(this);
            x = getReport(this, 'XmlDoc');
            if ~iscellstr(newFootnotes)
                newFootnotes = cellstr(newFootnotes);
            end
            numOfExistingFootnotes = numel(report.Footnotes);
            numOfNewFootnotes = numel(newFootnotes);
            k = numOfExistingFootnotes + (1 : numOfNewFootnotes);
            report.Footnotes = [report.Footnotes, newFootnotes];
            for i = 1 : numOfNewFootnotes
                outputElements(i) = x.createElement('sup');
                outputElements(i).setAttribute('class', 'FootnoteMark');
                if i<numOfNewFootnotes
                    format = '%g,';
                else
                    format = '%g';
                end
                footnoteNumber = numOfExistingFootnotes + i;
                footnoteMark = x.createTextNode(sprintf(format, footnoteNumber));
                outputElements(i).appendChild(footnoteMark);
            end
        end%


        function outputElement = dumpFootnotes(this)
            report = getReport(this);
            x = report.XmlDoc;
            footnoteCounter = report.FootnoteCounter;
            footnotes = report.Footnotes;
            numOfFootnotes = numel(footnotes);
            if numOfFootnotes<=footnoteCounter
                outputElement = [ ];
                return
            end
            outputElement = x.createElement('div');
            outputElement.setAttribute('class', 'Footnotes');
            ol = x.createElement('ol');
            ol.setAttribute('class', 'Footnotes');
            ol.setAttribute('start', sprintf('%g', footnoteCounter+1));
            for i = footnoteCounter+1 : numOfFootnotes
                li = x.createElement('li');
                li.setAttribute('class', 'Footnotes');
                li.appendChild(x.createTextNode(footnotes{i}));
                ol.appendChild(li);
            end
            outputElement.appendChild(ol);
            report.FootnoteCounter = numOfFootnotes;
        end%
    end


    properties (Dependent)
        NumOfFootnotes
    end


    methods
        function value = get.NumOfFootnotes(this)
            value = numel(this.Contents);
        end%
    end
end
