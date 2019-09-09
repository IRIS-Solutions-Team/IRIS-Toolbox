classdef Series < reportMaker.element.Element ...
                & reportMaker.element.DataElement ...
                & reportMaker.table.Row 
    properties
        Class = 'table.Series'
        CanBeAdded = cell.empty(1, 0)
    end


    properties
    end


    methods
        function this = Series(varargin)
            this = this@reportMaker.element.Element(varargin{1:end});
            this = this@reportMaker.element.DataElement(varargin{2:end});
            assignOptions(this, varargin{3:end});
        end%


        function outputElement = xmlify(this)
            x = getReport(this, 'XmlDoc');
            data = getData(this.Data, this.Dates);
            data = data(:, :);
            data = evaluateAutoData(this, data);
            numOfDataRows = size(data, 2);
            numericFormat = get(this, 'NumericFormat');
            dataStrings = arrayfun( @(x) sprintf(numericFormat, x), ...
                                    data, 'UniformOutput', false );
            if numOfDataRows==0
                outputElement = [ ];
                return
            end

            showMarks = get(this.Parent, 'ShowMarks');
            showUnits = get(this.Parent, 'ShowUnits');

            markStrings = get(this, 'Marks');
            unitString = get(this, 'Units');
            for i = 1 : numOfDataRows
                outputElement(i) = x.createElement('tr');
                outputElement(i).setAttribute('id', this.Id);
                hereXmlifyName( );
                hereXmlifyMarks( );
                hereXmlifyUnits( );
                hereXmlifyData( );
            end

            return


                function hereXmlifyName( )
                    name = x.createElement('td');
                    if i==1
                        name.setAttribute('class', 'RowName');
                        name.appendChild(x.createTextNode(this.Caption));
                    end
                    outputElement(i).appendChild(name);
                end%


                function hereXmlifyMarks( )
                    if ~showMarks
                        return
                    end
                    mark = x.createElement('td');
                    if numel(markStrings)>=i
                        mark.appendChild(x.createTextNode(markStrings{i}));
                    end
                    outputElement(i).appendChild(mark);
                end%


                function hereXmlifyUnits( )
                    if ~showUnits
                        return
                    end
                    unit = x.createElement('td');
                    if i==1
                        unit.appendChild(x.createTextNode(unitString));
                    end
                    outputElement(i).appendChild(unit);
                end%


                function hereXmlifyData( )
                    dataColumnClass = this.DataColumnClass;
                    for jj = 1 : this.NumOfDates
                        value = x.createElement('td');
                        thisColumnClass = ['Data', this.DataColumnClass{jj}];
                        value.setAttribute('class', thisColumnClass);
                        value.appendChild(x.createTextNode(dataStrings{jj, i}));
                        outputElement(i).appendChild(value);
                    end
                end%
        end%


        function data = evaluateAutoData(this, data)
            autoData = get(this, 'AutoData');
            numOfAutoData = numel(autoData);
            for i = 1 : numOfAutoData
                func = autoData{i};
                newData = func(data);
                data = [data, newData];
            end
        end%
    end
end

