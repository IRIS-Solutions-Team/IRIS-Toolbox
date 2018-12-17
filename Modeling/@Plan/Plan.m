classdef Plan
    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
        BaseStart = double.empty(0)
        BaseEnd = double.empty(0)
        ExtendedStart = double.empty(0)
        ExtendedEnd = double.empty(0)
        DefaultAnticipate = true

        AnticipationStatusOfExogenous = logical.empty(0)
        Endogenized = logical.empty(0, 0, 0)
        Exogenized = logical.empty(0, 0, 0)
    end


    methods
        function this = Plan(varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.Plan');
                parser.addRequired('Model', @(x) isa(x, 'model.Plan'));
                parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                parser.addParameter('Anticipate', true, @(x) isequal(x, true) || isequal(x, false));
            end
            if nargin==0
                return
            end
            parser.parse(varargin{:});
            this.BaseStart = double(parser.Results.SimulationRange(1));
            this.BaseEnd = double(parser.Results.SimulationRange(end));
            this = preparePlan(parser.Results.Model, this, [this.BaseStart, this.BaseEnd]);
            this.DefaultAnticipate = parser.Results.Anticipate;
            this.Exogenized = false(this.NumOfEndogenous, this.NumOfExtendedPeriods, this.NumOfExtendedPeriods);
            this.Endogenized = false(this.NumOfExogenous, this.NumOfExtendedPeriods, this.NumOfExtendedPeriods);
        end%


        function this = anticipate(this, names)
            setToValue = true;
            this = implementAnticipate(this, names, setToValue);
        end%


        function this = unanticipate(this, names)
            setToValue = false;
            this = implementAnticipate(this, names, setToValue);
        end%


        function this = implementAnticipate(this, names, setToValue)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.anticipate');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('NamesToAnticipate', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            if nnz(this.Endogenized)>0
                THIS_ERROR = { 'Plan:CannotChangeAnticipateAfterEndogenize'
                               'Cannot change anticipation status after some names have been exogenized' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            parser.parse(this, names);
            if isequal(setToValue, true)
                context = 'anticipate';
            else
                context = 'unanticipate';
            end
            inxOfExogenous = this.resolveNames(names, this.NamesOfExogenous, context);
            this.AnticipationStatusOfExogenous(inxOfExogenous) = setToValue;
        end%


        function this = exogenize(this, names, dates, anticipate)
            setToValue = true;
            this = implementExogenize(this, names, dates, anticipate, setToValue);
        end%


        function this = unexogenize(this, names, dates, anticipate)
            setToValue = false;
            this = implementExogenize(this, names, dates, anticipate, setToValue);
        end%


        function this = implementExogenize(this, names, dates, anticipate, setToValue)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.exogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('NamesToExogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addRequired('DatesToExogenize', @DateWrapper.validateDateInput);
            end
            parser.parse(this, names, dates);
            if isequal(setToValue, true)
                context = 'exogenize';
            else
                context = 'unexogenize';
            end 
            inxOfDates = resolveDates(this, dates);
            inxOfEndogenous = this.resolveNames(names, this.NamesOfEndogenous, context);
            if anticipate
                this.Exogenized = assignAnticipated(this, this.Exogenized, inxOfEndogenous, inxOfDates, setToValue);
            else
                this.Exogenized = assignUnanticipated(this, this.Exogenized, inxOfEndogenous, inxOfDates, setToValue);
            end
        end%


        function this = endogenize(this, names, dates)
            setToValue = true;
            this = implementEndogenize(this, names, dates, setToValue);
        end%


        function this = unendogenize(this, names, dates)
            setToValue = false;
            this = implementEndogenize(this, names, dates, setToValue);
        end%


        function this = implementEndogenize(this, names, dates, setToValue)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.endogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('NamesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addRequired('DatesToEndogenize', @DateWrapper.validateDateInput);
            end
            parser.parse(this, names, dates);
            if isequal(setToValue, true)
                context = 'endogenize';
            else
                context = 'unendogenize';
            end 
            inxOfDates = resolveDates(this, dates);
            inxOfExogenous = this.resolveNames(names, this.NamesOfExogenous, context);
            if ~any(inxOfExogenous)
                return
            end
            anticipate = this.AnticipationStatusOfExogenous(inxOfExogenous);
            if ~all(anticipate==anticipate(1))
                THIS_ERROR = { 'Plan:CannotEndogenizeWithDifferentAnticipate'
                               'All names that are to be endogenized within one call must have the same anticipation status' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            if anticipate(1)
                this.Endogenized = assignAnticipated(this, this.Endogenized, inxOfExogenous, inxOfDates, setToValue);
            else
                this.Endogenized = assignUnanticipated(this, this.Endogenized, inxOfExogenous, inxOfDates, setToValue);
            end
        end%
    end


    properties (Dependent)
        BaseRange
        ExtendedRange
        NumOfEndogenous
        NumOfExogenous
        NumOfBasePeriods
        NumOfExtendedPeriods
        NumOfEndogenizedPoints
        NumOfExogenizedPoints
        PosOfBaseStart
        PosOfBaseEnd
    end


    methods
        function value = get.BaseRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = DateWrapper.NaD;
                return
            end
            value = this.BaseStart : this.BaseEnd;
            value = DateWrapper.fromSerial(value);
        end%


        function value = get.ExtendedRange(this)
            if isempty(this.ExtendedStart) || isempty(this.ExtendedEnd)
                value = DateWrapper.NaD;
                return
            end
            value = this.ExtendedStart : this.ExtendedEnd;
            value = DateWrapper.fromSerial(value);
        end%


        function this = set.DefaultAnticipate(this, value)
            this.DefaultAnticipate = value;
            if value
                this.AnticipationStatusOfExogenous = true(this.NumOfExogenous, 1);
            else
                this.AnticipationStatusOfExogenous = false(this.NumOfExogenous, 1);
            end
        end%

        function value = get.NumOfEndogenous(this)
            value = numel(this.NamesOfEndogenous);
        end%


        function value = get.NumOfExogenous(this)
            value = numel(this.NamesOfExogenous);
        end%


        function value = get.NumOfBasePeriods(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = NaN;
                return
            end
            value = round(this.BaseEnd - this.BaseStart + 1);
        end%


        function value = get.NumOfExtendedPeriods(this)
            if isempty(this.ExtendedStart) || isempty(this.ExtendedEnd)
                value = NaN;
                return
            end
            value = round(this.ExtendedEnd - this.ExtendedStart + 1);
        end%


        function value = get.NumOfExogenizedPoints(this)
            value = nnz(this.Exogenized);
        end%


        function value = get.NumOfEndogenizedPoints(this)
            value = nnz(this.Endogenized);
        end%


        function value = get.PosOfBaseStart(this)
            value = round(this.BaseStart - this.ExtendedStart + 1);
        end%


        function value = get.PosOfBaseEnd(this)
            value = round(this.BaseEnd - this.ExtendedStart + 1);
        end%
    end


    methods
        function inxOfDates = resolveDates(this, dates)
            if isequal(dates, @all)
                inxOfDates = false(1, this.NumOfExtendedPeriods);
                inxOfDates(this.PosOfBaseStart:this.PosOfBaseEnd) = true;
                return
            end
            posOfDates = DateWrapper.getRelativePosition( this.ExtendedStart, ...
                                                          dates, ...
                                                          [this.PosOfBaseStart, this.PosOfBaseEnd], ...
                                                          'simulation range' );
            inxOfDates = false(1, this.NumOfExtendedPeriods);
            inxOfDates(posOfDates) = true;
        end%


        function array = assignAnticipated(this, array, inxOfNames, inxOfDates, setToValue)
            array(inxOfNames, inxOfDates, this.PosOfBaseStart:this.PosOfBaseEnd) = setToValue;
        end%


        function array = assignUnanticipated(this, array, inxOfNames, inxOfDates, setToValue)
            posOfBaseEnd = this.PosOfBaseEnd;
            for pos = find(inxOfDates)
                array(inxOfNames, pos, pos:posOfBaseEnd) = setToValue;
            end
        end%
    end


    methods (Static)
        function inxOfNames = resolveNames(selectNames, allNames, context)
            if isequal(selectNames, @all)
                inxOfNames = true(1, numel(allNames));
                return
            end
            if ~iscellstr(selectNames)
                selectNames = cellstr(selectNames);
            end
            [inxOfValidNames, posOfNames] = ismember(selectNames, allNames);
            if any(~inxOfValidNames)
                THIS_ERROR = { 'Plan:InvalidNameInContext'
                               'This name cannot be %1 in simulation plan: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       context, selectNames{~inxOfValidNames} );
            end
            inxOfNames = false(1, numel(allNames));
            inxOfNames(posOfNames) = true;
        end%
    end
end

