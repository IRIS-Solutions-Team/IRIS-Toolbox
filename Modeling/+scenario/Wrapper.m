classdef Wrapper < handle
    properties
        DisplayName(1, 1) string = ""
    end

    properties (SetAccess=protected)
        StartDate(1, 1) DateWrapper = DateWrapper.NaD
        EndDate(1, 1) DateWrapper = DateWrapper.NaD
        Names(1, :) string = string.empty(1, 0)

        IndexOfEndogenizable(1, :) logical = logical.empty(1, 0)
        IndexOfExogenizable(1, :) logical = logical.empty(1, 0)

        Frames(1, :) scenario.Frames = scenario.Frames.empty(1, 0)
    end


    properties (Dependent)
        NumOfNames
        NumOfPeriods
        Segments
        NumOfSegments
        NumOfExogenized
        NumOfEndogenized
        Determinacy
    end


    methods
        function this = Wrapper(model, simulationRange, varargin)
            if nargin==0
                return
            end

            persistent inputParser
            if isempty(inputParser)
                inputParser = extend.InputParser('scenario.Wrapper');
                inputParser.addRequired('Model', @(x) isa(x, 'model'));
                inputParser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                inputParser.addOptional('EndDate', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x));
            end
            inputParser.parse(model, simulationRange, varargin{:});
            endDate = inputParser.EndDate;
            if isequal(endDate, @auto)
                startDate = simulationRange(1);
                endDate = simulationRange(end);
            else
                startDate = simulationRange(1);
            end

            this.Names = string( get(model, 'Names') );
            this.StartDate = startDate;
            this.EndDate = endDate;
            this.IndexOfExogenizable = get(model, 'CanBeExogenized:Simulate');
            this.IndexOfEndogenizable = get(model, 'CanBeEndogenized:Simulate');
            this.Frames = scenario.Frames(this.NumOfNames, this.NumOfPeriods);
        end%

        
        function exogenize(this, names, varargin)
            [posNames, posFromDate, posToDate, posFromFrame, posToFrame] = ...
                getPositions(this, names, varargin{:});
            indexOfValidNames = this.IndexOfExogenizable(posNames);
            if any(~indexOfValidNames)
                throw( exception.Base('Scenario:Wrapper:CannotExogenizeName', 'error'), ...
                       errornames{~indexOfValidNames} );
            end
            exogenize(this.Frames, posNames, posFromDate, posToDate, posFromFrame, posToFrame);
        end%


        function endogenize(this, names, varargin)
            [posNames, posFromDate, posToDate, posFromFrame, posToFrame] = ...
                getPositions(this, names, varargin{:});
            indexOfValidNames = this.IndexOfEndogenizable(posNames);
            if any(~indexOfValidNames)
                throw( exception.Base('Scenario:Wrapper:CannotEndogenizeName', 'error'), ...
                       names{~indexOfValidNames} );
            end
            endogenize(this.Frames, posNames, posFromDate, posToDate, posFromFrame, posToFrame);
        end%


        function [posNames, posFromDate, posToDate, posFromFrame, posToFrame] = ...
            getPositions(this, names, fromDate, toDate, fromFrame, toFrame)
            numPeriods = this.NumOfPeriods;
            posNames = getPosOfNames(this, names); 
            posFromDate = getDatePosition(this, fromDate);
            posToDate = getDatePosition(this, toDate);
            if nargin>=5
                posFromFrame = getDatePosition(this, fromFrame);
            else
                posFromFrame = [ ];
            end
            if nargin>=6
                posToFrame = getDatePosition(this, toFrame);
            else
                posToFrame = [ ];
            end
        end%


        function pos = getDatePosition(this, date)
            if isequal(date, -Inf) || strcmpi(date, "Start")
                pos = 1;
            elseif isequal(date, Inf) || strcmpi(date, "End")
                pos = this.NumOfPeriods;
            elseif isa(date, 'DateWrapper')
                pos = rnglen(this.StartDate, date);
            elseif isnumeric(date) && isscalar(date) && date==round(date)
                pos = date;
            end
        end%


        function pos = getPosOfNames(this, names)
            [~, pos] = ismember(names, this.Names);
            indexOfValidNames= pos>0;
            if any(~indexOfValidNames)
                throw( exception.Base('Scenario:Wrapper:NameNotFound', 'error'), ...
                       names{~indexOfValidNames} );
            end
        end%
    end


    methods
        function n = get.NumOfNames(this)
            n = numel(this.Names);
        end%


        function n = get.NumOfPeriods(this)
            n = rnglen(this.StartDate, this.EndDate);
        end%


        function n = get.NumOfSegments(this)
            n = this.Frames.NumOfSegments;
        end%


        function segments = get.Segments(this)
            segments = this.Frames.Segments;
        end%


        function n = get.NumOfExogenized(this)
            n = this.Frames.NumOfExogenized;
        end%


        function n = get.NumOfEndogenized(this)
            n = this.Frames.NumOfEndogenized;
        end%


        function determinacy = get.Determinacy(this)
            determinacy = this.Frames.Determinacy;
        end%
    end
end
