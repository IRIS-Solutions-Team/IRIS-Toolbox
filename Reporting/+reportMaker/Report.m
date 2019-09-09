classdef Report < reptile.element.Element
    properties
        Class = 'Report'
        CanBeAdded = { 'reptile.Section'
                       'reptile.Table'
                       'reptile.Figure'
                       'reptile.Matrix' }
    end


    properties
        XmlDoc
        FileName = ''
        StyleSheet = fullfile(iris.root( ), 'Reporting', '+reptile', 'default.css')
        SourceFiles = reptile.SourceFiles.empty(1, 0)
        Footnotes = cell.empty(1, 0)
        FootnoteCounter = 0
    end


    methods
        function this = Report(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            this.FileName = varargin{2};
            assignOptions(this, varargin{3:end});
            singleFile = get(this, 'SingleFile');
            this.SourceFiles = reptile.SourceFiles(this.FileName, singleFile);
        end%


        function [fileName, code] = publish(this, varargin)
            code = xmlify(this);
            code = ['<!DOCTYPE html> ', newline( ), code];
            char2file(code, this.FileName);
            fileName = this.FileName;
            if this.CleanUp
                cleanup(this.SourceFiles);
            end
        end%


        function c = xmlify(this, outputFileName)
            x = com.mathworks.xml.XMLUtils.createDocument('html');
            this.XmlDoc = x;
            html = x.getDocumentElement( );
            hereXmlifyHead( );
            hereXmlifyBody( );
            c = xmlwrite(x); 

            return


            function hereXmlifyHead( )
                head = x.createElement('head');
                title = x.createElement('title');
                title.appendChild(x.createTextNode(this.Caption));
                style = x.createElement('style');
                style.setAttribute('type', 'text/css');
                styleSheet = file2char(this.StyleSheet);
                style.appendChild(x.createTextNode(styleSheet));
                head.appendChild(title);
                head.appendChild(style);
                html.appendChild(head);
            end%


            function hereXmlifyBody( )
                body = x.createElement('body');
                div = x.createElement('div');
                div.setAttribute('class', 'Report');
                div.setAttribute('id', this.Id);
                h1 = x.createElement('h1');
                h1.setAttribute('class', 'Report');
                h1.appendChild(x.createTextNode(this.Caption));
                div.appendChild(h1);
                body.appendChild(div);
                for i = 1 : this.NumOfChildren
                    child = xmlify(this.Children{i});
                    body.appendChild(child);
                end
                html.appendChild(body);
            end%
        end%
    end


    properties (Dependent)
        CleanUp
    end


    methods
        function value = get.CleanUp(this)
            value = get(this, 'CleanUp');
            if isequal(value, @auto)
                value = this.SourceFiles.SingleFile;
            end
        end%


        function this = set.FileName(this, value)
            [p, t, x] = fileparts(value);
            if isempty(x)
                x = '.html';
                value = fullfile(p, [t, x]);
            end
            this.FileName = value;
        end%
    end
end
