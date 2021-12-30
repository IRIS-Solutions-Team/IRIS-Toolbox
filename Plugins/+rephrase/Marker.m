classdef Marker ...
    < rephrase.Element ...
    & rephrase.Terminus ...
    & rephrase.Data

    properties % (Constant)
        Type = rephrase.Type.MARKER
    end


    methods
        function this = Marker(title, x, y, varargin)
            this = this@rephrase.Element(title, varargin{:});
            this.Content = struct( );
            this.Content.X = x;
            this.Content.Y = y;
        end%
    end

end

