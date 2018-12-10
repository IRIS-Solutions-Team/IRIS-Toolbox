classdef Wrapper < handle
    properties
        DisplayName = ''
    end


    properties (SetAccess=protected)
        StartDate = DateWrapper.NaD
        EndDate = DateWrapper.NaD

        InputNames = cell.empty(1, 0)
        OutputNames = cell.emtpy(1, 0)

        Frames = scenario.Frames.empty(1, 0)
    end


    properties (Dependent)
        NumOfInputNames
        NumOfOutputNames
        NumOfPeriods
        Segments
        NumOfSegments
        NumOfExogenized
        NumOfEndogenized
        Determinacy
        NamesOfEndogenous
        NamesOfExogenous
    end


    methods
        function this = Wrapper(model, simulationRange, varargin)
            if nargin==0
                return
            end

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('scenario.Wrapper');
                parser.addRequired('Model', @(x) isa(x, 'model'));
                parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                parser.addOptional('EndDate', @auto, @(x) isequal(x, @auto) || DateWrapper.validateDateInput(x));
            end
            parser.parse(model, simulationRange, varargin{:});
            endDate = parser.EndDate;
            if isequal(endDate, @auto)
                startDate = simulationRange(1);
                endDate = simulationRange(end);
            else
                startDate = simulationRange(1);
            end

            this.Names = string( get(model, 'Names') );
            this.StartDate = startDate;
            this.EndDate = endDate;
            this.InxOfExogenizable = get(model, 'CanBeExogenized:Simulate');
            this.InxOfEndogenizable = get(model, 'CanBeEndogenized:Simulate');
            this.Frames = scenario.Frames(this.NumOfInputNames, this.NumOfOutputNames, this.NumOfPeriods);
        end%

        
        function exogenize(this, names, varargin)
            [posNames, posFromDate, posToDate, posFromFrame, posToFrame] = ...
                getPositions(this, names, varargin{:});
            inxOfValidNames = this.InxOfExogenizable(posNames);
            if any(~inxOfValidNames)
                throw( exception.Base('Scenario:Wrapper:CannotExogenizeName', 'error'), ...
                       errornames{~inxOfValidNames} );
            end
            % Call scenario.Frames
            exogenize( this.Frames, posNames, ...
                       posFromDate, posToDate, ...
                       posFromFrame, posToFrame );
        end%


        function endogenize(this, names, varargin)
            [posNames, posFromDate, posToDate, posFromFrame, posToFrame] = ...
                getPositions(this, names, varargin{:});
            inxOfValidNames = this.InxOfEndogenizable(posNames);
            if any(~inxOfValidNames)
                throw( exception.Base('Scenario:Wrapper:CannotEndogenizeName', 'error'), ...
                       names{~inxOfValidNames} );
            end
            % Call scenario.Frames
            endogenize( this.Frames, posNames, ...
                        posFromDate, posToDate, ...
                        posFromFrame, posToFrame );
        end%


        function [ posNames, ...
                   posFromDate, posToDate, ...
                   posFromFrame, posToFrame ] = getPositions( this, names, ...
                                                              fromDate, toDate, ...
                                                              fromFrame, toFrame )
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
            else
                pos = numeric.rnglen(this.StartDate, date);
            end
        end%


        function pos = getPosOfNames(this, names)
            [~, pos] = ismember(names, this.Names);
            inxOfValidNames = pos>0;
            if any(~inxOfValidNames)
                throw( exception.Base('Scenario:Wrapper:NameNotFound', 'error'), ...
                       names{~inxOfValidNames} );
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


        function names = get.NamesOfEndogenous(this)
            names = this.Names(this.InxOfExogenizable);
        end%


        function names = get.NamesOfExogenous(this)
            names = this.Names(this.InxOfEndogenizable);
        end%
    end
end

