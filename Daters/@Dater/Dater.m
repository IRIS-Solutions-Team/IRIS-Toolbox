classdef Dater ...
    < DateWrapper

    methods
        function output = plus(varargin)
            output = plus@DateWrapper(varargin{:});
            if isa(output, 'DateWrapper')
                output = Dater(output);
            end
        end%


        function output = minus(varargin)
            output = minus@DateWrapper(varargin{:});
            if isa(output, 'DateWrapper')
                output = Dater(output);
            end
        end%


        function output = colon(varargin)
            output = colon@DateWrapper(varargin{:});
            if isa(output, 'DateWrapper')
                output = Dater(output);
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
    end
end

