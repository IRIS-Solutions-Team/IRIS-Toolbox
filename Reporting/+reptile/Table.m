classdef Table < reptile.element.Element ...
               & reptile.element.H2Element ...
               & reptile.element.DatesElement
    properties
        Class = 'Table'
        CanBeAdded = { 'reptile.table.Series'
                       'reptile.table.Subheading' }
    end


    properties
        DataColumnClass
    end


    properties (Constant)
    end


    properties (Dependent)
        NumOfDates
        NumOfNondataColumns
        NumOfColumns
    end


    methods
        function this = Table(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            this = this@reptile.element.DatesElement(varargin{2:end});
            assignOptions(this, varargin{3:end});
        end%


        function outputElement = xmlify(this, x)
            setDataColumnClass(this);
            outputElement = createDivH2(this, x);
            table = x.createElement('table');
            header = xmlifyDateRow(this, x);
            table.appendChild(header);
            for i = 1 : this.NumOfChildren
                children = xmlify(this.Children{i}, x);
                for j = 1 : numel(children)
                    table.appendChild(children(j));
                end
            end

            outputElement.setAttribute('id', this.Id);
            outputElement.appendChild(table);
        end%


        function outputElement = xmlifyDateRow(this, x)
            outputElement = x.createElement('tr');

            hereRenderName( );
            hereRenderMark( );
            hereRenderUnit( );

            dateFormat = reptile.Options.get(this, 'DateFormat');
            dateString = DateWrapper.toCellOfChar( this.Dates, ...
                                                   'DateFormat=', dateFormat );
            for i = 1 : this.NumOfDates
                date = x.createElement('td');
                thisColumnClass = ['DateRow', this.DataColumnClass{i}];
                date.setAttribute('class', thisColumnClass);
                date.appendChild(x.createTextNode(dateString{i}));
                outputElement.appendChild(date);
            end

            return


                function hereRenderName( )
                    showNames = true;
                    if showNames
                        name = x.createElement('td');
                        name.setAttribute('class', 'DateRow NameHeader');
                        outputElement.appendChild(name);
                    end
                end%


                function hereRenderMark( )
                    showMarks = reptile.Options.get(this, 'ShowMarks');
                    if showMarks
                        mark = x.createElement('td');
                        mark.setAttribute('class', 'DateRow MarkHeader');
                        outputElement.appendChild(mark);
                    end
                end%


                function hereRenderUnit( )
                    showUnits = reptile.Options.get(this, 'ShowUnits');
                    if showUnits
                        unit = x.createElement('td');
                        unit.setAttribute('class', 'DateRow UnitHeader');
                        outputElement.appendChild(unit);
                    end
                end%
        end%


        function setDataColumnClass(this)
            this.DataColumnClass = cell(1, this.NumOfDates);
            this.DataColumnClass(:) = {''};
            list = {'Highlight', 'VlineAfter', 'VlineBefore'};
            for i = 1 : numel(list)
                userDates = reptile.Options.get(this, list{i});
                if ~isempty(userDates)
                    doubleDates = round(100*double(this.Dates));
                    doubleUserDatas = round(100*double(userDates));
                    inx = bsxfun(@eq, doubleDates, transpose(doubleUserDatas));
                    inx = any(inx, 1);
                    if any(inx)
                        this.DataColumnClass(inx) = strcat(this.DataColumnClass(inx), [' ', list{i}]);
                    end
                end
            end
        end%
    end


    methods
        function value = get.NumOfNondataColumns(this)
            showNames = true;
            showMarks = reptile.Options.get(this, 'ShowMarks');
            showUnits = reptile.Options.get(this, 'ShowUnits');
            value = nnz(showNames) ...
                  + nnz(showMarks) ...
                  + nnz(showUnits);
        end%

            
        function value = get.NumOfColumns(this)
            value = this.NumOfNondataColumns + this.NumOfDates;
        end%


        function value = get.NumOfDates(this)
            value = numel(this.Dates);
        end%
    end
end
