classdef Plan
    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
        BaseStart = double.empty(0)
        BaseEnd = double.empty(0)
        ExtendedStart = double.empty(0)
        ExtendedEnd = double.empty(0)

        AnticipationStatusOfExogenous = logical.empty(0)
        InxOfAnticipatedEndogenized = logical.empty(0, 0)
        InxOfUnanticipatedEndogenized = logical.empty(0, 0)
        InxOfAnticipatedExogenized = logical.empty(0, 0)
        InxOfUnanticipatedExogenized = logical.empty(0, 0)
    end


    properties (SetAccess=protected)
        DefaultAnticipationStatus = true
    end


    methods
        function this = Plan(varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.Plan');
                parser.addRequired('Model', @(x) isa(x, 'model.Plan'));
                parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                parser.addParameter({'DefaultAnticipate', 'Anticipate'}, true, @(x) isequal(x, true) || isequal(x, false));
            end
            if nargin==0
                return
            end
            parser.parse(varargin{:});
            opt = parser.Options;
            this.BaseStart = double(parser.Results.SimulationRange(1));
            this.BaseEnd = double(parser.Results.SimulationRange(end));
            this = preparePlan(parser.Results.Model, this, [this.BaseStart, this.BaseEnd]);
            this.DefaultAnticipationStatus = opt.DefaultAnticipate;
            this.InxOfAnticipatedExogenized = false(this.NumOfEndogenous, this.NumOfExtendedPeriods);
            this.InxOfUnanticipatedExogenized = false(this.NumOfEndogenous, this.NumOfExtendedPeriods);
            this.InxOfAnticipatedEndogenized = false(this.NumOfExogenous, this.NumOfExtendedPeriods);
            this.InxOfUnanticipatedEndogenized = false(this.NumOfExogenous, this.NumOfExtendedPeriods);
            this.AnticipationStatusOfExogenous = repmat(this.DefaultAnticipationStatus, this.NumOfExogenous, 1);
        end%


        function this = anticipate(this, names, anticipationStatus)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.anticipate');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('NamesOfExogenous', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addRequired('AnticipationStatus', @(x) isequal(x, true) || isequal(x, false));
            end
            if this.NumOfEndogenizedPoints>0
                THIS_ERROR = { 'Plan:CannotChangeAnticipateAfterEndogenize'
                               'Cannot change anticipation status after some names have been already endogenized' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            parser.parse(this, names, anticipationStatus);
            context = 'be assigned anticipation status';
            inxOfExogenous = this.resolveNames(names, this.NamesOfExogenous, context);
            this.AnticipationStatusOfExogenous(inxOfExogenous) = anticipationStatus;
        end%


        function this = exogenize(this, dates, names, varargin)
            setToValue = true;
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unexogenize(this, dates, names, varargin)
            setToValue = false;
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unexogenizeAll(this)
            this.InxOfAnticipatedExogenized(:, :) = false;
            this.InxOfUnanticipatedExogenized(:, :) = false;
        end%


        function this = implementExogenize(this, dates, names, setToValue, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementExogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToExogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('NamesToExogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addParameter('Anticipate', @auto, @(x) isequal(x, @auto) || isequal(x, true) || isequal(x, false));
            end
            parser.parse(this, dates, names, varargin{:});
            opt = parser.Options;
            if isequal(opt.Anticipate, @auto)
                opt.Anticipate = this.DefaultAnticipationStatus;
            end
            if setToValue
                context = 'be exogenized';
            else
                context = 'be unexogenized';
            end
            inxOfDates = resolveDates(this, dates);
            inxOfNames = this.resolveNames(names, this.NamesOfEndogenous, context);
            if setToValue
                % Exogenize
                if opt.Anticipate
                    this.InxOfAnticipatedExogenized(inxOfNames, inxOfDates) = true;
                else
                    this.InxOfUnanticipatedExogenized(inxOfNames, inxOfDates) = true;
                end
            else
                % Unexogenize
                this.InxOfAnticipatedExogenized(inxOfNames, inxOfDates) = false;
                this.InxOfUnanticipatedExogenized(inxOfNames, inxOfDates) = false;
            end
        end%


        function [this, anticipationStatus] = endogenize(this, dates, names, varagin)
            setToValue = true;
            [this, anticipationStatus] = implementEndogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unendogenizeAll(this)
            this.InxOfAnticipatedEndogenized(:, :) = false;
            this.InxOfUnanticipatedEndogenized(:, :) = false;
        end%


        function [this, anticipationStatus] = implementEndogenize(this, dates, names)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementEndogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToEndogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('NamesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            parser.parse(this, dates, names, setToValue);
            if setToValue
                context = 'be endogenized';
            else
                context = 'be unendogenized';
            end
            inxOfDates = resolveDates(this, dates);
            inxOfNames = this.resolveNames(names, this.NamesOfExogenous, context);
            if ~any(inxOfNames)
                return
            end
            posOfNames = find(inxOfNames);
            anticipationStatus = this.AnticipationStatusOfExogenous(posOfNames);
            for pos = transpose(posOfNames(:))
                if setToValue
                    % Endogenize
                    if this.AnticipationStatusOfExogenous(pos)
                        this.InxOfAnticipatedEndogenized(pos, inxOfDates) = true;
                    else
                        this.InxOfUnanticipatedEndogenized(pos, inxOfDates) = true;
                    end
                else
                    % Unendogenize
                    this.InxOfAnticipatedEndogenized(pos, inxOfDates) = false;
                    this.InxOfUnanticipatedEndogenized(pos, inxOfDates) = false;
                end
            end
        end%


        function this = swap(this, dates, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.swap');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToSwap', @DateWrapper.validateDateInput);
                parser.addRequired('PairsToSwap', @validatePairsToSwap);
            end
            parser.parse(this, dates, varargin);
            setToValue = true;
            if numel(varargin)==1 && isstruct(varargin{1})
                inputStruct = varargin{1};
                namesToExogenize = fieldnames(inputStruct);
                numOfPairs = numel(namesToExogenize);
                pairsToSwap = cell(1, numOfPairs);
                for i = 1 : numOfPairs
                    pairsToSwap{i} = { namesToExogenize{i}, ...
                                       inputStruct.(namesToExogenize{i}) };
                end
            else
                pairsToSwap = varargin;
            end
            for i = 1 : numel(pairsToSwap)
                [nameToExogenize, nameToEndogenize] = pairsToSwap{i}{:};
                [this, anticipationStatus] = implementEndogenize( this, ...
                                                                  dates, ...
                                                                  nameToEndogenize, ...
                                                                  setToValue );
                this = implementExogenize( this, ...
                                           dates, ...
                                           nameToExogenize, ...
                                           setToValue, ...
                                           'Anticipate=', anticipationStatus );
            end
        end%


        function this = extendWithDummies(this, numOfPeriods)
            if numOfPeriods==0
                return
            end
            this.InxOfAnticipatedEndogenized(:, end+(1:numOfPeriods)) = false;
            this.InxOfUnanticipatedEndogenized(:, end+(1:numOfPeriods)) = false;
            this.InxOfAnticipatedExogenized(:, end+(1:numOfPeriods)) = false;
            this.InxOfUnanticipatedExogenized(:, end+(1:numOfPeriods)) = false;
        end%
    end


    properties (Dependent)
        DisplayRange
        BaseRange
        ExtendedRange
        NumOfEndogenous
        NumOfExogenous
        NumOfBasePeriods
        NumOfExtendedPeriods
        NumOfExogenizedPoints
        NumOfAnticipatedExogenizedPoints
        NumOfUnanticipatedExogenizedPoints
        NumOfEndogenizedPoints
        NumOfAnticipatedEndogenizedPoints
        NumOfUnanticipatedEndogenizedPoints
        PosOfBaseStart
        PosOfBaseEnd
        LastAnticipatedExogenized
    end


    methods
        function value = get.DisplayRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = '';
                return
            end
            displayStart = DateWrapper.toCellOfChar(this.BaseStart);
            displayEnd = DateWrapper.toCellOfChar(this.BaseEnd);
            value = [displayStart{1}, ':', displayEnd{1}]; 
        end%


        function value = get.BaseRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = DateWrapper.NaD;
                return
            end
            value = this.BaseStart : this.BaseEnd;
            value = DateWrapper(value);
        end%


        function value = get.ExtendedRange(this)
            if isempty(this.ExtendedStart) || isempty(this.ExtendedEnd)
                value = DateWrapper.NaD;
                return
            end
            value = this.ExtendedStart : this.ExtendedEnd;
            value = DateWrapper(value);
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
            value = this.NumOfAnticipatedExogenizedPoints ...
                  + this.NumOfUnanticipatedExogenizedPoints;
        end%


        function value = get.NumOfAnticipatedExogenizedPoints(this)
            value = nnz(this.InxOfAnticipatedExogenized);
        end%


        function value = get.NumOfUnanticipatedExogenizedPoints(this)
            value = nnz(this.InxOfUnanticipatedExogenized);
        end%


        function value = get.NumOfEndogenizedPoints(this)
            value = this.NumOfAnticipatedEndogenizedPoints ...
                  + this.NumOfUnanticipatedEndogenizedPoints;
        end%


        function value = get.NumOfAnticipatedEndogenizedPoints(this)
            value = nnz(this.InxOfAnticipatedEndogenized);
        end%


        function value = get.NumOfUnanticipatedEndogenizedPoints(this)
            value = nnz(this.InxOfUnanticipatedEndogenized);
        end%


        function value = get.PosOfBaseStart(this)
            value = round(this.BaseStart - this.ExtendedStart + 1);
        end%


        function value = get.PosOfBaseEnd(this)
            value = round(this.BaseEnd - this.ExtendedStart + 1);
        end%


        function value = get.LastAnticipatedExogenized(this)
            value = find(any(this.InxOfAnticipatedExogenized, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
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
                               'This name cannot %1 in simulation plan: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       context, selectNames{~inxOfValidNames} );
            end
            inxOfNames = false(1, numel(allNames));
            inxOfNames(posOfNames) = true;
        end%
    end
end


%
% Local Functions
%


function flag = validatePairsToSwap(pairs)
    if numel(pairs)==1 && isstruct(pairs{1})
        flag = true;
        return
    end
    tempValidate = @(x) (iscellstr(x) || isa(x, 'string')) && numel(x)==2;
    if iscell(pairs) && all(cellfun(tempValidate, pairs))
        flag = true;
        return
    end
    flag = false;
end%

