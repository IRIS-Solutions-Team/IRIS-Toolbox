classdef Method < int8
    enumeration
        INVALID     (-1)
        NONE        ( 0)
        FIRST_ORDER ( 1)
        SELECTIVE   ( 2)
        STACKED     ( 3)
        PERIOD      ( 5)
    end


    methods
        function func = simulateFunction(this)
            switch this
                case solver.Method.FIRST_ORDER
                    func = @Model.simulateFirstOrder;
                case solver.Method.SELECTIVE
                    func = @Model.simulateSelective;
                case {solver.Method.STACKED, solver.Method.PERIOD}
                    func = @Model.simulateStacked;
                case solver.Method.NONE
                    func = @Model.simulateNone;
                otherwise
                    func = [ ];
            end
        end%
    end


    methods (Static)
        function flag = validate(input)
            if isa(input, 'solver.Method') ...
               && input~=solver.Method.INVALID ...
               && input~=solver.Method.NONE
                flag = true;
                return
            end
            if ~ischar(input) && ~isa(input, 'string')
                flag = false;
                return
            end
            flag = solver.Method.parse(input)~=solver.Method.INVALID;
        end%


        function this = parse(input)
            if isa(input, 'solver.Method')
                this = input;
                return
            end
            if strcmpi(input, 'None')
                this = solver.Method.NONE;
            elseif strcmpi(input, 'FirstOrder')
                this = solver.Method.FIRST_ORDER;
            elseif strcmpi(input, 'Selective')
                this = solver.Method.SELECTIVE;
            elseif strcmpi(input, 'Stacked')
                this = solver.Method.STACKED;
            elseif strcmpi(input, 'Period')
                this = solver.Method.PERIOD;
            else
                this = solver.Method.INVALID;
            end
        end%
    end
end


