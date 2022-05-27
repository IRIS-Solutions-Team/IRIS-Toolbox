classdef InputOutputData ...
    < iris.mixin.DataBlock

    properties
        IsAsynchronous = false
        InxE
        MaxShift
        TimeTrend
        InxOfInitInPresample
        MixinUnanticipated

        % FrameColumns  Column range [from, to] of the individual frames
        FrameColumns (1, :) cell = cell.empty(1, 0)

        % FrameDates  Date range [from, to] of the individual frames
        FrameDates (1, :) cell = cell.empty(1, 0)

        % FrameData  Recording of simulate.Data objects for individual frames
        FrameData (1, :) cell = cell.empty(1, 0)

        Success
        ExitFlags 
        DiscrepancyTables (1, :) cell = cell.empty(1, 0)
        Method (1, :) solver.Method = solver.Method.empty(1, 0) 

        Deviation (1, :) logical = logical.empty(1, 0)

        % PrepareOutputInfo  True if output info is requested by the user
        PrepareOutputInfo (1, 1) logical = false

        % PrepareFrameData  True if databanks for individual frames are
        % requested by the user
        PrepareFrameData (1, 1) logical = false

        % Plan  Copy of the input plan
        Plan (:, :) Plan = Plan.empty(0)

        % 
        % Options copied over from InputParser
        %

        % SolverOptions  Solver options
        SolverOptions

        % DefaultBlazer  Default blazer object for simulations
        DefaultBlazer

        % ExogenizedBlazer  Blazer object for simulations with exogenized
        % data points
        ExogenizedBlazer

        % Window  Minimum lengths of time frame required
        Window = @auto

        % SuccessOnly  Stop simulation if a time frame fails
        SuccessOnly (1, 1) logical = false

        % SparseShocks  Store shocks in sparse arrays
        SparseShocks (1, 1) logical = false
    end


    methods
        varargout = defineFrames(varargin)
        varargout = checkDeficiency(varargin)
    end
end

