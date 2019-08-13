classdef ExcelReference
    methods (Static)
        function varargout = parseRow(varargin)
            [varargout{1:nargout}] = decodeRow(varargin{:});
        end%


        function varargout = parseColumn(varargin)
            [varargout{1:nargout}] = decodeColumn(varargin{:});
        end%


        function varargout = parseCell(varargin)
            [varargout{1:nargout}] = decodeCell(varargin{:});
        end%


        function varargout = parseRange(varargin)
            [varargout{1:nargout}] = decodeRange(varargin{:});
        end%




        function outputRow = decodeRow(varargin)
            outputRow = nan(size(varargin));
            for i = 1 : numel(varargin)
                rowRef = varargin{i};
                if isnumeric(rowRef)
                    row = rowRef;
                elseif validate.string(rowRef)
                    row = str2num(rowRef);
                end
                outputRow(i) = row;
            end
        end%




        function outputColumn = decodeColumn(varargin)
            LETTERS = 'A' : 'Z';
            NUM_OF_LETTERS = length(LETTERS);
            outputColumn = nan(size(varargin));
            for i = 1 : nargin
                columnRef = varargin{i};
                if isnumeric(columnRef)
                    outputColumn(i) = columnRef;
                    continue
                end
                column = [ ];
                try
                    column = str2num(columnRef);
                end
                if validate.numericScalar(column)
                    outputColumn(i) = column;
                    continue
                end
                columnRef = upper(char(columnRef));
                column = 0;
                for j = 1 : length(columnRef)
                    column = column*NUM_OF_LETTERS + find(columnRef(j)==LETTERS);
                end
                outputColumn(i) = column;
            end
        end%




        %{
        function columnRange = decodeColumnRange(firstColumn, lastColumn)
            columnRange = ExcelReference.decodeColumn(firstColumn) ...
                          : ExcelReference.decodeColumn(lastColumn);
        end%
        %}




        function varargout = decodeCell(varargin)
            xlsCell = cellstr(varargin);
            xlsCell = strtrim(xlsCell);
            numOfRefs = numel(xlsCell);
            varargout = cell(size(varargin));
            inxOfValid = true(1, numOfRefs);
            for i = 1 : numOfRefs
                tokens = regexp( xlsCell{i}, '([a-z]+)(\d+)', ...
                                 'Tokens', 'Once', 'IgnoreCase' );
                inxOfValid(i) = numel(tokens)==2;
                if ~inxOfValid(i)
                    continue
                end
                row = ExcelReference.decodeRow(tokens{2});
                column = ExcelReference.decodeColumn(tokens{1});
                varargout{i} = [row, column];
            end
            if any(~inxOfValid)
                THIS_ERROR = { 'ExcelReference:InvalidExcelReference'
                               'This is not a valid Excel cell address: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       varargin{~inxOfValid} );
            end
        end%




        function [startRef, endRef] = decodeRange(xlsRange)
            xlsRange = strtrim(xlsRange);
            tokens = regexp( xlsRange, '^([a-z]+\d+)(\.\.([a-z]+\d+))?$', ...
                             'Tokens', 'Once', 'IgnoreCase');
            tokens(cellfun('isempty', tokens)) = [ ];
            tokens = strrep(tokens, '.', '');
            if numel(tokens)~=1 && numel(tokens)~=2
                THIS_ERROR = { 'ExcelReference:InvalidExcelRange'
                               'This is not a valid Excel range string: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       xlsRange );
            end
            ref = cell(size(tokens));
            [ref{:}] = ExcelReference.decodeCell(tokens{:});
            startRef = ref{1};
            if numel(ref)==2
                endRef = ref{2};
            else
                endRef = startRef;
            end
        end%



        function range = decodeRowRange(xlsRange)
            xlsRange = strtrim(xlsRange);
            tokens = regexp( xlsRange, '^(\d+)(\.\.(\d+))?$', ...
                             'Tokens', 'Once', 'IgnoreCase');
            tokens(cellfun('isempty', tokens)) = [ ];
            tokens = strrep(tokens, '.', '');
            if numel(tokens)~=1 && numel(tokens)~=2
                THIS_ERROR = { 'ExcelReference:InvalidExcelRange'
                               'This is not a valid Excel row range string: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       xlsRange );
            end
            ref = ExcelReference.decodeRow(tokens{:});
            range = ref(1);
            if numel(ref)==2
                range = range : ref(2);
            end
        end%




        function range = decodeColumnRange(xlsRange)
            xlsRange = strtrim(xlsRange);
            tokens = regexp( xlsRange, '^([a-z]+)(\.\.([a-z]+))?$', ...
                             'Tokens', 'Once', 'IgnoreCase');
            tokens(cellfun('isempty', tokens)) = [ ];
            tokens = strrep(tokens, '.', '');
            if numel(tokens)~=1 && numel(tokens)~=2
                THIS_ERROR = { 'ExcelReference:InvalidExcelRange'
                               'This is not a valid Excel column range string: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       xlsRange );
            end
            ref = ExcelReference.decodeColumn(tokens{:});
            range = ref(1);
            if numel(ref)==2
                range = range : ref(2);
            end
        end%
    end
end

