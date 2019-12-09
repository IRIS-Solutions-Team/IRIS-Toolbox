classdef Matrix < rephrase.element.Element ...
                & rephrase.element.H2Element

    properties
        Class = 'Matrix'
        CanBeAdded = cell.empty(1, 0)
    end


    properties
        Data
    end


    methods
        function this = Matrix(varargin)
            this = this@rephrase.element.Element(varargin{1:end});
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('rephrase.Matrix');
                parser.KeepUnmatched = true;
                parser.addRequired('Matrix', @isnumeric);
            end
            parser.parse(varargin{2:end});
            this.Data = varargin{2};
            assignOptions(this, varargin{3:end});
        end%


        function outputElement = xmlify(this)
            x = getReport(this, 'XmlDoc');
            outputElement = createDivH2(this);
            matrix = x.createElement('table');
            if this.HasColumnNames
                header = xmlifyColumnNames(this, x);
                matrix.appendChild(header);
            end
            for i = 1 : this.NumOfDataRows
                row = xmlifyDataRow(this, x, i);
                matrix.appendChild(row);
            end
            outputElement.appendChild(matrix);
        end%


        function outputElement = xmlifyColumnNames(this, x)
            outputElement = x.createElement('tr');
            hereXmlifyRowName( );
            columnNames = get(this, 'ColumnNames');
            numOfColumnNames = numel(columnNames);
            for i = 1 : this.NumOfDataColumns
                hereXmlifyColumnName( );
            end

            return

                function hereXmlifyRowName( )
                    if ~this.HasRowNames
                        return
                    end
                    rowName = x.createElement('th');
                    outputElement.appendChild(rowName);
                end%


                function hereXmlifyColumnName( )
                    name = x.createElement('th');
                    name.setAttribute('class', 'ColumnName');
                    if i<=numOfColumnNames
                        name.appendChild(x.createTextNode(columnNames{i}));
                    end
                    outputElement.appendChild(name);
                end%
        end%


        function outputElement = xmlifyDataRow(this, x, i)
            outputElement = x.createElement('tr');
            numericFormat = get(this, 'NumericFormat');
            dataStrings = arrayfun( @(x) sprintf(numericFormat, x), ...
                                    this.Data(i, :), 'UniformOutput', false );
            rowNames = get(this, 'RowNames');
            hereXmlifyRowName( );
            for j = 1 : this.NumOfDataColumns
                hereXmlifyDataPoint( );
            end

            return


                function hereXmlifyRowName( )
                    if ~this.HasRowNames
                        return
                    end
                    rowName = x.createElement('td');
                    if this.NumOfRowNames>=i
                        rowName.setAttribute('class', 'RowName');
                        rowName.appendChild(x.createTextNode(rowNames{i}));
                    end
                    outputElement.appendChild(rowName);
                end%


                function hereXmlifyDataPoint( );
                    value = x.createElement('td');
                    value.setAttribute('class', 'Data');
                    value.appendChild(x.createTextNode(dataStrings{j}));
                    outputElement.appendChild(value);
                end%
        end%

    end


    properties (Dependent)
        NumOfColumns
        NumOfDataColumns
        NumOfDataRows
        NumOfNondataColumns
        HasRowNames
        HasColumnNames
        NumOfColumnNames
        NumOfRowNames
    end


    methods
        function value = get.NumOfColumns(this)
            value = this.NumOfNondataColumns + this.NumOfDataColumns;
        end%


        function value = get.NumOfNondataColumns(this)
            value = nnz(this.HasRowNames);
        end%


        function value = get.NumOfDataColumns(this)
            value = size(this.Data, 2);
        end%


        function value = get.NumOfDataRows(this)
            value = size(this.Data, 1);
        end%


        function value = get.HasRowNames(this)
            rowNames = get(this, 'RowNames');
            value = ~isempty(rowNames);
        end%


        function value = get.NumOfRowNames(this)
            rowNames = get(this, 'RowNames');
            value = numel(rowNames);
        end%


        function value = get.HasColumnNames(this)
            columnNames = get(this, 'ColumnNames');
            value = ~isempty(columnNames);
        end%


        function value = this.NumOfColumnNames(this)
            columnNames = get(this, 'ColumnNames');
            value = numel(columnNames);
        end%
    end
end

