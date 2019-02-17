classdef Series < reptile.element.Element ...
                & reptile.element.DataElement ...
                & reptile.table.Row 
    properties
        Class = 'table.Series'
        CanBeAdded = cell.empty(1, 0)
    end


    properties
    end


    methods
        function this = Series(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            this = this@reptile.element.DataElement(varargin{2:end});
            assignOptions(this, varargin{3:end});
        end%


        function outputElement = xmlify(this, x)
            data = getData(this.Data, this.Dates);
            data = data(:, :);
            data = evaluateAutoData(this, data);
            numOfDataRows = size(data, 2);
            format = get(this, 'Format');
            dataString = arrayfun( @(x) sprintf(format, x), ...
                                   data, ...
                                   'UniformOutput', false );
            if numOfDataRows==0
                outputElement = [ ];
                return
            end

            showMarks = get(this, 'ShowMarks');
            showUnits = get(this, 'ShowUnits');
            markStrings = get(this, 'Marks');
            unitString = get(this, 'Unit');
            for i = 1 : numOfDataRows
                outputElement(i) = x.createElement('tr');
                hereRenderName( );
                hereRenderMark( );
                hereRenderUnit( );
                hereRenderData( );
            end

            return


                function hereRenderName( )
                    name = x.createElement('td');
                    if i==1
                        name.appendChild(x.createTextNode(this.Caption));
                    end
                    outputElement(i).appendChild(name);
                end%


                function hereRenderMark( )
                    if ~showMarks
                        return
                    end
                    mark = x.createElement('td');
                    if numel(markStrings)>=i
                        mark.appendChild(x.createTextNode(markStrings{i}));
                    end
                    outputElement(i).appendChild(mark);
                end%


                function hereRenderUnit( )
                    if ~showUnits
                        return
                    end
                    unit = x.createElement('td');
                    if i==1
                        unit.appendChild(x.createTextNode(unitString));
                    end
                    outputElement(i).appendChild(unit);
                end%


                function hereRenderData( )
                    dataColumnClass = this.DataColumnClass;
                    for jj = 1 : this.NumOfDates
                        value = x.createElement('td');
                        thisColumnClass = ['Data', this.DataColumnClass{jj}];
                        value.setAttribute('class', thisColumnClass);
                        value.appendChild(x.createTextNode(dataString{jj, i}));
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

