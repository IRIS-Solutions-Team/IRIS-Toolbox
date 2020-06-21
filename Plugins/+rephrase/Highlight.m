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
    end
end

