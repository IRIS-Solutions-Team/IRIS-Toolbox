classdef Series ...
    < rephrase.element.Element ...
    & rephrase.element.DataElement

    properties
        Class = 'Series'
        CanBeAdded = cell.empty(1, 0)
    end


    properties
        DrawFunction
    end


    methods
        function this = Series(varargin)
            this = this@rephrase.element.Element(varargin{1:end});
            this = this@rephrase.element.DataElement(varargin{2:end});
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('rephrase.figure.chart.Series');
                addRequired(pp, 'DrawFunction', @validateDrawFunction);
            end
            pp.parse(varargin{3});
            this.DrawFunction = varargin{3};
            assignOptions(this, varargin{4:end});
        end%


        function draw(this)
            axesHandle = this.Parent.Handle;
            if iscell(this.DrawFunction)
                drawFunction = this.DrawFunction{1};
                drawOptions = this.DrawFunction(2:end);
            else
                drawFunction = this.DrawFunction;
                drawOptions = cell.empty(1, 0);
            end
            drawFunction(axesHandle, this.Dates, this.Data, drawOptions{:});
        end%
    end


    properties (Dependent)
        Dates
        NumOfDates
    end
    

    methods
        function value = get.Dates(this)
            value = this.Parent.Dates;
        end%


        function value = get.NumOfDates(this)
            value = this.Parent.NumOfDates;
        end%
    end
end


%
% Local Functions
%


function flag = validateDrawFunction(value)
    if isa(value, 'function_handle')
        flag = true;
        return
    elseif iscell(value) ...
           && isa(value{1}, 'function_handle') ...
           && iscellstr(value(2:2:end))
        flag = true;
        return
    end
    flag = false;
end%

