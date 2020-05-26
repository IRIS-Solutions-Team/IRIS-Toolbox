classdef InputOutputData ...
    < shared.DataBlock

    properties
        IsAsynchronous = false
        Blazers
        InxE
        MaxShift
        TimeTrend
        InxOfInitInPresample
        MixinUnanticipated
        Frames
        FrameDates
        Success
        ExitFlags = solver.ExitFlag.empty(1, 0)
        DiscrepancyTables = cell.empty(1, 0)
        Method = solver.Method.empty(1, 0) 
        Deviation = logical.empty(1, 0)
        NeedsEvalTrends = logical.empty(1, 0)
        PrepareOutputInfo = false
        Plan = Plan.empty(0)


        % __Options Copied over From Input Parser__

        % Solver  Solver options
        SolverOptions = solver.Options.empty(0)

        % Window  Minimum lengths of time frame required
        Window = @auto

        % SuccessOnly  Stop simulation if a time frame fails
        SuccessOnly = false

        % Store shocks in sparse arrays
        SparseShocks = false

        % Initial  Choose input data or first-order simulation for starting values
        Initial = 'Data'
    end


    methods
        varargout = defineFrames(varargin)
        varargout = checkDeficiency(varargin)
    end
end

