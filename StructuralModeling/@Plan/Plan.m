% Plan  Simulation Plans for Model and Explanatory objects

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef Plan ...
    < matlab.mixin.CustomDisplay

    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
        BaseStart = double.empty(0)
        BaseEnd = double.empty(0)
        ExtendedStart = double.empty(0)
        ExtendedEnd = double.empty(0)

        AutoswapPairs = cell.empty(0, 2)
        SlackPairs = string.empty(0, 2)

        SwapLink = int16(-1)

        AnticipationStatusEndogenous = logical.empty(0)
        AnticipationStatusExogenous = logical.empty(0)

        IdAnticipatedExogenized = int16.empty(0, 0)
        IdUnanticipatedExogenized = int16.empty(0, 0)
        IdAnticipatedEndogenized = int16.empty(0, 0)
        IdUnanticipatedEndogenized = int16.empty(0, 0)
        InxToKeepEndogenousNaN = logical.empty(0)

        SigmasExogenous = double.empty(0, 0)
        DefaultSigmasExogenous = double.empty(0, 0)
    end


    properties (SetAccess=protected)
        Method = @auto
        DefaultAnticipationStatus = true
        AllowUnderdetermined = true
        AllowOverdetermined = false
        NumDummyPeriods = 0
    end


    properties (Constant, Hidden)
        DEFAULT_SWAP_LINK = int16(-1)
        ZERO_SWAP_LINK = int16(0)
        TRY_SWAP_LINK = int16(-2)
        EMPTY_MARK = '.' % char.empty(1, 0)
        ANTICIPATED_MARK = 'A'
        UNANTICIPATED_MARK = 'U'
        ALWAYS_MARK = '!'
        WHEN_DATA_MARK = '?'
        DATE_PREFIX = 't'
        RANGE_DEPENDENT = [ 
            "IdAnticipatedExogenized"
            "IdUnanticipatedExogenized"
            "IdAnticipatedEndogenized"
            "IdUnanticipatedEndogenized"
            "InxToKeepEndogenousNaN"
            "SigmasExogenous" 
        ]
    end




    methods % Constructor
        %(
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
        %)
    end




    methods % User interface
        %(
        varargout = anticipate(varargin)
        varargout = assignSigma(varargin)
        varargout = autoswap(varargin)
        varargout = condition(varargin)
        varargout = endogenize(varargin)
        varargout = exogenize(varargin)
        varargout = exogenizeWhenData(varargin)
        varargout = get(varargin)
        varargout = multiplySigma(varargin)
        varargout = swap(varargin)




        function value = countVariants(this)
            value = size(this.SigmasExogenous, 3);
        end%




        function this = unexogenize(this, dates, names, varargin)
            if nargin==1
                this = unexogenizeAll(this);
                return
            end
            setToValue = int16(0);
            this = implementExogenize(this, dates, names, setToValue, varargin{:});
        end%




        function this = unexogenizeAll(this)
            this.IdAnticipatedExogenized(:, :) = int16(0);
            this.IdUnanticipatedExogenized(:, :) = int16(0);
            this.InxToKeepEndogenousNaN(:, :) = false;
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
            this.IdAnticipatedEndogenized(:, :) = int16(0);
            this.IdUnanticipatedEndogenized(:, :) = int16(0);
        end%




        function this = clear(this)
            this = unexogenizeAll(this);
            this = unendogenizeAll(this);
        end%


        function this = extendWithDummies(this, numDummyPeriods)
            if numDummyPeriods==0
                return
            end
            this.IdAnticipatedEndogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdUnanticipatedEndogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdAnticipatedExogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.IdUnanticipatedExogenized(:, end+(1:numDummyPeriods)) = int16(0);
            this.InxToKeepEndogenousNaN(:, end+(1:numDummyPeriods)) = false;
            this.SigmasExogenous(:, end+(1:numDummyPeriods), :) = NaN;
            this.NumDummyPeriods = numDummyPeriods;
        end%
    %)
    end




    methods 
        function [inxExogenized, inxEndogenized] = getSwapsWithinFrame( ...
            this, firstColumnFrame, lastColumnSimulation ...
        )
            numColumns = this.NumExtdPeriods + this.NumDummyPeriods;
            inxExogenized = logical(sparse(this.NumOfEndogenous, numColumns));
            inxEndogenized = logical(sparse(this.NumOfExogenous, numColumns));
            if this.NumOfExogenizedPoints>0
                inxExogenized(:, firstColumnFrame) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnFrame) ...
                    | this.InxOfUnanticipatedExogenized(:, firstColumnFrame);
                inxExogenized(:, firstColumnFrame+1:lastColumnSimulation) = ...
                    this.InxOfAnticipatedExogenized(:, firstColumnFrame+1:lastColumnSimulation);
            end
            if this.NumOfEndogenizedPoints>0
                inxEndogenized(:, firstColumnFrame) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnFrame) ...
                    | this.InxOfUnanticipatedEndogenized(:, firstColumnFrame);
                inxEndogenized(:, firstColumnFrame+1:lastColumnSimulation) = ...
                    this.InxOfAnticipatedEndogenized(:, firstColumnFrame+1:lastColumnSimulation);
            end
        end%
    end




    methods (Access=private, Hidden)
        function [this, outputAnticipationStatus] = implementExogenize(this, dates, names, id, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('Plan.implementExogenize');
                addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
                addRequired(pp, 'datesToExogenize', @(x) isequal(x, @all) || validate.date(x));
                addRequired(pp, 'namesToExogenize', @(x) isequal(x, @all) || validate.list(x));
                addParameter(pp, {'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
                addParameter(pp, 'MissingValue', 'Error', @(x) validate.anyString(x, 'Error', 'KeepEndogenous'));
            end
            pp.parse(this, dates, names, varargin{:});
            opt = pp.Options;

            anticipationStatusOfEndogenous = this.AnticipationStatusEndogenous;
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
                        this.IdAnticipatedExogenized(inxNames, inxDates) = id;
                    else
                        this.IdUnanticipatedExogenized(inxNames, inxDates) = id;
                    end
                    % Exogenize only when data available
                    this.InxToKeepEndogenousNaN(inxNames, inxDates) = strcmpi(opt.MissingValue, 'KeepEndogenous');
                else
                    % Unexogenize
                    this.IdAnticipatedExogenized(inxNames, inxDates) = id;
                    this.IdUnanticipatedExogenized(inxNames, inxDates) = id;
                    this.InxToKeepEndogenousNaN(inxNames, inxDates) = false;
                end
            end
        end%


        function [this, outputAnticipationStatus] = implementEndogenize(this, dates, names, id, varargin)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('Plan.implementEndogenize');
                addRequired(pp, 'plan', @(x) isa(x, 'Plan'));
                addRequired(pp, 'datesToEndogenize', @(x) isequal(x, @all) || validate.date(x));
                addRequired(pp, 'namesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
                addParameter(pp, {'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || validate.logicalScalar(x));
            end
            pp.parse(this, dates, names, varargin{:});
            opt = pp.Options;

            anticipationStatusOfExogenous = this.AnticipationStatusExogenous;
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
                        this.IdAnticipatedEndogenized(column, inxDates) = id;
                    else
                        this.IdUnanticipatedEndogenized(column, inxDates) = id;
                    end
                else
                    % Unendogenize
                    this.IdAnticipatedEndogenized(column, inxDates) = id;
                    this.IdUnanticipatedEndogenized(column, inxDates) = id;
                end
            end
        end%




        function inxDates = resolveDates(this, dates)
            if isequal(dates, @all) || isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
                inxDates = false(1, this.NumExtdPeriods);
                inxDates(this.PosOfBaseStart:this.PosOfBaseEnd) = true;
                return
            end
            posDates = Dater.getRelativePosition( this.ExtendedStart, dates, ...
                                                        [this.PosOfBaseStart, this.PosOfBaseEnd], ...
                                                        'simulation Plan range' );
            inxDates = false(1, this.NumExtdPeriods);
            inxDates(posDates) = true;
        end%




        function inxVariants = resolveVariants(this, variants)
            numVariants = countVariants(this);
            if isequal(variants, @all)
                inxVariants = true(1, numVariants);
                return
            end
            if all(variants==round(variants) & variants>=1 & variants<=numVariants);
                inxVariants = variants;
                return
            end
            if islogical(variants) && numel(variants)==numVariants
                variants = reshape(variants, 1, [ ]);
                return
            end
            thisError = [ "Plan:InvalidVariant"
                          "Plan variants need to be specified as integers "
                          "between 1 and the total number of variants in the Plan object." ];
            throw(exception.Base(thisError, 'error'));
        end%
    end


    properties (Dependent)
        LastAnticipatedExogenized
        LastUnanticipatedExogenized
        LastAnticipatedEndogenized
        LastUnanticipatedEndogenized
        HasExogenized
        InxAllExogenized


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
        BaseRangeColumns
        ExtendedRange
        ColumnLastAnticipatedExogenized
        NumOfEndogenous
        NumOfExogenous
        NumBasePeriods
        NumExtdPeriods
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
        function values = get.InxAllExogenized(this)
            numColumns = this.NumExtdPeriods + this.NumDummyPeriods;
            inxAllExogenized = logical(sparse(this.NumOfEndogenous, numColumns));
            if this.NumOfExogenizedPoints>0
                inxExogenized(:, :) = this.InxOfAnticipatedExogenized | this.InxOfUnanticipatedExogenized;
            end
        end%


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
                    thisError = { 'Plan:InvalidAutoswapPairs'
                                   'Invalid value assigned to @Plan.AutoswapPairs' };
                    throw( exception.Base(thisError, 'error') );
                end%
        end%


        function value = get.Start(this)
            value = Dater(this.BaseStart);
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
                pass = Frequency.sameFrequency( dater.getFrequency(this.BaseStart), ...
                                                dater.getFrequency(value) );
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
                for name = reshape(this.RANGE_DEPENDENT, 1, [ ])
                    this.(name) = this.(name)(:, shift+1:end, :);
                end
            elseif shift<0
                for name = reshape(this.RANGE_DEPENDENT, 1, [ ])
                    numRows = size(this.(name), 1);
                    numPages = size(this.(name), 3);
                    if name=="SigmasExogenous"
                        add = repmat(this.DefaultSigmasExogenous, 1, -shift, 1);
                    else
                        add = zeros(numRows, -shift, numPages, 'like', this.(name));
                    end
                    this.(name) = [add, this.(name)];
                end
            end
            this.BaseStart = dater.plus(this.BaseStart, shift);
            this.ExtendedStart = dater.plus(this.ExtendedStart, shift);
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
                pass = Frequency.sameFrequency( dater.getFrequency(this.BaseEnd), ...
                                                dater.getFrequency(value) );
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
                for name = reshape(this.RANGE_DEPENDENT, 1, [ ])
                    numRows = size(this.(name), 1);
                    numPages = size(this.(name), 3);
                    if name=="SigmasExogenous"k
                        add = repmat(this.DefaultSigmasExogenous, 1, shift, 1);
                    else
                        add = zeros(numRows, shift, numPages, "like", this.(name));
                    end
                    this.(name) = [this.(name), add];
                end
            elseif shift<0
                for name = reshape(this.RANGE_DEPENDENT, 1, [ ])
                    this.(name) = this.(name)(:, 1:end+shift, :);
                end
            end
            this.BaseEnd = dater.plus(this.BaseEnd, shift);
            this.ExtendedEnd = dater.plus(this.ExtendedEnd, shift);
            this = resetOutsideBaseRange(this);
            %)
        end%




        function value = get.End(this)
            value = Dater(this.BaseEnd);
        end%


        function value = get.HasExogenized(this)
            value = this.NumOfExogenizedPoints>0;
        end%


        function value = get.InxOfAnticipatedExogenized(this)
            value = not(this.IdAnticipatedExogenized==0);
        end%




        function value = get.InxOfUnanticipatedExogenized(this)
            value = not(this.IdUnanticipatedExogenized==0);
        end%




        function value = get.InxOfAnticipatedEndogenized(this)
            value = not(this.IdAnticipatedEndogenized==0);
        end%




        function value = get.InxOfUnanticipatedEndogenized(this)
            value = not(this.IdUnanticipatedEndogenized==0);
        end%




        function value = get.DisplayRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = '';
                return
            end
            displayStart = Dater.toCellstr(this.BaseStart);
            displayEnd = Dater.toCellstr(this.BaseEnd);
            value = [displayStart{1}, ':', displayEnd{1}]; 
        end%


        function value = get.BaseRange(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = Dater(NaN);
                return
            end
            value = dater.colon(this.BaseStart, this.BaseEnd);
            value = Dater(value);
        end%


        function value = get.BaseRangeColumns(this)
            startColumn = round(this.BaseStart - this.ExtendedStart + 1);
            endColumn = round(this.BaseEnd - this.ExtendedStart + 1);
            value = startColumn : endColumn;
        end%


        function value = get.ExtendedRange(this)
            if isempty(this.ExtendedStart) || isempty(this.ExtendedEnd)
                value = Dater(NaN);
                return
            end
            value = dater.colon(this.ExtendedStart, this.ExtendedEnd);
            value = Dater(value);
        end%


        function value = get.NumOfEndogenous(this)
            value = numel(this.NamesOfEndogenous);
        end%


        function value = get.NumOfExogenous(this)
            value = numel(this.NamesOfExogenous);
        end%


        function value = get.NumBasePeriods(this)
            if isempty(this.BaseStart) || isempty(this.BaseEnd)
                value = NaN;
                return
            end
            value = round(this.BaseEnd - this.BaseStart + 1);
        end%


        function value = get.NumExtdPeriods(this)
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


        function value = get.ColumnLastAnticipatedExogenized(this)
            value = find(any(this.InxOfAnticipatedExogenized, 1), 1, 'last');
            if isempty(value)
                value = 0;
            end
        end%


        function value = get.NamesOfAnticipated(this)
            value = this.NamesOfExogenous(this.AnticipationStatusExogenous);
        end%


        function value = get.NamesOfUnanticipated(this)
            value = this.NamesOfExogenous(~this.AnticipationStatusExogenous);
        end%


        function value = get.StructWithAnticipationStatus(this)
            temp = num2cell(this.AnticipationStatusExogenous);
            value = cell2struct(temp, cellstr(this.NamesOfExogenous), 1);
        end%


        function value = get.AllNames(this)
            value = [this.NamesOfEndogenous, this.NamesOfExogenous];
        end%


        function output = get.DatabankOfAnticipatedExogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfEndogenous, ...
                                              this.IdAnticipatedExogenized );
        end%


        function output = get.DatabankOfUnanticipatedExogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfEndogenous, ...
                                              this.IdUnanticipatedExogenized );
        end%


        function output = get.DatabankOfAnticipatedEndogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfExogenous, ...
                                              this.IdAnticipatedEndogenized );
        end%


        function output = get.DatabankOfUnanticipatedEndogenized(this)
            output = createDatabankOfAnchors( this, ...
                                              this.NamesOfExogenous, ...
                                              this.IdAnticipatedEndogenized );
        end%


        function output = createDatabankOfAnchors(this, names, anchors)
            output = struct( );
            baseRangeColumns = this.PosOfBaseStart : this.PosOfBaseEnd;
            template = Series(this.BaseStart, false(this.NumBasePeriods, 1));
            numNames = numel(names);
            for i = 1 : numNames
                name = names{i};
                values = transpose(anchors(i, baseRangeColumns));
                output.(name) = fill(template, values, this.BaseStart);
            end
        end%
    end


    methods (Static) % Static Constructor Signatures
        %(
        varargout = forModel(varargin)
        varargout = forComodel(varargin)
        varargout = forExplanatory(varargin)

        function varargout = forExplanatoryEquation(varargin)
            [varargout{1:nargout}] = Plan.forExplanatory(varargin{:});
        end%
        %)
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
                exception.error([
                    "Plan:InvalidNameInContext"
                    "This name cannot %1 in the simulation Plan: %s "
                ], context, selectNames{~inxValidNames});
            end
            posNames(~inxValidNames) = [ ];
            inxNames = false(1, numel(allNames));
            inxNames(posNames) = true;
        end%
    end




    methods (Access=protected, Hidden)
        function pg = getPropertyGroups(this)
            toChar = @(x) char(dater.toDefaultString(x));

            % Dates
            s1 = struct( ...
                'Start',                        toChar(this.Start), ...
                'End',                          toChar(this.End), ...
                'LastAnticipatedExogenized',    toChar(this.LastAnticipatedExogenized), ...
                'LastUnanticipatedExogenized',  toChar(this.LastUnanticipatedExogenized), ...
                'LastAnticipatedEndogenized',   toChar(this.LastAnticipatedEndogenized), ...
                'LastUnanticipatedEndogenized', toChar(this.LastUnanticipatedEndogenized) ...
            );
            pg1 = matlab.mixin.util.PropertyGroup(s1, 'SimulationDates');

            % Switches
            pg2 = matlab.mixin.util.PropertyGroup({ 
                'DefaultAnticipationStatus'
                'AllowUnderdetermined'
                'AllowOverdetermined' 
            }, 'Switches');

            % Determinacy of the Swap System
            pg3 = matlab.mixin.util.PropertyGroup({
                'NumOfAnticipatedExogenizedPoints'
                'NumOfUnanticipatedExogenizedPoints'
                'NumOfAnticipatedEndogenizedPoints'
                'NumOfUnanticipatedEndogenizedPoints' 
            }, 'SwapPoints');

            pg = [pg1, pg2, pg3];
        end%




        function [this, id] = nextSwapLink(this)
            id = this.SwapLink;
            this.SwapLink = this.SwapLink - 1;
        end%




        function ids = getUniqueIds(this)
            list = [ 
                reshape(this.IdAnticipatedExogenized,    [ ], 1)
                reshape(this.IdUnanticipatedExogenized,  [ ], 1)
                reshape(this.IdAnticipatedEndogenized,   [ ], 1)
                reshape(this.IdUnanticipatedEndogenized, [ ], 1) 
            ];
            list(list==0) = [ ];
            list = unique(list);
            negativeIds = reshape(list(list<0), 1, [ ]);
            positiveIds = reshape(list(list>0), 1, [ ]);
            ids = [sort(negativeIds, 'descend'), sort(positiveIds, 'ascend')];
        end%




        function this = resetOutsideBaseRange(this)
            numExtendedPeriods = this.NumExtdPeriods;
            numPresample = round(this.BaseStart-this.ExtendedStart);
            if numPresample==0
                posPresample = double.empty(1, 0);
            else
                posPresample = 1 : numPresample;
            end
            numPostsample = round(this.ExtendedEnd-this.BaseEnd);
            if numPostsample==0
                posPostsample = double.empty(1, 0);
            else
                posPostsample = (numExtendedPeriods-numPostsample+1) : numExtendedPeriods;
            end
            for name = reshape(this.RANGE_DEPENDENT, 1, [ ])
                value = 0;
                if name=="SigmasExogenous"
                    value = NaN;
                end
                this.(name)(:, [posPresample, posPostsample], :) = value;
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
        date = Dater(NaN);
        return
    end
    column = find(any(inx, 1), 1, 'Last');
    date = dater.plus(start, column-1);
end%

