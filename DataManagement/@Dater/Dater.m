classdef Dater ...
    < DateWrapper

    methods
        function out = plus(varargin)
            out = plus@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = minus(varargin)
            out = minus@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = uplus(varargin)
            out = uplus@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = uminus(varargin)
            out = uminus@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = colon(varargin)
            out = colon@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = max(varargin)
            out = max@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = min(varargin)
            out = min@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%


        function out = real(varargin)
            out = real@DateWrapper(varargin{:});
            if isa(out, 'DateWrapper')
                out = Dater(out);
            end
        end%
    end


    methods (Static)
        function t = today(varargin)
            t = Dater(dater.today(varargin{:}));
        end%


        function t = dd(varargin)
            t = Dater(dater.dd(varargin{:}));
        end%


        function t = hh(varargin)
            t = Dater(dater.hh(varargin{:}));
        end%


        function t = ii(varargin)
            t = Dater(dater.ii(varargin{:}));
        end%


        function t = mm(varargin)
            t = Dater(dater.mm(varargin{:}));
        end%


        function t = qq(varargin)
            t = Dater(dater.qq(varargin{:}));
        end%


        function t = yy(varargin)
            t = Dater(dater.yy(varargin{:}));
        end%


        function t = ww(varargin)
            t = Dater(dater.ww(varargin{:}));
        end%


        function t = fromSdmxString(varargin)
            t = Dater(dater.fromSdmxString(varargin{:}));
        end%


        function t = fromString(varargin)
            t = Dater(dater.fromString(varargin{:}));
        end%


        function t = fromDefaultString(varargin)
            t = Dater(dater.fromDefaultString(varargin{:}));
        end%
    end
end

