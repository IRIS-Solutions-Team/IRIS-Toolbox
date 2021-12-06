classdef ExcelReference
    methods (Static)
        function varargout = parseRow(varargin)
            [varargout{1:nargout}] = ExcelReference.decodeRow(varargin{:});
        end%


        function varargout = parseColumn(varargin)
            [varargout{1:nargout}] = ExcelReference.decodeColumn(varargin{:});
        end%


        function varargout = parseCell(varargin)
            [varargout{1:nargout}] = ExcelReference.decodeCell(varargin{:});
        end%


        function varargout = parseRange(varargin)
            [varargout{1:nargout}] = ExcelReference.decodeRange(varargin{:});
        end%




        function outputRow = decodeRow(varargin)
            outputRow = [ ];
            for i = 1 : numel(varargin)
                rowRef = varargin{i};
                if isnumeric(rowRef)
                    row = rowRef;
                elseif isstring(rowRef)
                    row = double(row);
                elseif validate.string(rowRef)
                    row = str2num(rowRef);
                end
                outputRow = [outputRow, reshape(row, 1, [ ])];
            end
        end%


        function outputColumn = decodeColumn(varargin)
            LETTERS = 'A' : 'Z';
            NUM_LETTERS = numel(LETTERS);
            outputColumn = [ ];
            for i = 1 : nargin
                columnRef = varargin{i};
                if isnumeric(columnRef)
                    outputColumn = [outputColumn, reshape(columnRef, 1, [ ])];
                    continue
                end
                column = [ ];
                try
                    column = double(string(columnRef));
                end
                if isnumeric(column) && ~isempty(column) && all(isfinite(column))
                    outputColumn = [outputColumn, reshape(column, 1, [ ])];
                    continue
                end
                columnRef = upper(cellstr(columnRef));
                for j = 1 : numel(columnRef)
                    column = 0;
                    for k = 1 : numel(columnRef{j}) 
                        column = column*NUM_LETTERS + find(columnRef{j}(k)==LETTERS);
                    end
                    outputColumn = [outputColumn, column];
                end
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
            numRefs = numel(xlsCell);
            varargout = cell(size(varargin));
            inxValid = true(1, numRefs);
            for i = 1 : numRefs
                tokens = regexp( ...
                    xlsCell{i}, '([a-z]+)(\d+)' ...
                    , 'Tokens', 'Once', 'IgnoreCase' ...
                );
                inxValid(i) = numel(tokens)==2;
                if ~inxValid(i)
                    continue
                end
                row = ExcelReference.decodeRow(tokens{2});
                column = ExcelReference.decodeColumn(tokens{1});
                varargout{i} = [row, column];
            end
            if any(~inxValid)
                thisError = [
                    "ExcelReference:InvalidExcelReference"
                    "This is not a valid Excel cell address: %s "
                ];
                throw(exception.Base(thisError, 'error'), varargin{~inxValid});
            end
        end%




        function [startRef, endRef] = decodeRange(xlsRange, sizeBuffer)
            xlsRange = strip(xlsRange);
            tokens = regexp( ...
                xlsRange, "^(([a-z]+|\|)(\d+|_))(\.\.(([a-z]+|\|)(\d+|_)))?$" ...
                , "Tokens", "Once", "IgnoreCase" ...
            );
            tokens(cellfun(@isempty, tokens)) = [ ];
            tokens = replace(tokens, ".", "");
            if any(contains(tokens, ["|", "_"]))
                tokens = replace(tokens, "|", string(sizeBuffer(2)));
                tokens = replace(tokens, "_", string(sizeBuffer(1)));
            end
            if numel(tokens)~=1 && numel(tokens)~=2
                thisError = [
                    "ExcelReference:InvalidExcelRange"
                    "This is not a valid Excel range string: %s " 
                ];
                throw(exception.Base(thisError, 'error'), xlsRange);
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



        function range = decodeRowRange(xlsRange, sizeBuffer)
            xlsRange = strtrim(xlsRange);
            tokens = regexp( ...
                xlsRange, "^(\d+|_)(\.\.(\d+|_))?$" ...
                , "Tokens", "Once", "IgnoreCase" ...
            );
            tokens(cellfun(@isempty, tokens)) = [ ];
            tokens = replace(tokens, ".", "");
            if any(contains(tokens, ["|", "_"]))
                tokens = replace(tokens, "|", string(sizeBuffer(2)));
                tokens = replace(tokens, "_", string(sizeBuffer(1)));
            end
            if numel(tokens)~=1 && numel(tokens)~=2
                thisError = [
                    "ExcelReference:InvalidExcelRange"
                    "This is not a valid Excel row range string: %s "
                ];
                throw(exception.Base(thisError, 'error'), xlsRange);
            end
            ref = ExcelReference.decodeRow(tokens{:});
            range = ref(1);
            if numel(ref)==2
                range = range : ref(2);
            end
        end%




        function range = decodeColumnRange(xlsRange, sizeBuffer)
            xlsRange = strtrim(xlsRange);
            tokens = regexp( ...
                xlsRange, '^([a-z]+|\|)(\.\.([a-z]+|\|))?$' ...
                , 'Tokens', 'Once', 'IgnoreCase' ...
            );
            tokens(cellfun(@isempty, tokens)) = [ ];
            tokens = strrep(tokens, ".", "");
            if any(contains(tokens, ["|", "_"]))
                tokens = replace(tokens, "|", string(sizeBuffer(2)));
            end
            if numel(tokens)~=1 && numel(tokens)~=2
                thisError = [
                    "ExcelReference:InvalidExcelRange"
                    "This is not a valid Excel column range string: %s "
                ];
                throw(exception.Base(thisError, 'error'), xlsRange);
            end
            ref = ExcelReference.decodeColumn(tokens{:});
            range = ref(1);
            if numel(ref)==2
                range = range : ref(2);
            end
        end%
    end
end

