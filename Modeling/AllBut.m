classdef AllBut
    properties
        List = cell.empty(1, 0)
    end


    properties (Constant, Hidden)
        ERROR_INVALID_LIST = { 'AllBut:InvalidList'
                               'AllBut input list must be char, cellstr or string'}
    end


    methods
        function this = AllBut(varargin)
            if isempty(varargin)
                return
            end
            this.List = varargin;
        end%


        function list = convert(this, allNames)
            if ~iscellstr(allNames)
                allNames = cellstr(allNames);
            end
            list = setdiff(allNames, this.List, 'stable');
        end%


        function this = set.List(this, value)
            try
                value = cellstr(value); 
                if iscellstr(value)
                    this.List = value;
                    return
                end
            catch
                throw( exception.Base(this.ERROR_INVALID_LIST, 'error') );
            end
        end%
    end
end

