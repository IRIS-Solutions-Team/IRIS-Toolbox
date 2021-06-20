classdef Highlight
    properties
        StartDate = -Inf
        EndDate = Inf
        Color (1, :) double = NaN
    end


    methods
        function this = Highlight(varargin)
            if nargin>=1
                this.StartDate = varargin{1};
            end
            if nargin>=2
                this.EndDate = varargin{2};
            end
            if nargin>=3
                color = varargin{3};
                if isstring(color) || ischar(color)
                    this.Color = color;
                elseif isnumeric(color) && ~isequaln(color, NaN)
                    this.Color = sprintf("rgba(%g, %g, %g, %g)", color);
                end
            end
        end%


        function this = set.StartDate(this, value)
            if isequal(value, -Inf)
                this.StartDate = value;
                return
            end
            if isstring(value) || ischar(value)
                this.StartDate = string(value);
                return
            end
            this.StartDate = dater.toIsoString(value);
        end%


        function this = set.EndDate(this, value)
            if isequal(value, Inf)
                this.EndDate = value;
                return
            end
            if isstring(value) || ischar(value)
                this.EndDate = string(value);
                return
            end
            this.EndDate = dater.toIsoString(value);
        end%
    end
end

