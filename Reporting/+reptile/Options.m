classdef ( CaseInsensitiveProperties=true ) ...
         Options

    properties
        AutoData = cell.empty(1, 0)
        AxesOptions = cell.empty(1, 0)
        CleanUp = @auto
        Close = true
        DateFormat = struct( 'ii', 'P', ...
                             'yy', 'Y', ...
                             'hh', 'Y:P', ...
                             'qq', 'Y:P', ...
                             'bb', 'Y:P', ...
                             'mm', 'Y:P', ...
                             'ww', 'Y:P', ...
                             'dd', '$YYYY-Mmm-DD' ) 
        FigureOptions = cell.empty(1, 0)
        Format = '%.2f'
        Highlight = DateWrapper.empty(1, 0)
        MarginTop = 0.035;
        MarginRight = 0;
        MarginBottom = 0;
        MarginLeft = 0.07;
        Marks = cell.empty(1, 0)
        PageBreakAfter = false
        Scale = 1.1
        SingleFile = false
        ShowMarks = true
        ShowTitle = @auto
        ShowUnits = true
        Style = struct.empty(0)
        Unit = ''
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
                    default = reptile.Options( );
                    value = default.(option);
                    return
                else
                    value = reptile.Options.get(element.Parent, option);
                    return
                end
            end
        end%
    end
end

