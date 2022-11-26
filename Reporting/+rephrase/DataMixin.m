classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Conditional 
        Settings_Transform = []
        Settings_NaN (1, 1) = string(char(8943))
        Settings_Round (1, 1) double = Inf
    end


    methods 
        function content = finalizeSeriesData(this, input)
            %(
            % Keep expression string and add to the data requests
            if isstring(input) || ischar(input) || iscellstr(input)
%                 content = textual.stringify(input);
%                 this.DataRequests = union(this.DataRequests, content, 'stable');
                error("Not implemented");
                return
            end

            parent = this.Parent;
            dates = getFinalDates(parent);
            if isa(input, 'Series')
                input = transform(this, input);
                values = getData(input, dates);
                values = values(:, 1);
            elseif isa(input, 'struct')
                values = transform(input.Values);
                dates = input.Dates;
            end
            [dates, values] = parent.finalizeSeriesData(dates, values);
            values = round(this, values);

            content = struct('Dates', [], 'Values', []);
            content.Dates = dates;
            content.Values = values;
            for n = ["Dates", "Values"]
                content.(n) = reshape(content.(n), 1, []);
                if isscalar(content.(n)) && ~iscell(content.(n))
                    content.(n) = {content.(n)};
                end
            end
            %)
        end%


        function values = round(this, values)
            %(
            if this.Settings_Round<Inf
                values = round(values, round(this.Settings_Round));
            end
            %)
        end%


        function x = transform(this, x)
            if isa(this.Settings.Transform, 'function_handle')
                x = this.Settings.Transform(x);
            end
        end%
    end

end

