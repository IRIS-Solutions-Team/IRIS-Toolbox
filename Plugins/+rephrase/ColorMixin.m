
classdef ColorMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Color = NaN
        Settings_FillColor = NaN
    end


    methods
        function this = set.Settings_Color(this, x)
            this.Settings_Color = this.convertColor(x);
        end%


        function this = set.Settings_FillColor(this, x)
            this.Settings_FillColor = this.convertColor(x);
        end%
    end


    methods (Static)
        function x = convertColor(x)
            numX = numel(x);
            if isnumeric(x) && (numX==3 || numX==4)
                if all(x(1:3)>=0 & x(1:3)<=1)
                    x(1:3) = 255*x(1:3);
                end
                if numX==3
                    x = sprintf("rgb(%g,%g,%g)", x);
                else
                    x = sprintf("rgba(%g,%g,%g,%g)", x);
                end
                return
            end
            x = string(x);
        end%
    end

end

