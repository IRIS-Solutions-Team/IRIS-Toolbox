% Plan  Simulation plans for Model objects
%

% -IRIS Macroeconomic Modeling Toolbox
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

        SwapId = uint16(2)

        AnticipationStatusOfEndogenous = logical.empty(0)
        AnticipationStatusOfExogenous = logical.empty(0)

        IdOfAnticipatedExogenized = logical.empty(0, 0)
        IdOfUnanticipatedExogenized = logical.empty(0, 0)

        IdOfAnticipatedEndogenized = logical.empty(0, 0)
        IdOfUnanticipatedEndogenized = logical.empty(0, 0)
    end


    properties (SetAccess=protected)
        DefaultAnticipationStatus = true
        AllowUnderdetermined = false
        AllowOverdetermined = false
    end


    properties (Constant, Hidden)
        ANTICIPATED_MARK = 'A'
        UNANTICIPATED_MARK = 'U'
        DATE_PREFIX = 't'
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
            this = Plan.fromModel(varargin{:});
        end%
    end




    methods % User Interface
        varargout = anticipate(varargin)
        varargout = get(varargin)
        varargout = swap(varargin)




        function this = exogenize(this, dates, names, varargin)
            setToValue = uint16(1);
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%




        function this = unexogenize(this, dates, names, varargin)
            if nargin==1
                this = unexogenizeAll(this);
                return
            end
            setToValue = uint16(0);
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unexogenizeAll(this)
            this.IdOfAnticipatedExogenized(:, :) = uint16(0);
            this.IdOfUnanticipatedExogenized(:, :) = uint16(0);
        end%


        function this = endogenize(this, dates, names, varargin)
            setToValue = uint16(1);
            this = implementEndogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unendogenize(this, dates, names, varargin)
            if nargin==1
                this = unendogenizeAll(this);
                return
            end
            setToValue = uint16(0);
            this = implementEndogenize(this, dates, names, setToValue, varargin{:});
        end%


        function this = unendogenizeAll(this)
            this.IdOfAnticipatedEndogenized(:, :) = uint16(0);
            this.IdOfUnanticipatedEndogenized(:, :) = uint16(0);
        end%


        function this = clear(this)
            this = unexogenizeAll(this);
            this = unendogenizeAll(this);
        end%




        function this = autoswap(this, dates, namesToAutoswap, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.autoswap');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToSwap', @DateWrapper.validateDateInput);
                parser.addRequired('NamesToAutoswap', @(x) ischar(x) || iscellstr(x) || isa(x, 'string') || isequal(x, @all));
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
                    numOfNames = numel(namesToAutoswap);
                    inxToAutoswap = false(size(this.AutoswapPairs, 1), 1);
                    inxOfValid = true(1, numOfNames);
                    for i = 1 : numel(namesToAutoswap)
                        name = namesToAutoswap{i};
                        inx = strcmp(name, this.AutoswapPairs(:, 1)) ...
                            | strcmp(name, this.AutoswapPairs(:, 2));
                        if any(inx)
                            inxToAutoswap = inxToAutoswap | inx;
                        else
                            inxOfValid(i) = false;
                        end
                    end
                    if any(~inxOfValid)
                        THIS_ERROR = { 'Plan:CannotAutoswapName'
                                       'Cannot autoswap this name: %s ' };
                        throw( exception.Base(THIS_ERROR, 'error'), ...
                               namesToAutoswap{~inxOfValid} );
            end
                end%
        end%


            



        function this = extendWithDummies(this, numOfPeriods)
            if numOfPeriods==0
                return
            end
            this.IdOfAnticipatedEndogenized(:, end+(1:numOfPeriods)) = uint16(0);
            this.IdOfUnanticipatedEndogenized(:, end+(1:numOfPeriods)) = uint16(0);
            this.IdOfAnticipatedExogenized(:, end+(1:numOfPeriods)) = uint16(0);
            this.IdOfUnanticipatedExogenized(:, end+(1:numOfPeriods)) = uint16(0);
        end%
    end


    methods % Display




        function [ inxOfExogenized, ...
                   inxOfEndogenized ] = getSwapsWithinTimeFrame( this, ...
                                                                 firstColumnOfTimeFrame, ...
                                                                 lastColumnOfSimulation )
            inxOfExogenized = false(this.NumOfEndogenous, this.NumOfExtendedPeriods);
            inxOfEndogenized = false(this.NumOfExogenous, this.NumOfExtendedPeriods);
            if this.NumOfExogenizedPoints>0
                inxOfExogenized(:, firstColumnOfTimeFrame) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnOfTimeFrame) ...
                    | this.InxOfUnanticipatedExogenized(:, firstColumnOfTimeFrame);
                inxOfExogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation);
            end
            if this.NumOfEndogenizedPoints>0
                inxOfEndogenized(:, firstColumnOfTimeFrame) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnOfTimeFrame) ...
                    | this.InxOfUnanticipatedEndogenized(:, firstColumnOfTimeFrame);
                inxOfEndogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnOfTimeFrame+1:lastColumnOfSimulation);
            end
        end%
    end


    methods (Access=private)
        function [this, outputAnticipationStatus] = implementExogenize(this, dates, names, id, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementExogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToExogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('NamesToExogenize', @(x) isequal(x, @all) || validate.list(x));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            parser.parse(this, dates, names, varargin{:});
            opt = parser.Options;

            anticipationStatusOfEndogenous = this.AnticipationStatusOfEndogenous;
            if ~isequal(opt.AnticipationStatus, @auto)
                anticipationStatusOfEndogenous(:) = opt.AnticipationStatus;
            end
            context = (id==uint16(0)) : { 'be unexogenized', 'be exogenized' };
            inxOfDates = resolveDates(this, dates);
            inxOfNames = this.resolveNames(names, this.NamesOfEndogenous, context);
            if ~any(inxOfNames)
                return
            end
            posOfNames = find(inxOfNames);
            outputAnticipationStatus = logical.empty(0, 1);
            for column = transpose(posOfNames(:))
                if id~=uint16(0)
                    % Exogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfEndogenous(column);
                    if anticipationStatusOfEndogenous(column)
                        this.IdOfAnticipatedExogenized(inxOfNames, inxOfDates) = id;
                    else
                        this.IdOfUnanticipatedExogenized(inxOfNames, inxOfDates) = id;
                    end
                else
                    % Unexogenize
                    this.IdOfAnticipatedExogenized(inxOfNames, inxOfDates) = id;
                    this.IdOfUnanticipatedExogenized(inxOfNames, inxOfDates) = id;
                end
            end
        end%




        function [this, outputAnticipationStatus] = implementEndogenize(this, dates, names, id, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementEndogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToEndogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('NamesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            parser.parse(this, dates, names);
            opt = parser.Options;

            anticipationStatusOfExogenous = this.AnticipationStatusOfExogenous;
            if ~isequal(opt.AnticipationStatus, @auto)
                anticipationStatusOfExogenous(:) = opt.AnticipationStatus;
            end
            context = (id==uint16(0)) : {'be unendogenized', 'be endogenized'};
            inxOfDates = resolveDates(this, dates);
            inxOfNames = this.resolveNames(names, this.NamesOfExogenous, context);
            if ~any(inxOfNames)
                return
            end
            posOfNames = find(inxOfNames);
            posOfNames = transpose(posOfNames(:));
            outputAnticipationStatus = logical.empty(0, 1);
            for column = transpose(posOfNames(:))
                if id~=uint16(0)
                    % Endogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfExogenous(column);
                    if anticipationStatusOfExogenous(column)
                        this.IdOfAnticipatedEndogenized(column, inxOfDates) = id;
                    else
                        this.IdOfUnanticipatedEndogenized(column, inxOfDates) = id;
                    end
                else
                    % Unendogenize
                    this.IdOfAnticipatedEndogenized(column, inxOfDates) = id;
                    this.IdOfUnanticipatedEndogenized(column, inxOfDates) = id;
                end
            end
        end%


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
    end


    properties (Dependent)
        StartDate
        EndDate
        LastAnticipatedExogenizedDate
        LastUnanticipatedExogenizedDate
        LastAnticipatedEndogenizedDate
        LastUnanticipatedEndogenizedDate

        InxOfAnticipatedExogenized
        InxOfUnanticipatedExogenized
        InxOfAnticipatedEndogenized
        InxOfUnanticipatedEndogenized

        DisplayRange
        BaseRange
        ExtendedRange
        LastAnticipatedExogenized
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


        function value = get.StartDate(this)
            value = DateWrapper.toDefaultString(this.BaseStart);
        end%



        function value = get.EndDate(this)
            value = DateWrapper.toDefaultString(this.BaseEnd);
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


        function value = get.LastAnticipatedExogenizedDate(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfAnticipatedExogenized);
        end%


        function value = get.LastUnanticipatedExogenizedDate(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfUnanticipatedExogenized);
        end%


        function value = get.LastAnticipatedEndogenizedDate(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfAnticipatedEndogenized);
        end%


        function value = get.LastUnanticipatedEndogenizedDate(this)
            value = hereGetLastDate(this.ExtendedStart, this.InxOfUnanticipatedEndogenized);
        end%


        function value = get.LastAnticipatedExogenized(this)
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
            SERIES = Series(this.BaseStart, false(this.NumOfBasePeriods, 1));
            numOfNames = numel(names);
            for i = 1 : numOfNames
                name = names{i};
                values = transpose(anchors(i, baseRangeColumns));
                output.(name) = fill(SERIES, values, this.BaseStart);
            end
        end%
    end


    methods (Static)
        function this = fromModel(varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.Plan');
                parser.addRequired('Model', @(x) isa(x, 'model.Plan'));
                parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                parser.addParameter({'DefaultAnticipationStatus', 'DefaultAnticipate', 'Anticipate'}, true, @(x) isequal(x, true) || isequal(x, false));
            end
            parser.parse(varargin{:});
            opt = parser.Options;

            this = Plan( );
            this.BaseStart = double(parser.Results.SimulationRange(1));
            this.BaseEnd = double(parser.Results.SimulationRange(end));
            this = preparePlan(parser.Results.Model, this, [this.BaseStart, this.BaseEnd]);
            this.DefaultAnticipationStatus = opt.DefaultAnticipationStatus;
            this.IdOfAnticipatedExogenized = zeros(this.NumOfEndogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfUnanticipatedExogenized = zeros(this.NumOfEndogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfAnticipatedEndogenized = zeros(this.NumOfExogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfUnanticipatedEndogenized = zeros(this.NumOfExogenous, this.NumOfExtendedPeriods, 'uint16');
            this.AnticipationStatusOfEndogenous = repmat(this.DefaultAnticipationStatus, this.NumOfEndogenous, 1);
            this.AnticipationStatusOfExogenous = repmat(this.DefaultAnticipationStatus, this.NumOfExogenous, 1);
        end%

        
        function inxOfNames = resolveNames(selectNames, allNames, context, throwError)
            if nargin<4
                throwError = true;
            end
            if isequal(selectNames, @all)
                inxOfNames = true(1, numel(allNames));
                return
            end
            if ~iscellstr(selectNames)
                selectNames = cellstr(selectNames);
            end
            [inxOfValidNames, posOfNames] = ismember(selectNames, allNames);
            if throwError && any(~inxOfValidNames)
                THIS_ERROR = { 'Plan:InvalidNameInContext'
                               'This name cannot %1 in simulation plan: %s ' };
                throw( exception.Base(THIS_ERROR, 'error'), ...
                       context, selectNames{~inxOfValidNames} );
            end
            posOfNames(~inxOfValidNames) = [ ];
            inxOfNames = false(1, numel(allNames));
            inxOfNames(posOfNames) = true;
        end%
    end




    methods (Access=protected)
        function pg = getPropertyGroups(~)
            pg1 = matlab.mixin.util.PropertyGroup( { 'StartDate'
                                                     'EndDate' 
                                                     'DefaultAnticipationStatus'
                                                     'AllowUnderdetermined'
                                                     'AllowOverdetermined' } );

            pg2 = matlab.mixin.util.PropertyGroup( { 'LastAnticipatedExogenized'
                                                     'LastUnanticipatedExogenized'
                                                     'LastAnticipatedEndogenized'
                                                     'LastUnanticipatedEndogenized' }); 

            pg3 = matlab.mixin.util.PropertyGroup( { 'NumOfAnticipatedExogenizedPoints'
                                                     'NumOfUnanticipatedExogenizedPoints'
                                                     'NumOfAnticipatedEndogenizedPoints'
                                                     'NumOfUnanticipatedEndogenizedPoints' }); 
            pg = [pg1, pg2, pg3];
        end%
    end
end


%
% Local Functions
%

function dateString = hereGetLastDate(start, id)
    inx = not(id==0);
    if not(any(inx(:)))
        column = NaN;
        date = NaN;
        dateString = DateWrapper.toDefaultString(NaN);
        return
    end
    column = find(any(inx, 1), 1, 'Last');
    date = DateWrapper.roundPlus(start, column-1);
    dateString = DateWrapper.toDefaultString(date);
end%

