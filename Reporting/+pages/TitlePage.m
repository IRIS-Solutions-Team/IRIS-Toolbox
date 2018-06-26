classdef TitlePage < handle
    properties
        Title(1, 1) = gobjects(1)
        Subtitle(1, 1) = gobjects(1)
        CloseFigure(1, 1) logical = true
        Visible { validateVisible } = 'on'
    end

        
    properties (Access=protected)
        FigureHandle(1, 1) = gobjects(1)
    end


    properties (Constant, Hidden)
        DEFAULT_TITLE = { 'FontName'; 'Helvetica'
                          'FontSize'; 16
                          'Position'; [0, 2/3, 1, 0]
                          'HorizontalAlignment'; 'center'
                          'VerticalAlignment'; 'bottom'
                          'LineStyle'; 'none' }
                          
        DEFAULT_SUBTITLE = { 'FontName'; 'Helvetica'
                             'FontSize'; 16*0.8
                             'Position'; [0, 2/3-0.01, 1, 0]
                             'HorizontalAlignment'; 'center'
                             'VerticalAlignment'; 'top'
                             'LineStyle'; 'none' }
    end


    methods
        function this = TitlePage(title, subtitle)
            if nargin==0 || isempty(title)
                title = "";
            end
            if nargin<2 || isempty(subtitle)
                subtitle = "";
            end
            this.FigureHandle = figure('Units', 'Normalized', 'Visible', this.Visible);
            printTitle(this, title, subtitle);
            setappdata(this.FigureHandle, 'IRIS_PagesCloseFigure', this.CloseFigure);
            setappdata(this.FigureHandle, 'IRIS_PagesTitle', title);
            setappdata(this.FigureHandle, 'IRIS_PagesSubtitle', subtitle);
        end% 


        function printTitle(this, title, subtitle)
            if strlength(title)>0
                this.Title = annotation( this.FigureHandle, 'TextBox', ... 
                                         'String', title, ...
                                         this.DEFAULT_TITLE{:} );
            end
            if strlength(subtitle)>0
                this.Subtitle = annotation( this.FigureHandle, 'TextBox', ... 
                                            'String', subtitle, ...
                                            this.DEFAULT_SUBTITLE{:} );
            end
        end%


        function set.Visible(this, value)
            if isequal(value, true)
                value = 'on';
            elseif isequal(value, false)
                value = 'off';
            end
            this.Visible = value;
            set(this.FigureHandle, 'Visible', this.Visible);
        end%


        function set.CloseFigure(this, value)
            this.CloseFigure = value;
            setappdata(this.FigureHandle, 'IRIS_PagesCloseFigure', this.CloseFigure);
        end%
    end
end


function flag = validateVisible(value)
    flag = isequal(value, true) || isequal(value, false) ...
           || any(strcmpi(value, {'on', 'off'}));
end%

