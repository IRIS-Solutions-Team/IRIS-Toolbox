classdef Plan
    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
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
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.Plan');
                parser.addRequired('Model', @(x) isa(x, 'model.Plan'));
                parser.addRequired('SimulationRange', @DateWrapper.validateProperRangeInput);
                parser.addParameter({'DefaultAnticipationStatus', 'DefaultAnticipate', 'Anticipate'}, true, @(x) isequal(x, true) || isequal(x, false));
            end
            if nargin==0
                return
            end
            parser.parse(varargin{:});
            opt = parser.Options;
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
    end




    methods % User Interface
        function this = anticipate(this, anticipationStatus, names)
% anticipate  Set anticipation status for individual shocks
%
% __Syntax__
%
%     plan = anticipate(plan, anticipationStatus, names)
%
%
% __Input Arguments__
%
% * `plan` [ Plan ] - Simulation plan.
%
% * `anticipatioStatus` [ true | false ] - New anticipation status for the
% shocks listed in `names`.
%
% * `names` [ char | string | cellstr ] - List of shocks whose anticipation
% status will be set to `anticipationStatus`.
%
%
% __Output Arguments__
%
% * p [ Plan ] - Simulation plan with a new anticipation status for the
% specified shocks.
%
%
% __Description__
%
%
% __Example__
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.anticipate');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('AnticipationStatus', @Valid.logicalScalar);
                parser.addRequired('NamesOfExogenous', @Valid.list);
            end
            if this.NumOfEndogenizedPoints>0
                THIS_ERROR = { 'Plan:CannotChangeAnticipateAfterEndogenize'
                               'Cannot change anticipation status after some names have been already endogenized' };
                throw( exception.Base(THIS_ERROR, 'error') );
            end
            parser.parse(this, anticipationStatus, names);
            context = 'be assigned anticipation status';
            this.resolveNames(names, this.AllNames, context);
            throwError = false;
            inxOfEndogenous = this.resolveNames(names, this.NamesOfEndogenous, context, throwError);
            if any(inxOfEndogenous)
                this.AnticipationStatusOfEndogenous(inxOfEndogenous) = anticipationStatus;
            end
            inxOfExogenous = this.resolveNames(names, this.NamesOfExogenous, context, throwError);
            if any(inxOfExogenous)
                this.AnticipationStatusOfExogenous(inxOfExogenous) = anticipationStatus;
            end
        end%




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


        function this = swap(this, dates, varargin)
            if isempty(varargin)
                pairsToSwap = cell.empty(1, 0);
            elseif numel(varargin)==1 && isstruct(varargin{1})
                pairsToSwap = varargin{1};
                varargin(1) = [ ];
            else
                inxOfPairs = cellfun(@(x) (iscellstr(x) || isa(x, 'string')) && numel(x)==2, varargin);
                pairsToSwap = cell.empty(1, 0);
                while ~isempty(inxOfPairs) && inxOfPairs(1)
                    pairsToSwap{end+1} = varargin{1};
                    varargin(1) = [ ];
                    inxOfPairs(1) = [ ];
                end
            end
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.swap');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToSwap', @DateWrapper.validateDateInput);
                parser.addRequired('PairsToSwap', @validatePairsToSwap);
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || Valid.logicalScalar(x));
            end
            parser.parse(this, dates, pairsToSwap, varargin{:});
            opt = parser.Options;
            if numel(varargin)==1 && isstruct(varargin{1})
                inputStruct = varargin{1};
                namesToExogenize = fieldnames(inputStruct);
                numOfPairs = numel(namesToExogenize);
                pairsToSwap = cell(1, numOfPairs);
                for i = 1 : numOfPairs
                    pairsToSwap{i} = { namesToExogenize{i}, ...
                                       inputStruct.(namesToExogenize{i}) };
                end
            end
            numOfPairs = numel(pairsToSwap);
            anticipationMismatch = cell(1, 0);
            for i = 1 : numOfPairs
                setToValue = this.SwapId;
                this.SwapId = this.SwapId + uint16(1);
                [nameToExogenize, nameToEndogenize] = pairsToSwap{i}{:};

                [this, anticipateEndogenized] = ...
                    implementEndogenize( this, ...
                                         dates, ...
                                         nameToEndogenize, ...
                                         setToValue, ...
                                         'AnticipationStatus=', opt.AnticipationStatus );

                [this, anticipateExogenized] = ...
                    implementExogenize( this, ...
                                        dates, ...
                                        nameToExogenize, ...
                                        setToValue, ...
                                        'AnticipationStatus=', opt.AnticipationStatus );

                if ~isequal(anticipateEndogenized, anticipateExogenized)
                    anticipationMismatch{end+1} = sprintf( '%s[%s] <-> %s[%s]', ...
                                                           nameToExogenize, ...
                                                           statusToString(anticipateExogenized), ...
                                                           nameToEndogenize, ...
                                                           statusToString(anticipateEndogenized) );
                    % Do the swap using the anticipation status of the shock
                    % This is for GPMN compatibility only
                    % Will be removed in the near future
                    [this, anticipateEndogenized] = ...
                        implementEndogenize( this, ...
                                             dates, ...
                                             nameToEndogenize, ...
                                             setToValue, ...
                                             'AnticipationStatus=', anticipateEndogenized );

                    [this, anticipateExogenized] = ...
                        implementExogenize( this, ...
                                            dates, ...
                                            nameToExogenize, ...
                                            setToValue, ...
                                            'AnticipationStatus=', anticipateEndogenized );
                end
            end
            if ~isempty(anticipationMismatch)
                THIS_ERROR = { 'Plan:AnticipationStatusMismatch' 
                               [ 'Anticipation status mismatch in this swapped pair: %s \n', ...
                                 '    Use anticipate(~) to align anticipation status of the paired variable and shock\n', ...
                                 '    This warning will become an error in a future IRIS release' ] };
                throw( exception.Base(THIS_ERROR, 'warning'), ...
                       anticipationMismatch{:} );
            end
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
        function outputTable = table(this, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.table');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addParameter('InputDatabank', [ ], @(x) isempty(x) || isstruct(x));
                parser.addParameter('WriteTable', '', @(x) isempty(x) || ischar(x) || isa(x, 'string'));
            end
            parse(parser, this, varargin{:});
            opt = parser.Options;
            inxOfDates = any( [ this.InxOfAnticipatedExogenized 
                                this.InxOfUnanticipatedExogenized
                                this.InxOfAnticipatedEndogenized
                                this.InxOfUnanticipatedEndogenized ], 1 );
            numOfDates = nnz(inxOfDates);
            posOfDates = find(inxOfDates);
            dates = this.ExtendedStart + posOfDates - 1;
            inxOfExogenized = any( this.InxOfAnticipatedExogenized ...
                                 | this.InxOfUnanticipatedExogenized, 2 );
            numOfExogenized = nnz(inxOfExogenized);
            inxOfEndogenized = any( this.InxOfAnticipatedEndogenized ...
                                  | this.InxOfUnanticipatedEndogenized, 2 );
            dateNames = DateWrapper.toCellOfChar(dates);
            dateNames = strcat(this.DATE_PREFIX, dateNames);

            isData = false;
            data = cell.empty(0, 0);
            if ~isempty(opt.InputDatabank)
                data = databank.toDoubleArray(opt.InputDatabank, this.NamesOfEndogenous, this.ExtendedRange, 1);
                data = transpose(data);
                isData = true;
            end

            rowNames = cell.empty(1, 0);
            idColumn = uint16.empty(0, 1);
            cellData = isData : { cell.empty(0, 2*numOfDates), cell.empty(0, numOfDates) };
            for id = uint16(1) : this.SwapId
                markExogenized = cell(this.NumOfEndogenous, this.NumOfExtendedPeriods);
                inxOfAnticipated = this.IdOfAnticipatedExogenized==id;
                inxOfUnanticipated = this.IdOfUnanticipatedExogenized==id;
                inxOfExogenized = inxOfAnticipated | inxOfUnanticipated;
                anyExogenized = any(inxOfExogenized(:));
                if anyExogenized
                    markExogenized(inxOfAnticipated) = { this.ANTICIPATED_MARK };
                    markExogenized(inxOfUnanticipated) = { this.UNANTICIPATED_MARK };
                    keep = any(inxOfAnticipated | inxOfUnanticipated, 2);
                    markExogenized = markExogenized(keep, inxOfDates);
                    rowNames = [rowNames, this.NamesOfEndogenous(keep)];
                    idColumn = [idColumn; repmat(id-1, nnz(keep), 1)];
                    if isData
                        valuesOfExogenized = nan(this.NumOfEndogenous, this.NumOfExtendedPeriods);
                        valuesOfExogenized(inxOfExogenized) = data(inxOfExogenized);
                        valuesOfExogenized = valuesOfExogenized(keep, inxOfDates);
                        valuesOfExogenized = num2cell(valuesOfExogenized);
                        addCellData = cell(nnz(keep), 2*nnz(inxOfDates));
                        addCellData(:, 1:2:end) = markExogenized;
                        addCellData(:, 2:2:end) = valuesOfExogenized;
                        cellData = [cellData; addCellData];
                    else
                        cellData = [cellData; markExogenized];
                    end
                end

                inxOfAnticipated = this.IdOfAnticipatedEndogenized==id;
                inxOfUnanticipated = this.IdOfUnanticipatedEndogenized==id;
                anyEndogenized = any(inxOfAnticipated(:)) || any(inxOfUnanticipated(:));
                if anyEndogenized
                    markEndogenized = cell(this.NumOfExogenous, this.NumOfExtendedPeriods);
                    markEndogenized(inxOfAnticipated) = { this.ANTICIPATED_MARK };
                    markEndogenized(inxOfUnanticipated) = { this.UNANTICIPATED_MARK };
                    keep = any(inxOfAnticipated | inxOfUnanticipated, 2);
                    markEndogenized = markEndogenized(keep, inxOfDates);
                    rowNames = [rowNames, this.NamesOfExogenous(keep)];
                    idColumn = [idColumn; repmat(id-1, nnz(keep), 1)];
                    if isData
                        addCellData = cell(nnz(keep), 2*nnz(inxOfDates));
                        addCellData(:, 1:2:end) = markEndogenized;
                        addCellData(:, 2:2:end) = {[ ]};
                        cellData = [cellData; addCellData];
                    else
                        cellData = [cellData; markEndogenized];
                    end
                end
            end

            tableData = cell(1, numOfDates);
            for t = 1 : numOfDates
                tableData{t} = isData : { cellData(:, (t-1)*2+(1:2)), cellData(:, t) };
            end
            outputTable = table(idColumn, tableData{:});
            outputTable.Properties.RowNames = rowNames;
            outputTable.Properties.VariableNames = [{'SwapId'}, dateNames];

            % Write table to text or spreadsheet file
            if ~isempty(opt.WriteTable)
                writetable(outputTable, opt.WriteTable, 'WriteRowNames', true);
            end
        end%




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
                parser.addRequired('NamesToExogenize', @(x) isequal(x, @all) || Valid.list(x));
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || Valid.logicalScalar(x));
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
            for pos = transpose(posOfNames(:))
                if id~=uint16(0)
                    % Exogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfEndogenous(pos);
                    if anticipationStatusOfEndogenous(pos)
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
                parser.addParameter({'AnticipationStatus', 'Anticipate'}, @auto, @(x) isequal(x, @auto) || Valid.logicalScalar(x));
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
            for pos = transpose(posOfNames(:))
                if id~=uint16(0)
                    % Endogenize
                    outputAnticipationStatus(end+1, 1) = anticipationStatusOfExogenous(pos);
                    if anticipationStatusOfExogenous(pos)
                        this.IdOfAnticipatedEndogenized(pos, inxOfDates) = id;
                    else
                        this.IdOfUnanticipatedEndogenized(pos, inxOfDates) = id;
                    end
                else
                    % Unendogenize
                    this.IdOfAnticipatedEndogenized(pos, inxOfDates) = id;
                    this.IdOfUnanticipatedEndogenized(pos, inxOfDates) = id;
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
        InxOfAnticipatedExogenized
        InxOfUnanticipatedExogenized
        InxOfAnticipatedEndogenized
        InxOfUnanticipatedEndogenized

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
        function value = get.InxOfAnticipatedExogenized(this)
            value = this.IdOfAnticipatedExogenized~=0;
        end%


        function value = get.InxOfUnanticipatedExogenized(this)
            value = this.IdOfUnanticipatedExogenized~=0;
        end%


        function value = get.InxOfAnticipatedEndogenized(this)
            value = this.IdOfAnticipatedEndogenized~=0;
        end%


        function value = get.InxOfUnanticipatedEndogenized(this)
            value = this.IdOfUnanticipatedEndogenized~=0;
        end%


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




function varargout = statusToString(varargin)
    varargout = varargin;
    for i = 1 : nargin
        if isequal(varargin{i}, true)
            varargout{i} = 'true';
        else
            varargout{i} = 'false';
        end
    end
end%


