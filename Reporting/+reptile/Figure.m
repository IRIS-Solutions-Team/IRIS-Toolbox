classdef Figure < reptile.element.Element ...
                & reptile.element.H2Element ...
                & reptile.element.DatesElement
    properties
        Class = 'Figure'
        CanBeAdded = { 'reptile.figure.Chart' }
    end


    properties
        Handle = gobjects(1)
        Subplot = [NaN, NaN]
        ImageSource = ''
    end


    properties (Dependent)
        NumOfDates
        NumOfSubplots
    end


    methods
        function this = Figure(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            this = this@reptile.element.DatesElement(varargin{2:end});
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('reptile.Figure');
                parser.addRequired('Subplot', @validateSubplot);
            end
            parser.parse(varargin{3});
            this.Subplot = varargin{3};
            assignOptions(this, varargin{4:end});
        end%


        function outputElement = xmlify(this)
            x = getReport(this, 'XmlDoc');
            draw(this);
            print(this);
            p = resolveDimensions(this);

            if get(this, 'Close')
                close(this.Handle);
            end

            outputElement = createDivH2(this);
            div = x.createElement('div');
            div.setAttribute('class', 'Image');
            div.setAttribute('style', sprintf('width:%gin', p.Width));
            img = x.createElement('img');
            img.setAttribute('src', this.ImageSource);
            img.setAttribute('alt', this.Caption);
            style = sprintf('width:%gin; margin:%gin %gin %gin %gin;', p.Width, p.Crop);
            img.setAttribute('style', style);
            div.appendChild(img);
            outputElement.appendChild(div);
            closeDivH2(this, outputElement);
        end%
            

        function print(this)
            set( this.Handle, ...
                 'PaperOrientation', 'Portrait', ...
                 'PaperUnits', 'Inches' );
            scale = get(this, 'Scale');
            paperSize = get(this.Handle, 'PaperSize');
            set( this.Handle, ...
                 'PaperPosition', [0, 0, fliplr(scale*paperSize)] );
            sourceFiles = getReport(this, 'SourceFiles');
            this.ImageSource = getNewFileName(sourceFiles, 'png');
            print(this.Handle, this.ImageSource, '-dpng');
            add(sourceFiles, this.ImageSource);
            if sourceFiles.SingleFile
                encodeImage(this);
            end
        end%


        function p = resolveDimensions(this)
            set(this.Handle, 'PaperUnits', 'Inches');
            paperPosition = get(this.Handle, 'PaperPosition');
            width = paperPosition(3);
            height = paperPosition(4);
            cropTop = get(this, 'CropTop');
            cropRight = get(this, 'CropRight');
            cropBottom = get(this, 'CropBottom');
            cropLeft = get(this, 'CropLeft');
            p = struct( 'Width', width, ...
                        'Crop', -[ cropTop*height
                                   cropRight*width
                                   cropBottom*height
                                   cropLeft*width ] );
        end%


        function encodeImage(this)
            fid = fopen(this.ImageSource, 'r');
            b = fread(fid);
            fclose(fid);
            c = matlab.net.base64encode(b);
            this.ImageSource = ['data:image/jpeg;base64,', c];
        end%


        function draw(this)
            visible = get(this, 'Visible');
            figureOptions = get(this, 'FigureOptions');
            this.Handle = visual.next( this.Subplot, ...
                                       'Visible', visible, ...
                                       figureOptions{:} );
            for i = 1 : this.NumOfChildren
                draw(this.Children{i});
            end
        end%
    end


    methods
        function value = get.NumOfDates(this)
            value = numel(this.Dates);
        end%


        function value = get.NumOfSubplots(this)
            value = prod(this.Subplot);
        end%


        function this = set.Subplot(this, value)
            if isnumeric(value) && numel(value)==2 ...
               && all(round(value)==value) && all(value>=1)
                this.Subplot = value;
                return
            end
            THIS_ERROR = { 'DateWrapper:InvalidFigureSubplot'
                           'Invalid value assigned to Subplot in reptile.Figure' };
            throw( exception.Base(THIS_ERROR, 'error') );
        end%
    end
end


%
% Local Functions
%


function flag = validateSubplot(value)
    flag = isnumeric(value) ...
           && numel(value)==2 ...
           && all(round(value)==value) ...
           && all(value>=1);
end%

