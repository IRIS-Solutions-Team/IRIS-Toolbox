classdef Table < reptile.element.Element ...
               & reptile.element.H2Element ...
               & reptile.element.DatesElement ...
               & reptile.element.FootnotesElement
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


        function outputElement = xmlify(this)
            setDataColumnClass(this);
            resolveShowUnits(this);
            resolveShowMarks(this);

            x = getReport(this, 'XmlDoc');
            outputElement = createDivH2(this);
            table = x.createElement('table');
            header = xmlifyDateRow(this, x);
            table.appendChild(header);
            for i = 1 : this.NumOfChildren
                children = xmlify(this.Children{i});
                for j = 1 : numel(children)
                    table.appendChild(children(j));
                end
            end
            outputElement.appendChild(table);
            closeDivH2(this, outputElement);
        end%


        function outputElement = xmlifyDateRow(this, x)
            outputElement = x.createElement('tr');

            hereRenderName( );
            hereRenderMarks( );
            hereRenderUnits( );

            dateFormat = reptile.Options.get(this, 'DateFormat');
            dateString = DateWrapper.toCellstr( this.Dates, ...
                                                   'DateFormat=', dateFormat );
            for i = 1 : this.NumOfDates
                date = x.createElement('th');
                thisColumnClass = this.DataColumnClass{i};
                date.setAttribute('class', thisColumnClass);
                date.appendChild(x.createTextNode(dateString{i}));
                outputElement.appendChild(date);
            end

            return


                function hereRenderName( )
                    showNames = true;
                    if showNames
                        name = x.createElement('th');
                        outputElement.appendChild(name);
                    end
                end%


                function hereRenderMarks( )
                    showMarks = reptile.Options.get(this, 'ShowMarks');
                    if showMarks
                        marks = x.createElement('th');
                        outputElement.appendChild(marks);
                    end
                end%


                function hereRenderUnits( )
                    showUnits = reptile.Options.get(this, 'ShowUnits');
                    if showUnits
                        units = x.createElement('th');
                        outputElement.appendChild(units);
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


        function resolveShowUnits(this)
            showUnits = get(this, 'ShowUnits');
            if isequal(showUnits, @auto)    
                showUnits = false;
                for i = 1 : this.NumOfChildren
                    units = get(this.Children{i}, 'Units');
                    if ~isempty(units)
                        showUnits = true;
                        break
                    end
                end
            end
            set(this, 'ShowUnits', showUnits);
        end%


        function resolveShowMarks(this)
            showMarks = get(this, 'ShowMarks');
            if isequal(showMarks, @auto)    
                showMarks = false;
                for i = 1 : this.NumOfChildren
                    marks = get(this.Children{i}, 'Marks');
                    if ~isempty(marks)
                        showMarks = true;
                        break
                    end
                end
            end
            set(this, 'ShowMarks', showMarks);
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
