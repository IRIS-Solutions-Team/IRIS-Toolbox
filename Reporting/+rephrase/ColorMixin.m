
classdef ColorMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Color = NaN
        Settings_FillColor = NaN
    end


    methods
        function this = set.Settings_Color(this, x)
            this.Settings_Color = this.ensureRgbaArray(x);
        end%


        function this = set.Settings_FillColor(this, x)
            this.Settings_FillColor = this.ensureRgbaArray(x);
        end%
    end


    methods (Static)
        function x = ensureRgbaArray(x)
            if (isstring(x) || ischar(x)) && ismember(string(x), ["transparent", "half-transparent"])
                return
            end

            if isnumeric(x)
                x = here_fromArray(x);
                return
            end

            if (ischar(x) || isstring(x))
                x = lower(string(x));
                if startsWith(x, "rgba(", "ignoreCase", true)
                    x = here_fromRgbaString(x);
                    return
                elseif startsWith(x, "rgb(", "ignoreCase", true)
                    x = here_fromRgbString(x);
                    return
                elseif startsWith(x, "#") && strlength(x)==4
                    x = here_fromShortHexString(x);
                    return
                elseif startsWith(x, "#") && strlength(x)==7
                    x = here_fromLongHexString(x);
                    return
                end
            end

            exception.error([
                "Rephrase"
                "Invalid color specification; must be RGB, RGBA, HEX, RGBA array, ""transparent"", or ""half-transparent"" "
            ]);

            function x = here_fromArray(x)
                if numel(x)==4
                    x = reshape(x, 1, []);
                    return
                end
                if numel(x)==3
                    x = [reshape(x, 1, []), 1];
                    return
                end
                if numel(x)==1
                    x = [x, x, x, 1];
                    return
                end
            end%

            function x = here_fromRgbaString(x)
                x = sscanf(x, 'rgba(%g,%g,%g,%g)');
                x = reshape(x(1:4), 1, []);
            end%

            function x = here_fromRgbString(x)
                x = sscanf(x, 'rgb(%g,%g,%g)');
                x = [reshape(x(1:3), 1, []), 1];
            end%

            function x = here_fromShortHexString(x)
                x = char(x);
                x = hex2dec({[x(2),x(2)], [x(3),x(3)], [x(4),x(4)]});
                x = [reshape(x, 1, []), 1];
            end%

            function x = here_fromLongHexString(x)
                x = char(x);
                x = hex2dec({x(2:3), x(4:5), x(6:7)});
                x = [reshape(x, 1, []), 1];
            end%
        end%
    end

end

