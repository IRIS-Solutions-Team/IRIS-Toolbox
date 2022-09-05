classdef Marker ...
    < rephrase.Terminal ...
    & rephrase.DataMixin

    properties % (Constant)
        Type = string(rephrase.Type.MARKER)
    end


    methods
        function this = Marker(title, x, y, varargin)
            this = this@rephrase.Terminal(title, varargin{:});
            this.Content = struct( );
            this.Content.X = x;
            this.Content.Y = y;
        end%
    end

end

