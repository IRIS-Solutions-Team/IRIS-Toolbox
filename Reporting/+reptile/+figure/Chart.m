classdef Chart < reptile.element.Element ...
               & reptile.element.DatesElement
    properties
        Class = 'Chart'
        CanBeAdded = { 'reptile.figure.chart.Series' }
    end


    properties
        Handle = gobjects(1)
    end


    methods
        function this = Chart(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            this = this@reptile.element.DatesElement(varargin{2:end});
            assignOptions(this, varargin{3:end});
        end%


        function draw(this)
            resolveDates(this);
            this.Handle = visual.next( );
            axesOptions = get(this, 'AxesOptions');
            if ~isempty(axesOptions)
                axesOptions(1:2:end) = regexprep(axesOptions(1:2:end), '\W', '');
                set(this.Handle, axesOptions{:});
            end
            hold(this.Handle, 'on');
            for i = 1 : this.NumOfChildren
                draw(this.Children{i});
            end
            hold(this.Handle, 'off');
            postprocess(this);
        end%


        function postprocess(this)
            if this.ShowTitle
                title(this.Handle, this.Caption);
            end
            highlight = get(this, 'Highlight');
            if ~isempty(highlight)
                visual.highlight(this.Handle, highlight);
            end
            style = get(this, 'Style');
            if ~isempty(style)
                visual.style(this.Handle, style);
            end
        end%


        function resolveDates(this)
            if isempty(this.Dates)
                this.Dates = this.Parent.Dates;
                if isempty(this.Dates)
                    THIS_ERROR = { 'Reptile:CannotDetermineChartRange'
                                   'Cannot determine chart range' };
                    throw( exception.Base(THIS_ERROR, 'error') );
                end
            end
        end%
    end


    properties (Dependent)
        ShowTitle
    end
    

    methods
        function value = get.ShowTitle(this)
            value = get(this, 'ShowTitle');
            if isequal(value, @auto)
                value = ~isempty(this.Caption);
            end
        end%
    end
end
