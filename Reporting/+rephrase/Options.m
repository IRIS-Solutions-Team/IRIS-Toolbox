classdef ( CaseInsensitiveProperties=true ) ...
         Options

    properties
        AutoData = cell.empty(1, 0)
        AxesOptions = cell.empty(1, 0)
        CleanUp = @auto
        Close = true
        ColumnNames = cell.empty(1, 0)
        DateFormat = struct( 'ii', 'P', ...
                             'yy', 'Y', ...
                             'hh', 'Y:P', ...
                             'qq', 'Y:P', ...
                             'bb', 'Y:P', ...
                             'mm', 'Y:P', ...
                             'ww', 'Y:P', ...
                             'dd', '$YYYY-Mmm-DD' ) 
        FigureOptions = cell.empty(1, 0)
        Footnote = cell.empty(1, 0)
        NumericFormat = '%.2f'
        Highlight = DateWrapper.empty(1, 0)
        CropTop = 0.035;
        CropRight = 0;
        CropBottom = 0;
        CropLeft = 0.07;
        Marks = cell.empty(1, 0)
        PageBreakAfter = false
        RowNames = cell.empty(1, 0)
        Scale = 1.1
        SingleFile = false

        % ShowHeading  Print caption as heading
        ShowHeading = @auto

        ShowMarks = @auto

        % ShowTitle  Print caption as chart title
        ShowTitle = @auto

        ShowUnits = @auto
        Style = struct.empty(0)
        Units = ''
        Visible = false
        VLine = DateWrapper.empty(1, 0)
        VLineAfter = DateWrapper.empty(1, 0)
        VLineBefore = DateWrapper.empty(1, 0)
    end


    methods
        function this = Options(varargin)
            if nargin==0
                return
            end
            if isequal(varargin{1}, @parent)
                list = properties(this);
                for i = 1 : numel(list)
                    this.(list{i}) = @parent;
                end
            end
        end%


        function this = set.AutoData(this, value)
            if isequal(value, @parent)
                this.AutoData = @parent;
                return
            end
            if iscell(value) ...
               && all(cellfun('isclass', value, 'function_handle'))
                this.AutoData = value;
                return
            elseif isa(value, 'function_handle')
                this.AutoData = { value };
                return
            end
            THIS_ERROR = { 'Reptile:InvalidAutoData'
                           'AutoData must be function handle or cell array of function handles' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end%
    end


    methods (Static)
        function value = get(element, option)
            value = element.Options.(option);
            if isequal(value, @parent)
                if isempty(element.Parent)
                    default = rephrase.Options( );
                    value = default.(option);
                    return
                else
                    value = rephrase.Options.get(element.Parent, option);
                    return
                end
            end
        end%


        function set(element, option, value)
            element.Options.(option) = value;
        end%
    end
end

