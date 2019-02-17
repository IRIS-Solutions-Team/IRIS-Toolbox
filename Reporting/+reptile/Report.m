classdef Report < reptile.element.Element
    properties
        Class = 'Report'
        CanBeAdded = {'reptile.Table', 'reptile.Figure' }
    end


    properties
        FileName = ''
        StyleSheet = fullfile(iris.root( ), 'Reporting', '+reptile', 'default.css')
    end


    methods
        function this = Report(varargin)
            this = this@reptile.element.Element(varargin{1:end});
            fileName = varargin{2};
            assignOptions(this, varargin{3:end});
            [p, t, x] = fileparts(fileName);
            if isempty(x)
                x = '.html';
                fileName = fullfile(p, [t, x]);
            end
            this.FileName = fileName;
            singleFile = get(this, 'SingleFile');
            this.SourceFiles = reptile.SourceFiles(this.FileName, singleFile);
        end%


        function fileName = publish(this, varargin)
            c = xmlify(this);
            c = ['<!DOCTYPE html> ', newline( ), c];
            char2file(c, this.FileName);
            fileName = this.FileName;
            if this.CleanUp
                cleanup(this.SourceFiles);
            end
        end%


        function c = xmlify(this, outputFileName)
            x = com.mathworks.xml.XMLUtils.createDocument('html');
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
                    child = xmlify(this.Children{i}, x);
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
    end
end
