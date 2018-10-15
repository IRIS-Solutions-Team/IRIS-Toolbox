classdef Figure < reptile.Base
    properties
        FigureHandle = gobjects(0)
    end


    properties (Constant)
        CanBeParent = {'reptile.Report'}
        HorizontalPaperMargin = 0.5
        VerticalPaperMargin = 0
    end


    methods
        function this = Figure(varargin)
            this = this@reptile.Base(varargin{:});
        end% 


        function add(this, varargin)
            add@reptile.Base(this, varargin{:}); 
        end%


        function figureHandle = plot(this, databank, figureHandle)
            this.FigureHandle = figureHandle;
            setFigureOptions(this);
            sub = this.resolveSubplot( );
            for i = 1 : this.NumChildren
                axesHandle = subplot(sub(1), sub(2), i);
                plot(this.Container{i}, databank, axesHandle);
            end
            if ~isempty(this.Caption)
                printCaption(this);
            end
        end%


        function sub = resolveSubplot(this)
            if isequal(this.Options.Subplot, @auto)
                [numOfRows, numOfCols] = visual.backend.optimizeSubplot(this.NumChildren);
                sub = [numOfRows, numOfCols];
            else
                sub = this.Options.Subplot;
            end
        end%


        function setFigureOptions(this)
            set(this.FigureHandle, 'PaperOrientation', this.Options.Orientation);
            set(this.FigureHandle, 'PaperUnits', 'inches');
            paperSize = get(this.FigureHandle, 'PaperSize');
            h = this.HorizontalPaperMargin;
            v = this.VerticalPaperMargin;
            set(this.FigureHandle, 'PaperPosition', [0, 0, paperSize] + [-h, -v, 2*h, 1.5*v]);

            set( this.FigureHandle, ...
                 'DefaultLineLineWidth', 1.5 );
        end%


        function printCaption(this)
            axesFontSize = get(this.FigureHandle, 'DefaultAxesFontSize');
            visual.heading( this.FigureHandle, this.Caption, ...
                            'FontSize=', 1.5*axesFontSize, ...
                            'FontWeight=', 'bold' );
        end%
    end
end

