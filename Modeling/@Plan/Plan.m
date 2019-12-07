% Plan  Simulation Plans for Model objects
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

classdef Plan < matlab.mixin.CustomDisplay

    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
        AutoswapPairs = cell.empty(0, 2)
        BaseStart = double.empty(0)
        BaseEnd = double.empty(0)
        ExtendedStart = double.empty(0)
        ExtendedEnd = double.empty(0)

        SwapId = int16(-1)

        AnticipationStatusOfEndogenous = logical.empty(0)
        AnticipationStatusOfExogenous = logical.empty(0)

        IdOfAnticipatedExogenized = int16.empty(0, 0)
        IdOfUnanticipatedExogenized = int16.empty(0, 0)
        IdOfAnticipatedEndogenized = int16.empty(0, 0)
        IdOfUnanticipatedEndogenized = int16.empty(0, 0)
        
        SigmaOfExogenous = double.empty(0, 0)
    end


    properties (SetAccess=protected)
        DefaultAnticipationStatus = true
        AllowUnderdetermined = false
        AllowOverdetermined = false
        NumOfDummyPeriods = 0
    end


    properties (Constant, Hidden)
        DEFAULT_SWAP_ID = int16(-1)
        EMPTY_MARK = '.' % char.empty(1, 0)
        ANTICIPATED_MARK = 'A'
        UNANTICIPATED_MARK = 'U'
        DATE_PREFIX = 't'
        RANGE_DEPENDENT = [ "IdOfAnticipatedExogenized", ...
                            "IdOfUnanticipatedExogenized", ...
                            "IdOfAnticipatedEndogenized", ...
                            "IdOfUnanticipatedEndogenized" ]
    end


    methods % Constructor
        function this = Plan(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'Plan')
                this = varargin{1};
                return
            end
            if nargin>=2 && isa(varargin{1}, 'Model')
                this = Plan.forModel(varargin{:});
                return
            end
            thisError = [ "Plan:InvalidConstructor"
                          "This is an invalid call of the Plan object constructor; "
                          "use Plan( ) or Plan.forModel(...) instead." ];
            throw(exception.Base(thisError, 'error'));
        end%
    end




    methods % User Interface
        varargout = anticipate(varargin)
        varargout = endogenized(varargin)
        varargout = exogenized(varargin)
        varargout = get(varargin)
        varargout = swap(varargin)




        function this = unexogenize(this, dates, names, varargin)
            if nargin==1
                this = unexogenizeAll(this);
                return
            end
            setToValue = int16(0);
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%




        function this = unexogenizeAll(this)
            this.IdOfAnticipatedExogenized(:, :) = int16(0);
            this.IdOfUnanticipatedExogenized(:, :) = int16(0);
        end%




        function this = unendogenize(this, dates, names, varargin)
            if nargin==1
                this = unendogenizeAll(this);
                return
            end
            setToValue = int16(0);
            this = implementEndogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unendogenizeAll(this)
            this.IdOfAnticipatedEndogenized(:, :) = int16(0);
            this.IdOfUnanticipatedEndogenized(:, :) = int16(0);
        end%


        function this = clear(this)
            this = unexogenizeAll(this);
            this = unendogenizeAll(this);
        end%




        function this = autoswap(this, dates, namesToAutoswap, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.autoswap');
                parser.addRequired('plan', @(x) isa(x, 'Plan'));
                parser.addRequired('datesToSwap', @DateWrapper.validateDateInput);
                parser.addRequired('namesToAutoswap', @(x) ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @all));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            parser.parse(this, dates, namesToAutoswap, varargin{:});
            opt = parser.Options;
            inxToAutoswap = false(size(this.AutoswapPairs, 1), 1); 
            if isequal(namesToAutoswap, @all)
                inxToAutoswap(:) = true;
            else
                inxToAutoswap = hereIndexPairsToSwap( );
            end
            pairsToAutoswap = this.AutoswapPairs(inxToAutoswap, :);
            this = swap(this, dates, pairsToAutoswap, 'AnticipationStatus=', opt.AnticipationStatus);
            return

                function inxToAutoswap = hereIndexPairsToSwap( )
                    namesToAutoswap = cellstr(namesToAutoswap);
                    namesToAutoswap = transpose(namesToAutoswap(:));
                    numNames = numel(namesToAutoswap);
                    inxToAutoswap = false(size(this.AutoswapPairs, 1), 1);
                    inxValid = true(1, numNames);
                    for i = 1 : numel(namesToAutoswap)
                        name = namesToAutoswap{i};
                        inx = strcmp(name, this.AutoswapPairs(:, 1)) ...
                            | strcmp(name, this.AutoswapPairs(:, 2));
                        if any(inx)
                            inxToAutoswap = inxToAutoswap | inx;
                        else
                            inxValid(i) = false;
                        end
                    end
                    if any(~inxValid)
                        THIS_ERROR = { 'Plan:CannotAutoswapName'
                                       'Cannot autoswap this name: %s ' };
                        throw( exception.Base(THIS_ERROR, 'error'), ...
                               namesToAutoswap{~inxValid} );
            end
                end%
        end%


            



        function this = extendWithDummies(this, numDummyPeriods)
            if numDummyPeriods==0
                return
            end
            this.IdOfAnticipatedEndogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdOfUnanticipatedEndogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdOfAnticipatedExogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdOfUnanticipatedExogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.NumOfDummyPeriods = numDummyPeriods;
        end%
    end




    methods 
        function [ inxExogenized, ...
                   inxEndogenized ] = getSwapsWithinTimeFrame( this, ...
                                                               firstColumnOfTimeFrame, ...
                                                               lastColumnOfSimulation )
            numColumns = this.NumOfExtendedPeriods + this.NumOfDummyPeriods;
            inxExogenized = false(this.NumOfEndogenous, numColumns);
            inxEndogenized = false(this.NumOfExogenous, numColumns);
            if this.NumOfExogenizedPoints>0
                inxExogenized(:, firstColumnOfTimeFrame) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnOfTimeFrame) ...
                    | this.InxOfUnanticipatedExogenized(:, firstColumnOfTimeFrame);
                inxExogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation);
            end
            if this.NumOfEndogenizedPoints>0
                inxEndogenized(:, firstColumnOfTimeFrame) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnOfTimeFrame) ...
                    | this.InxOfUnanticipatedEndogenized(:, firstColumnOfTimeFrame);
                inxEndogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation);
            end
        end%
    end




    methods (Access=private, Hidden)
        function [this, outputAnticipationStatus] = implementExogenize(this, dates, names, id, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementExogenize');
                parser.addRequired('plan', @(x) isa(x, 'Plan'));
                parser.addRequired('datesToExogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('namesToExogenize', @(x) isequal(x, @all) || validate.list(x));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            parser.parse(this, dates, names, varargin{:});
            opt = parser.Options;

            anticipationStatusOfEndogenous = this.AnticipationStatusOfEndogenous;
            if ~isequal(opt.AnticipationStatus, @auto)
                anticipationStatusOfEndogenous(:) = opt.AnticipationStatus;
            end
            context = (id==int16(0)) : { 'be unexogenized', 'be exogenized' };
            inxDates = resolveDates(this, dates);
            inxNames = this.resolveNames(names, this.NamesOfEndogenous, context);
            if ~any(inxNames)
                return
            end
            posNames = find(inxNames);
            outputAnticipationStatus = logical.empty(0, 1);
            for column = transpose(posNames(:))
                if id~=int16(0)
                    % Exogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfEndogenous(column);
                    if anticipationStatusOfEndogenous(column)
                        this.IdOfAnticipatedExogenized(inxNames, inxDates) = id;
                    else
                        this.IdOfUnanticipatedExogenized(inxNames, inxDates) = id;
                    end
                else
                    % Unexogenize
                    this.IdOfAnticipatedExogenized(inxNames, inxDates) = id;
                    this.IdOfUnanticipatedExogenized(inxNames, inxDates) = id;
                end
            end
        end%




        function [this, outputAnticipationStatus] = implementEndogenize(this, dates, names, id, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementEndogenize');
                parser.addRequired('plan', @(x) isa(x, 'Plan'));
                parser.addRequired('datesToEndogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('namesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            parser.parse(this, dates, names);
            opt = parser.Options;

            numDates = numel(dates);

            anticipationStatusOfExogenous = this.AnticipationStatusOfExogenous;
            if ~isequal(opt.AnticipationStatus, @auto)
                anticipationStatusOfExogenous(:) = opt.AnticipationStatus;
            end
            context = (id==int16(0)) : {'be unendogenized', 'be endogenized'};
            inxDates = resolveDates(this, dates);
            inxNames = this.resolveNames(names, this.NamesOfExogenous, context);
            if ~any(inxNames)
                return
            end
            posNames = find(inxNames);
            posNames = transpose(posNames(:));
            outputAnticipationStatus = logical.empty(0, 1);
            for column = transpose(posNames(:))
                if id~=int16(0)
                    % Endogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfExogenous(column);
                    if anticipationStatusOfExogenous(column)
                        this.IdOfAnticipatedEndogenized(column, inxDates) = id;
                    else
                        this.IdOfUnanticipatedEndogenized(column, inxDates) = id;
                    end
                else
                    % Unendogenize
                    this.IdOfAnticipatedEndogenized(column, inxDates) = id;
                    this.IdOfUnanticipatedEndogenized(column, inxDates) = id;
                end
            end
        end%


        function inxDates = resolveDates(this, dates)
            if isequal(dates, @all)
                inxDates = false(1, this.NumOfExtendedPeriods);
                inxDates(this.PosOfBaseStart:this.PosOfBaseEnd) = true;
                return
            end
            posDates = DateWrapper.getRelativePosition( this.ExtendedStart, dates, ...
                                                        [this.PosOfBaseStart, this.PosOfBaseEnd], ...
                                                        'simulation range' );
            inxDates = false(1, this.NumOfExtendedPeriods);
            inxDates(posDates) = true;
        end%
    end


    properties (Dependent)
        LastAnticipatedExogenized
        LastUnanticipatedExogenized
        LastAnticipatedEndogenized
        LastUnanticipatedEndogenized


% Start  Start date of the simulation range
%{
% ## Syntax ##
%
%     currentStart = plan.Start
%     plan.Start = newStart
%
% ## Arguments ##
%
% __`plan`__ [ Plan ] -
% Plan object whose `Start` date will be accessed or assigned.
%
% __ `currentStart`__ [ DateWrapper ] -
% Current `Start` date of the `plan` object.
%
% __ `newStart`__ [ DateWrapper | numeric ] -
% New `Start` date for the `plan` object.
%
% 
% ## Description ##
%
%  
% ## Example ##
%
%     >> p = Plan(m, qq(2021,1):qq(2025,4));
%     >> p.Start
%     ans =
%       1x1 QUARTERLY Date(s)
%         '2021Q1'
%     >> p.Start = qq(2022,1);
%     >> p.Start
%     ans =
%       1x1 QUARTERLY Date(s)
%         '2022Q1'
%
%}
        Start


% End  End date of the simulation range
%{
% ## Syntax ##
%
%     currentEnd = plan.End
%     plan.End = newEnd
%
% ## Arguments ##
%
% __`plan`__ [ Plan ] -
% Plan object whose `End` date will be accessed or assigned.
%
% __ `currentEnd`__ [ DateWrapper ] -
% Current `End` date of the `plan` object.
%
% __ `newEnd`__ [ DateWrapper | numeric ] -
% New `End` date for the `plan` object.
%
% 
% ## Description ##
%
%  
% ## Example ##
%
%     >> p = Plan(m, qq(2021,1):qq(2025,4));
%     >> p.End
%     ans =
%       1x1 QUARTERLY Date(s)
%         '2025Q4'
%     >> p.End = qq(2026,4);
%     >> p.End
%     ans =
%       1x1 QUARTERLY Date(s)
%         '2026Q4'
%
%}
        End


        InxOfAnticipatedExogenized
        InxOfUnanticipatedExogenized
        InxOfAnticipatedEndogenized
        InxOfUnanticipatedEndogenized

        DisplayRange
        BaseRange
        ExtendedRange
        ColumnOfLastAnticipatedExogenized
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

        NamesOfAnticipated
        NamesOfUnanticipated
        StructWithAnticipationStatus
        AllNames

        DatabankOfAnticipatedExogenized
        DatabankOfUnanticipatedExogenized
        DatabankOfAnticipatedEndogenized
        DatabankOfUnanticipatedEndogenized
    end


    methods % Get Set Methods
        function this = set.AutoswapPairs(this, value)
            if ~iscellstr(value) || size(value, 2)~=2
                hereThrowError( );
            end
            if ~all(ismember(value(:,1), this.NamesOfEndogenous))
                hereThrowError( );
            end
            if ~all(ismember(value(:,2), this.NamesOfExogenous))
                hereThrowError( );
            end
            this.AutoswapPairs = value;

            return
                function hereThrowError( )
                    THIS_ERROR = { 'Plan:InvalidAutoswapPairs'
                                   'Invalid value assigned to @Plan.AutoswapPairs' };
                    throw( exception.Base(THIS_ERROR, 'error') );
                end%
        end%


        function value = get.Start(this)
            value = DateWrapper(this.BaseStart);
        end%




        function this = set.Start(this, value)
            %(
            if isempty(this.BaseStart)
                thisError = { 'Plan:StartDateNotInitialized'
                              'Plan.Start must be initialized first in a constructor' };
                throw(exception.Base(thisError, 'error'));
            end
            try
                value = double(value);
                pass = Frequency.sameFrequency( DateWrapper.getFrequencyAsNumeric(this.BaseStart), ...
                                                DateWrapper.getFrequencyAsNumeric(value) );
            catch
                pass = false;
            end
            if ~pass
                thisError = { 'Plan:InvalidStartDateFrequency'
                              'New Plan.Start must be the same date frequency as the simulation range' };
                throw(exception.Base(thisError, 'error'));
            end
            if value>this.BaseEnd
                thisError = { 'Plan:StartDateAfterEndDate'
                              'New Plan.Start date must not be after Plan.End date' };
                throw(exception.Base(thisError, 'error'));
            end
            shift = round(value - this.BaseStart);
            if shift==0
                return
            elseif shift>0
                for name = this.RANGE_DEPENDENT
                    this.(name) = this.(name)(:, shift+1:end, :);
                end
            elseif shift<0
                for name = this.RANGE_DEPENDENT
                    numRows = size(this.(name), 1);
                    this.(name) = [ zeros(numRows, -shift, 'like', this.(name)), this.(name) ];
                end
            end
            this.BaseStart = DateWrapper.roundPlus(this.BaseStart, shift);
            this.ExtendedStart = DateWrapper.roundPlus(this.ExtendedStart, shift);
            this = resetOutsideBaseRange(this);
            %)
        end%




        function this = set.End(this, value)
            %(
            if isempty(this.BaseEnd)
                thisError = { 'Plan:EndDateNotInitialized'
                              'Plan.End must be initialized first in a constructor' };
                throw(exception.Base(thisError, 'error'));
            end
            try
                value = double(value);
                pass = Frequency.sameFrequency( DateWrapper.getFrequencyAsNumeric(this.BaseEnd), ...
                                                DateWrapper.getFrequencyAsNumeric(value) );
            catch
                pass = false;
            end
            if ~pass
                thisError = { 'Plan:InvalidEndDateFrequency'
                              'New Plan.End must be the same date frequency as the simulation range' };
                throw(exception.Base(thisError, 'error'));
            end
            if value<this.BaseStart
                thisError = { 'Plan:EndDateBeforeStartDate'
                              'New Plan.End date must not be before Plan.Start date' };
                throw(exception.Base(thisError, 'error'));
            end
            shift = round(value - this.BaseEnd);
            if shift==0
                return
            elseif shift>0
                for name = this.RANGE_DEPENDENT
                    numRows = size(this.(name), 1);
                    this.(name) = [ this.(name), zeros(numRows, shift, 'like', this.(name)) ];
                end
            elseif shift<0
                for name = this.RANGE_DEPENDENT
                    this.(name) = this.(name)(:, 1:end+shift, :);
                end
            end
            this.BaseEnd = DateWrapper.roundPlus(this.BaseEnd, shift);
            this.ExtendedEnd = DateWrapper.roundPlus(this.ExtendedEnd, shift);
            %)
        end%




        function value = get.End(this)
            value = DateWrapper(this.BaseEnd);
        end%


        function value = get.InxOfAnticipatedExogenized(this)
            value = not(this.IdOfAnticipatedExogenized==0);
        end%




        function value = get.InxOfUnanticipatedExogenized(this)
            value = not(this.IdOfUnanticipatedExogenized==0);
        end%




        function value = get.InxOfAnticipatedEndogenized(this)
            value = not(this.IdOfAnticipatedEndogenized==0);
        end%




        function value = get.InxOfUnanticipatedEndogenized(this)
            value = not(this.IdOfUnanticipatedEndogenized==0);
        end%




        function value = get.DisplayRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = '';
                return
            end
            displayStart = DateWrapper.toCellstr(this.BaseStart);
            displayEnd = DateWrapper.toCellstr(this.BaseEnd);
            value = [displayStart{1}, ':', displayEnd{1}]; 
        end%


        function value = get.BaseRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = DateWrapper.NaD;
                return
            end
            value = DateWrapper.roundColon(this.BaseStart, this.BaseEnd);
            value = DateWrapper(value);
        end%


        function value = get.ExtendedRange(this)
            if isempty(this.ExtendedStart) || isempty(this.ExtendedEnd)
                value = DateWrapper.NaD;
                return
            end
            value = DateWrapper.roundColon(this.ExtendedStart, this.ExtendedEnd);
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
                value = 0;
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
            value = hereGetLastDate(this.ExtendedStart, this.InxOfAnticipatedExogenized);
        end%


        function value = get.LastUnanticipatedExogenized(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfUnanticipatedExogenized);
        end%


        function value = get.LastAnticipatedEndogenized(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfAnticipatedEndogenized);
        end%


        function value = get.LastUnanticipatedEndogenized(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfUnanticipatedEndogenized);
        end%


        function value = get.ColumnOfLastAnticipatedExogenized(this)
            value = find(any(this.InxOfAnticipatedExogenized, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.NamesOfAnticipated(this)
            value = this.NamesOfExogenous(this.AnticipationStatusOfExogenous);
        end%


        function value = get.NamesOfUnanticipated(this)
            value = this.NamesOfExogenous(~this.AnticipationStatusOfExogenous);
        end%


        function value = get.StructWithAnticipationStatus(this)
            temp = num2cell(this.AnticipationStatusOfExogenous);
            value = cell2struct(temp, this.NamesOfExogenous, 1);
        end%


        function value = get.AllNames(this)
            value = [this.NamesOfEndogenous, this.NamesOfExogenous];
        end%


        function output = get.DatabankOfAnticipatedExogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfEndogenous, ...
                                              this.IdOfAnticipatedExogenized );
        end%


        function output = get.DatabankOfUnanticipatedExogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfEndogenous, ...
                                              this.IdOfUnanticipatedExogenized );
        end%


        function output = get.DatabankOfAnticipatedEndogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfExogenous, ...
                                              this.IdOfAnticipatedEndogenized );
        end%


        function output = get.DatabankOfUnanticipatedEndogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfExogenous, ...
                                              this.IdOfAnticipatedEndogenized );
        end%


        function output = createDatabankOfAnchors(this, names, anchors)
            output = struct( );
            baseRangeColumns = this.PosOfBaseStart : this.PosOfBaseEnd;
            template = Series(this.BaseStart, false(this.NumOfBasePeriods, 1));
            numNames = numel(names);
            for i = 1 : numNames
                name = names{i};
                values = transpose(anchors(i, baseRangeColumns));
                output.(name) = fill(template, values, this.BaseStart);
            end
        end%
    end


    methods (Static)
        varargout = forModel(varargin)
    end



        
    methods (Static, Hidden)
        function inxNames = resolveNames(selectNames, allNames, context, throwError)
            if nargin<4
                throwError = true;
            end
            if isequal(selectNames, @all)
                inxNames = true(1, numel(allNames));
                return
            end
            if ~iscellstr(selectNames)
                selectNames = cellstr(selectNames);
            end
            [inxValidNames, posNames] = ismember(selectNames, allNames);
            if throwError && any(~inxValidNames)
                THIS_ERROR = { 'Plan:InvalidNameInContext'
                               'This name cannot %1 in simulation plan: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       context, selectNames{~inxValidNames} );
            end
            posNames(~inxValidNames) = [ ];
            inxNames = false(1, numel(allNames));
            inxNames(posNames) = true;
        end%




        function flag = validateSwapId(id)
            if validate.numericScalar(id) && id~=0 && id==round(id)
                flag = true;
                return
            end
            flag = false;
        end%
    end




    methods (Access=protected, Hidden)
        function pg = getPropertyGroups(this)
            toChar = @(x) char(DateWrapper.toDefaultString(x));

            % Dates
            s1 = struct( 'Start',                        toChar(this.Start), ...
                         'End',                          toChar(this.End), ...
                         'LastAnticipatedExogenized',    toChar(this.LastAnticipatedExogenized), ...
                         'LastUnanticipatedExogenized',  toChar(this.LastUnanticipatedExogenized), ...
                         'LastAnticipatedEndogenized',   toChar(this.LastAnticipatedEndogenized), ...
                         'LastUnanticipatedEndogenized', toChar(this.LastUnanticipatedEndogenized) );
            pg1 = matlab.mixin.util.PropertyGroup(s1, 'SimulationDates');

            % Switches
            pg2 = matlab.mixin.util.PropertyGroup( { 'DefaultAnticipationStatus'
                                                     'AllowUnderdetermined'
                                                     'AllowOverdetermined' }, ...
                                                     'Switches' );

            % Determinacy of the Swap System
            pg3 = matlab.mixin.util.PropertyGroup( { 'NumOfAnticipatedExogenizedPoints'
                                                     'NumOfUnanticipatedExogenizedPoints'
                                                     'NumOfAnticipatedEndogenizedPoints'
                                                     'NumOfUnanticipatedEndogenizedPoints' }, ...
                                                     'SwapPoints');

            pg = [pg1, pg2, pg3];
        end%




        function [this, id] = nextSwapId(this)
            id = this.SwapId;
            this.SwapId = this.SwapId - 1;
        end%




        function ids = getUniqueIds(this)
            list = [ reshape(this.IdOfAnticipatedExogenized,    [ ], 1)
                     reshape(this.IdOfUnanticipatedExogenized,  [ ], 1)
                     reshape(this.IdOfAnticipatedEndogenized,   [ ], 1)
                     reshape(this.IdOfUnanticipatedEndogenized, [ ], 1) ];
            list(list==0) = [ ];
            list = unique(list);
            negativeIds = reshape(list(list<0), 1, [ ]);
            positiveIds = reshape(list(list>0), 1, [ ]);
            ids = [sort(negativeIds, 'descend'), sort(positiveIds, 'ascend')];
        end%




        function this = resetOutsideBaseRange(this)
            numExtendedPeriods = this.NumOfExtendedPeriods;
            posPresample = 1 : round(this.BaseStart-this.ExtendedStart);
            posPostsample = numExtendedPeriods-round(this.ExtendedEnd-this.BaseEnd) : numExtendedPeriods;
            for name = this.RANGE_DEPENDENT
                this.(name)(:, [posPresample, posPostsample]) = 0;
            end
        end%
    end
end


%
% Local Functions
%

function date = hereGetLastDate(start, id)
    inx = id~=0;
    if not(any(inx(:)))
        date = DateWrapper.NaD;
        return
    end
    column = find(any(inx, 1), 1, 'Last');
    date = DateWrapper.roundPlus(start, column-1);
end%

