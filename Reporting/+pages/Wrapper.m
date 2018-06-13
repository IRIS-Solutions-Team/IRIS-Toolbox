classdef Wrapper < handle
    properties
        PaperType(1, 1) string { validatePaperType } = "usletter"
        PaperOccupied(1, 1) double = 0.97
        PaperOrientation { validatePaperOrientation } = "landscape"
        CloseFigure(1, 1) { validateCloseFigure } = @auto
        PageHeading = gobjects(1)
        LeftHeader = gobjects(1)
        RightHeader = gobjects(1)
        LeftFooter = gobjects(1)
        RightFooter = gobjects(1)
        Print(1, 1) logical = true
        DeletePSFile(1, 1) logical = true
    end


    properties (Access=protected)
        MasterFigureHandle(1, 1) = gobjects(1)
        FiguresToClose(1, :) = gobjects(0)
        % Running fields
        FirstTitle(1, 1) string = ""
        FirstSubtitle(1, 1) string = ""
        CurrentTitle(1, 1) string = ""
        CurrentSubtitle(1, 1) string = ""
    end


    properties (Access=protected)
        FileName(1, 1) string { validateFileName } = ""
        PageCount = 0
    end


    properties (Constant, Hidden)
        CONVERT_PS_TO_PDF = iris.get('ConvertPsToPdf')

        DEFAULT_MASTER_FIGURE_NUMBER = 2147483646 

        DEFAULT_PAGE_HEADING  = { 'Position'; [0, 1, 1, 0]
                                  'String'; ""
                                  'HorizontalAlignment'; 'Center'
                                  'VerticalAlignment'; 'Top'
                                  'LineStyle'; 'None'
                                  'FontSize'; 14 }

        DEFAULT_LEFT_HEADER  = { 'Position'; [0, 1, 1, 0]
                                 'String'; ""
                                 'HorizontalAlignment'; 'Left'
                                 'VerticalAlignment'; 'Top'
                                 'LineStyle'; 'None'
                                 'FontSize'; 9 }

        DEFAULT_RIGHT_HEADER = { 'Position'; [0, 1, 1, 0]
                                 'String'; ""
                                 'HorizontalAlignment'; 'Right'
                                 'VerticalAlignment'; 'Top'
                                 'LineStyle'; 'None'
                                 'FontSize'; 9 }

        DEFAULT_LEFT_FOOTER  = { 'Position'; [0, 0, 1, 0]
                                 'String'; ""
                                 'HorizontalAlignment'; 'Left'
                                 'VerticalAlignment'; 'Bottom'
                                 'LineStyle'; 'None'
                                 'FontSize'; 9 }

        DEFAULT_RIGHT_FOOTER = { 'Position'; [0, 0, 1, 0]
                                 'String'; ""
                                 'HorizontalAlignment'; 'Right'
                                 'VerticalAlignment'; 'Bottom'
                                 'LineStyle'; 'None'
                                 'FontSize'; 9 }
    end


    properties (Dependent)
        FileNamePDF
        FileNamePS
    end


    methods
        function this = Wrapper(fileName)
            if ~isstring(fileName)
                fileName = string(fileName);
            end
            this.FileName = fileName;
            if exist(this.FileNamePS, 'file')==2
                delete(char(this.FileNamePS));
            end
            if exist(this.FileNamePDF, 'file')==2
                delete(char(this.FileNamePDF));
            end
            createMaster(this);
        end%


        function add(this, figureHandle)
            if nargin<2
                figureHandle = visual.backend.getCurrentFigureIfExists( );
            end
            if isempty(figureHandle)
                return
            end
            for i = 1 : numel(figureHandle)
                if ~isgraphics(figureHandle(i), 'Figure')
                    continue
                end
                setFigureOptions(this, figureHandle(i));
                this.PageCount = this.PageCount + 1;
                updateRunningFields(this, figureHandle(i));
                copyFromMaster( this, ...
                                figureHandle(i), ...
                                this.PageHeading, ...
                                this.DEFAULT_PAGE_HEADING );
                copyFromMaster( this, ...
                                figureHandle(i), ...
                                this.LeftHeader, ...
                                this.DEFAULT_LEFT_HEADER );
                copyFromMaster( this, ...
                                figureHandle(i), ...
                                this.RightHeader, ...
                                this.DEFAULT_RIGHT_HEADER );
                copyFromMaster( this, ...
                                figureHandle(i), ...
                                this.LeftFooter, ...
                                this.DEFAULT_LEFT_FOOTER );
                copyFromMaster( this, ...
                                figureHandle(i), ...
                                this.RightFooter, ...
                                this.DEFAULT_RIGHT_FOOTER );
                if this.Print
                    print(figureHandle(i), '-dpsc', this.FileName, '-append');
                end
            end
            for i = 1 : numel(figureHandle)
                if closeThisFigure(this, figureHandle(i))
                    this.FiguresToClose(1, end+1) = figureHandle(i);
                end
            end
        end%


        function finish(this)
            if this.Print
                this.CONVERT_PS_TO_PDF(this.FileNamePS, this.FileNamePDF);
            end
            cleanup(this);
        end%


        function cleanup(this)
            if this.DeletePSFile
                charFileNamePS = char(this.FileNamePS);
                if exist(charFileNamePS, 'file')==2
                    delete(char(this.FileNamePS));
                end
            end
            if ~isempty(this.FiguresToClose)
                for h = this.FiguresToClose
                    if isgraphics(h)
                        close(h);
                    end
                end
            end
            if isgraphics(this.MasterFigureHandle)
                close(this.MasterFigureHandle);
            end
        end%


        function delete(this)
            cleanup(this);
        end%
    end


    methods (Access=protected)
        function createMaster(this)
            masterFigureNumber = this.DEFAULT_MASTER_FIGURE_NUMBER;
            while isgraphics(masterFigureNumber) && masterFigureNumber>1
                masterFigureNumber = masterFigureNumber - 1;
            end
            this.MasterFigureHandle = figure(masterFigureNumber);
            set(this.MasterFigureHandle, 'Visible', false);
            this.PageHeading = annotation( 'TextBox', 'Visible', false, ...
                                           this.DEFAULT_PAGE_HEADING{:} );
            this.LeftHeader = annotation( 'TextBox', 'Visible', false, ...
                                          this.DEFAULT_LEFT_HEADER{:} );
            this.RightHeader = annotation( 'TextBox', 'Visible', false, ...
                                           this.DEFAULT_RIGHT_HEADER{:} );
            this.LeftFooter = annotation( 'TextBox', 'Visible', false, ...
                                          this.DEFAULT_LEFT_FOOTER{:} );
            this.RightFooter = annotation( 'TextBox', 'Visible', false, ...
                                           this.DEFAULT_RIGHT_FOOTER{:} );
        end%


        function updateRunningFields(this, figureHandle)
            title = getappdata(figureHandle, 'IRIS_PagesTitle');
            subtitle = getappdata(figureHandle, 'IRIS_PagesSubtitle');
            if ~isempty(title) && strlength(title)>0
                this.CurrentTitle = title;
                if strlength(this.FirstTitle)==0
                    this.FirstTitle = title;
                end
            end
            if ~isempty(subtitle) && strlength(subtitle)>0
                this.CurrentSubtitle = subtitle;
                if strlength(this.FirstSubtitle)==0
                    this.FirstSubtitle = subtitle;
                end
            end
        end%


        function copyFromMaster(this, figureHandle, annotationHandle, default)
            string = annotationHandle.String;
            if isempty(string)
                return
            end
            string = makeSubstitutions(this, string);
            if isempty(string)
                return
            end
            temp = annotation(figureHandle, 'TextBox', 'Visible', 'Off');
            newAnnotationHandle = copyobj(annotationHandle, get(temp, 'Parent'));
            set(newAnnotationHandle, 'String', string, 'Visible', true);
            delete(temp);
        end%


        function header = makeSubstitutions(this, header)
            pageNumber = sprintf('%g', this.PageCount);
            header = strrep(header, '$(PageNumber)', pageNumber);
            header = strrep(header, '$(TimeStamp)', string(datetime( )));
            header = strrep(header, '$(FileName)', this.FileName);
            header = strrep(header, '$(FileNamePS)', this.FileNamePS);
            header = strrep(header, '$(FileNamePDF)', this.FileNamePDF);
            listOfRunningFields = [ "FirstTitle", "FirstSubtitle", ...
                                    "CurrentTitle", "CurrentSubtitle" ];            
            for field = listOfRunningFields
                markToReplace = "$(" + field + ")";
                header = strrep(header, markToReplace, this.(field));
            end
        end%


        function flag = closeThisFigure(this, figureHandle)
            if isequal(this.CloseFigure, true)
                flag = true;
                return
            end
            if isequal(this.CloseFigure, @auto) ...
                && isequal(getappdata(figureHandle, 'IRIS_PagesCloseFigure'), true)
                flag = true;
                return
            end
            flag = false;
        end%


        function setFigureOptions(this, figureHandle)
            set( figureHandle, ...
                 'PaperType', this.PaperType, ...
                 'PaperOrientation', this.PaperOrientation );
            paperSize = get(figureHandle, 'PaperSize');
            margin = paperSize*(1 - this.PaperOccupied)/2;
            paperPosition = [margin, paperSize-2*margin];
            set(figureHandle, 'PaperPosition', paperPosition);
        end%
    end


    methods
        function fileNamePS = get.FileNamePS(this)
            fileNamePS = this.FileName + ".ps";
        end%


        function fileNamePDF = get.FileNamePDF(this)
            fileNamePDF = this.FileName + ".pdf";
        end%


        function this = set.PageHeading(this, value)
            if ischar(value) || isa(value, 'string')
                this.PageHeading.String = string(value);
                return
            elseif isgraphics(value)
                this.PageHeading = value;
            end
        end%


        function this = set.LeftHeader(this, value)
            if ischar(value) || isa(value, 'string')
                this.LeftHeader.String = string(value);
                return
            elseif isgraphics(value)
                this.LeftHeader = value;
            end
        end%


        function this = set.RightHeader(this, value)
            if ischar(value) || isa(value, 'string')
                this.RightHeader.String = string(value);
                return
            elseif isgraphics(value)
                this.RightHeader = value;
            end
        end%


        function this = set.LeftFooter(this, value)
            if ischar(value) || isa(value, 'string')
                this.LeftFooter.String = string(value);
                return
            elseif isgraphics(value)
                this.LeftFooter = value;
            end
        end%


        function this = set.RightFooter(this, value)
            if ischar(value) || isa(value, 'string')
                this.RightFooter.String = string(value);
                return
            elseif isgraphics(value)
                this.RightFooter = value;
            end
        end%
    end
end


function validateFileName(fileName)
    if strlength(fileName)==0
        return
    end
    [path, title, ext] = fileparts(fileName);
    if strlength(ext)==0
        return
    end
    error( ...
        'pages:Wrapper:validateFileName', ...
        'FileName must have no extension' ...
    );
end%


function validateCloseFigure(value)
    if isequal(value, true) || isequal(value, false) ...
        || isequal(value, @auto)
        return
    end
    error( 'pages:Wrapper:validateCloseFigure', ...
           'CloseFigure must be one of {true, false, @auto}' );
end%


function validatePaperType(value)
    list = set(0, 'DefaultFigurePaperType');
    if isempty(value) || any(strcmpi(value, list))
        return
    end
    error( 'pages:Wrapper:validatePaperType', ...
           'PaperType must be valid figure paper type string.' );
end%


function validatePaperOrientation(value)
    if ( ischar(value) || isa(value, 'string') ) ...
        && any(strcmpi(value, ["Landscape", "Portrait"]))
        return
    end
    error( 'pages:Wrapper:validateOrientation', ...
           'PaperOrientation must be ' );
end%

