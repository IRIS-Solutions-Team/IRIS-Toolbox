classdef Text ...
    < rephrase.Element ...
    & rephrase.Terminus

    properties (Constant)
        Type = rephrase.Type.TEXT
    end


    methods (Access=protected)
        function this = Text(varargin)
            this = this@rephrase.Element(varargin{:});
        end%
    end


    methods (Static)
        function this = fromFile(title, fileName, varargin)
            this = rephrase.Text(title, varargin{:});
            this.Content = textual.convertEndOfLines(fileread(fileName));
        end%


        function this = fromString(title, text, varargin)
            this = rephrase.Text(title, varargin{:});
            this.Content = text;
        end%
    end
end 
