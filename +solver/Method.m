classdef Method < int8
    enumeration
        INVALID     (-1)
        NONE        ( 0)
        FIRSTORDER ( 1)
        SELECTIVE   ( 2)
        STACKED     ( 3)
        PERIOD      ( 5)
        STEADY      ( 6)
    end


    methods
        function func = simulateFunction(this)
            switch this
                case solver.Method.FIRSTORDER
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


        function flag = needsFirstOrderSolution(this, model, initial, terminal)
            if this==solver.Method.FIRSTORDER || this==solver.Method.SELECTIVE
                flag = true;
            elseif this==solver.Method.PERIOD || this==solver.Method.STACKED
                maxLead = get(model, "maxLead");
                flag = startsWith(initial, "firstOrder", "ignoreCase", true) ...
                    || (startsWith(terminal, "firstOrder", "ignoreCase", true) && maxLead>0);
            else
                flag = false;
            end
        end%


        function flag = needsFirstOrderTerminal(this, model, terminal)
            if this==solver.Method.PERIOD || this==solver.Method.STACKED
                maxLead = get(model, "maxLead");
                flag = startsWith(terminal, "firstOrder", "ignoreCase", true) && maxLead>0;
            else
                flag = false;
            end
        end%


        function flag = needsIgnoreShocks(this)
            %
            % Only plain-vanilla first-order simulators are used in STACKED
            % and PERIOD methods
            %
            flag = this==solver.Method.PERIOD || this==solver.Method.STACKED;
        end%
    end
end

