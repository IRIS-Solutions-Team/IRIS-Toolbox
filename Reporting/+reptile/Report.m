classdef Report < reptile.Base
    properties (Constant)
        CanBeParent = cell.empty(1, 0)
    end


    properties
        FileName = char.empty(1, 0)
        Code = char.empty(1, 0)
        FigureHandles = gobjects(1, 0)
    end


    methods
        function this = Report(varargin)
            this = this@reptile.Base(varargin{:});
        end% 


        function add(this, varargin)
            add@reptile.Base(this, varargin{:}); 
        end%


        function plot(this, databank, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('reptile.Report.plot');
                parser.addRequired('Report', @(x) isa(x, 'reptile.Report'));
                parser.addRequired('Databank', @isstruct);
                parser.addParameter('Screen', true, @(x) isequal(x, true) || isequal(x, false));
                parser.addParameter('PDF', false, @(x) isequal(x, false) || (ischar(x) && ~isempty(x)));
                parser.addParameter('CloseFigures', false, @(x) isequal(x, false) || isequal(x, true));
            end
            parser.parse(this, databank, varargin{:});
            opt = parser.Options;
            figureOpt = createFigureOptions(this, opt);
            this.FigureHandles = gobjects(1, this.NumChildren);
            for i = 1 : this.NumChildren
                if isa(this.Container{i}, 'reptile.Figure')
                    this.FigureHandles(i) = figure(figureOpt{:});
                    plot(this.Container{i}, databank, this.FigureHandles(i));
                end
            end
            if ~isequal(opt.PDF, false)
                printPDF(this, opt.PDF);
            end
            if opt.CloseFigures
                closeFigures(this, opt);
            end
        end%


        function figureOpt = createFigureOptions(this, opt)
            figureOpt = cell.empty(1, 0);
            if opt.Screen
                figureOpt = [figureOpt, {'Visible', 'On'}];
            else
                figureOpt = [figureOpt, {'Visible', 'Off'}];
            end
        end%


        function closeFigures(this)
            for i = 1 : numel(this.FigureHandles)
                try
                    close(this.FigureHandles(i));
                end
            end
        end%


        function printPDF(this, fileName)
            [filePath, fileTitle, fileExt] = fileparts(fileName);
            if isempty(fileExt)
                fileExt = '.pdf';
            end
            for i = 1 : numel(this.FigureHandles)
                ithFileTitle = sprintf('%s_%g', fileTitle, i);
                ithFileName = fullfile(filePath, [ithFileTitle, fileExt]);
                print(this.FigureHandles(i), '-dpdf', ithFileName);
            end
        end%
    end
end
