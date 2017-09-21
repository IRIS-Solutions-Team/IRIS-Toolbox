classdef XlsSheet < handle
    properties
        FileName = ''
        Sheet
        Raw = { }
        
        StartDate
        Orientation
        FirstRow
        LastRow
        FirstColumn
        LastColumn
    end
    
    
    
    
    properties (Dependent)
        NRow
        NColumn
    end
    
    
    
    
    methods
        function this = XlsSheet(fileName, sheet)
            if nargin==0
                return
            end
            if nargin==1
                sheet = 1;
            end
            [~, ~, this.Raw] = xlsread(fileName, sheet, '', 'basic');
            this.FileName = fileName;
            this.Sheet = sheet;
        end
        
        
        
        
        function prepareForReading(this, startDate, orientation, first, last)
            this.StartDate = startDate;
            this.Orientation = orientation;
            switch this.Orientation
                case 'Column'
                    this.FirstRow = first;
                    this.LastRow = last;
                case 'Row'
                    this.FirstColumn = first;
                    this.LastColumn = last;
                otherwise
                    % Do nothing.
            end     
        end
        
        
        
        
        function x = readSeries(this, time, xlsRange)
            TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
            [from, to] = parseXlsRange(this, xlsRange);
            if from(1)~=to(1) && from(2)~=to(2)
                error('XlsSheet:DataMustBeRowOrColumn', ...
                    'Time series data must be one row or one column');
            end
            cellData = this.Raw(from(1):to(1), from(2):to(2));
            nData = length(cellData);
            try %#ok<TRYNC>
                data = [ cellData{:} ];
                data = data(:);
            end
            if ~isnumeric(data) || length(data)~=nData
                error('XlsSheet:DataMustBeNumeric', ...
                    'Time series data must be numeric');
            end
            x = TIME_SERIES_CONSTRUCTOR(time, data);
        end
        
        
        
        
        function d = readDatabase(this, varargin)
            TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
            opt = passvalopt('XlsSheet.retrieveDbase', varargin{:});
            opt = datdefaults(opt, false);
            d = struct( );
            range = this.Raw(2:end, 1);
            if isequal(opt.dateformat, @excel)
                opt.dateformat = 'yyyy/mm/dd';
                range = [ range{:} ];
                range = datetime(range, 'ConvertFrom', 'Excel');
                range = datestr(range, opt.dateformat);
                range = cellstr(range);
            end
            range = str2dat(range, opt);
            data = this.Raw(2:end, :);
            ixNan = cellfun(@(x) ~isnumeric(x), data);
            data(ixNan) = { NaN };
            data = cell2mat(data);
            for iCol = 2 : this.NCol
                name = this.Raw{1, iCol};
                d.(name) = TIME_SERIES_CONSTRUCTOR(range, data(:, iCol));
            end
        end
        
        
        
        
        function set.Orientation(this, value)
            flag = ischar(value) && any(strcmp(value, {'', 'Column', 'Row'}));
            assert(flag);
            this.Orientation = value;
        end
        
        
        
        
        function set.FirstColumn(this, value)
            if ischar(value)
                value = parseXlsColumnRef(this, value);
            end
            flag = isintscalar(value) && value>=1 && value<this.NColumn; %#ok<MCSUP>
            assert(flag);
            this.FirstColumn = value;
        end
        
        
        
        
        function set.LastColumn(this, value)
            if isequal(value, 'end')
                value = this.NColumn; %#ok<MCSUP>
            elseif ischar(value)
                value = parseXlsColumnRef(this, value);
            end
            flag = isintscalar(value) && value>=1 && value<=this.NColumn; %#ok<MCSUP>
            assert(flag);
            this.LastColumn = value;
        end
        
        
        
        
        function set.FirstRow(this, value)
            if ischar(value)
                value = str2double(value);
            end
            flag = isintscalar(value) && value>=1 && value<=this.NRow; %#ok<MCSUP>
            assert(flag);
            this.FirstRow = value;
        end
        
        
        
        
        function set.LastRow(this, value)
            if isequal(value, 'end')
                value = this.NRow; %#ok<MCSUP>
            elseif ischar(value)
                value = str2double(value);
            end
            flag = isintscalar(value) && value>=1 && value<=this.NRow; %#ok<MCSUP>
            assert(flag);
            this.LastRow = value;
        end
        
        
        
        
        function x = get.NRow(this)
            x = size(this.Raw, 1);
        end
        
        
        
        function x = get.NColumn(this)
            x = size(this.Raw, 2);
        end
    
    
    
    
        function [start, finish] = parseXlsRange(this, range)
            pos = strfind(range, ':');
            if length(pos)>1
                error('XlsSheet:InvalidXlsRange', ...
                    'Invalid XLS range: %s', range);
            end
            if ~isempty(pos)
                pos = pos(1);
                chStart = range(1:pos-1);
                chFinish = range(pos+1:end);
            else
                chStart = range;
                chFinish = range;
            end
            try
                start = parseXlsRef(this, chStart);
                finish = parseXlsRef(this, chFinish);
            catch
                error('XlsSheet:InvalidXlsRange', ...
                    'Invalid XLS range: %s', range);
            end
        end
        
        
        
        
        function ref = parseXlsRef(this, chRef)
            chRef = upper(chRef);
            tkn = regexp(chRef, '([A-Z]+|#)(\d+|#)', 'tokens', 'once');
            if length(tkn)~=2 || isempty(tkn{1}) || isempty(tkn{2})
                error('XlsSheet:InvalidXlsRef', ...
                    'Invalid XLS reference: %s', chRef);
            end
            chRow = tkn{2};
            if isequal(chRow, '#')
                row = this.NRow;
            else
                row = str2num(chRow); %#ok<ST2NM>
            end
            col = parseXlsColumnRef(this, tkn{1});
            ref = [row, col];
        end
        
        
        
        
        function colRef = parseXlsColumnRef(this, chCol)
            FIRST_LETTER = double('A');
            LAST_LETTER = double('Z');
            N_LETTER = LAST_LETTER - FIRST_LETTER + 1;
            if isequal(chCol, '#')
                colRef = this.NColumn;
            else
                x = double(chCol) - FIRST_LETTER + 1;
                colRef = sum( N_LETTER.^fliplr(0:length(x)-1) .* x );
            end            
        end
    end
end
