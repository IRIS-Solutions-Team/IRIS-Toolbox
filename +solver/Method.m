classdef Method < int8
    enumeration
        INVALID     (-1)
        NONE        ( 0)
        FIRST_ORDER ( 1)
        SELECTIVE   ( 2)
        STACKED     ( 3)
        STATIC      ( 4)
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
            elseif strcmpi(input, 'Static')
                this = solver.Method.STATIC;
            else
                this = solver.Method.INVALID;
            end
        end%
    end
end


