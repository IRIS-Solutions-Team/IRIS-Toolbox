classdef Text ...
    < rephrase.Terminal

    properties % (Constant)
        Type = string(rephrase.Type.TEXT)
    end


    properties (Hidden)
        Settings_ParseFormulas (1, 1) logical = true
        Settings_HighlightCodeBlocks (1, 1) logical = true
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
