classdef (Abstract) Row < handle
    properties (Dependent)
        Dates
        NumOfDates
        NumOfColumns
        DataColumnClass
    end


    methods
        function value = get.Dates(this)
            value = this.Parent.Dates;
        end%


        function value = get.NumOfDates(this)
            value = this.Parent.NumOfDates;
        end%


        function value = get.NumOfColumns(this)
            value = this.Parent.NumOfColumns;
        end%


        function value = get.DataColumnClass(this)
            value = this.Parent.DataColumnClass;
        end%
    end
end

