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




        function varargout = decodeRow(varargin)
            varargout = cell(size(varargin));
            for i = 1 : numel(varargin)
                rowRef = varargin{i};
                if isnumeric(rowRef)
                    row = rowRef;
                elseif ischar(rowRef) || isa(rowRef, 'string')
                    row = str2num(rowRef);
                end
                varargout{i} = row;
            end
        end%




        function varargout = decodeColumn(varargin)
            LETTERS = 'A' : 'Z';
            NUM_OF_LETTERS = length(LETTERS);
            varargout = cell(size(varargin));
            for i = 1 : numel(varargin)
                columnRef = varargin{i};
                if isnumeric(columnRef)
                    varargout{i} = columnRef;
                    continue
                end
                column = [ ];
                try
                    column = str2num(columnRef);
                end
                if Valid.numericScalar(column)
                    varargout{i} = column;
                    continue
                end
                columnRef = upper(char(columnRef));
                column = 0;
                for j = 1 : length(columnRef)
                    column = column*NUM_OF_LETTERS + find(columnRef(j)==LETTERS);
                end
                varargout{i} = column;
            end
        end%




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
    end
end

