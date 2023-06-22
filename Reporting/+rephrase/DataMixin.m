classdef (Abstract) DataMixin ...
    < matlab.mixin.Copyable

    properties (Hidden)
        Settings_Conditional 
        Settings_Transform = []
        Settings_NaN (1, 1) = string(char(8943))
        Settings_Round (1, 1) double = Inf
        Settings_ColumnClass (1, :) string = string.empty(1, 0)
        Settings_RemoveMissing (1, 1) logical = false
    end


    methods 
        function finalize(this)
            if isa(this.Settings.Transform, 'function_handle')
                this.Settings.Transform = func2str(this.Settings.Transform);
            end
            this.Settings.ColumnClass = rephrase.fixScalar(this.Settings.ColumnClass);
        end%


        function content = finalizeSeriesData(this, input, startDate, endDate)
            %(
            % Keep expression string and add to the data requests
            if isstring(input) || ischar(input) || iscellstr(input)
%                 content = textual.stringify(input);
%                 this.DataRequests = union(this.DataRequests, content, 'stable');
                error("String inputs into Series elements not implemented");
                return
            end

            parent = this.Parent;
            if isa(input, 'Series')
                dates = getFinalDates(parent);
                input = transform(this, input);
                values = getData(input, dates);
                values = values(:, 1);
            elseif isa(input, 'struct')
                dates = double(input.Dates);
                values = transform(this, input.Values);
            end
            values = round(this, values);

            if this.Settings_RemoveMissing
                inxNaN = isnan(values);
                dates(inxNaN) = [];
                values(inxNaN) = [];
            end

            content = struct('Dates', [], 'Values', []);
            content.Dates = dates;
            content.Values = values;

            content = parent.finalizeSeriesData(content);

            for n = ["Dates", "Values"]
                content.(n) = reshape(content.(n), 1, []);
                content.(n) = rephrase.fixScalar(content.(n));
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
            if isa(this.Settings_Transform, 'function_handle')
                x = this.Settings_Transform(x);
            end
        end%
    end

end

