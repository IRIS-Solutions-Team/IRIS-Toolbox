classdef Plan
    properties
        NamesOfEndogenous = cell.empty(1, 0)
        NamesOfExogenous = cell.empty(1, 0)
        BaseStart = double.empty(0)
        BaseEnd = double.empty(0)
        ExtendedStart = double.empty(0)
        ExtendedEnd = double.empty(0)

        SwapId = uint16(2)

        IdOfAnticipatedExogenized = logical.empty(0, 0)
        IdOfUnanticipatedExogenized = logical.empty(0, 0)

        AnticipationStatusOfExogenous = logical.empty(0)
        IdOfAnticipatedEndogenized = logical.empty(0, 0)
        IdOfUnanticipatedEndogenized = logical.empty(0, 0)
    end


    properties (SetAccess=protected)
        DefaultAnticipationStatus = true
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
            this.IdOfAnticipatedExogenized = zeros(this.NumOfEndogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfUnanticipatedExogenized = zeros(this.NumOfEndogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfAnticipatedEndogenized = zeros(this.NumOfExogenous, this.NumOfExtendedPeriods, 'uint16');
            this.IdOfUnanticipatedEndogenized = zeros(this.NumOfExogenous, this.NumOfExtendedPeriods, 'uint16');
            this.SwapId = uint16(2);
            this.AnticipationStatusOfExogenous = repmat(this.DefaultAnticipationStatus, this.NumOfExogenous, 1);
        end%
    end


    methods % User Interface
        function this = anticipate(this, anticipationStatus, names)
            if islogical(names)
                [names, anticipationStatus] = deal(anticipationStatus, names);
            end
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
            inxOfEndogenized = this.resolveNames(names, this.NamesOfExogenous, context);
            this.AnticipationStatusOfExogenous(inxOfEndogenized) = anticipationStatus;
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


        function [this, anticipationStatus] = endogenize(this, dates, names, varargin)
            setToValue = uint16(1);
            [this, anticipationStatus] = implementEndogenize(this, dates, names, setToValue, varargin{:});
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


        function this = swap(this, dates, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.swap');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToSwap', @DateWrapper.validateDateInput);
                parser.addRequired('PairsToSwap', @validatePairsToSwap);
            end
            parser.parse(this, dates, varargin);
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
                setToValue = this.SwapId;
                this.SwapId = this.SwapId + uint16(1);
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
            if isData
                cellData = cell.empty(0, 2*numOfDates);
            else
                cellData = cell.empty(0, numOfDates);
            end
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
                if isData
                    tableData{t} = cellData(:, (t-1)*2+(1:2));
                else
                    tableData{t} = cellData(:, t);
                end
            end
            outputTable = table(idColumn, tableData{:});
            outputTable.Properties.RowNames = rowNames;
            outputTable.Properties.VariableNames = [{'SwapId'}, dateNames];

            % Write table to text or spreadsheet file
            if ~isempty(opt.WriteTable)
                writetable(outputTable, opt.WriteTable, 'WriteRowNames', true);
            end
        end%
    end


    methods (Access=private)
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
            if setToValue~=uint16(0)
                context = 'be exogenized';
            else
                context = 'be unexogenized';
            end
            inxOfDates = resolveDates(this, dates);
            inxOfNames = this.resolveNames(names, this.NamesOfEndogenous, context);
            if setToValue~=uint16(0)
                % Exogenize
                if opt.Anticipate
                    this.IdOfAnticipatedExogenized(inxOfNames, inxOfDates) = setToValue;
                else
                    this.IdOfUnanticipatedExogenized(inxOfNames, inxOfDates) = setToValue;
                end
            else
                % Unexogenize
                this.IdOfAnticipatedExogenized(inxOfNames, inxOfDates) = setToValue;
                this.IdOfUnanticipatedExogenized(inxOfNames, inxOfDates) = setToValue;
            end
        end%


        function [this, anticipationStatus] = implementEndogenize(this, dates, names, setToValue, varargin)
            persistent parser
            if isempty(parser)
                parser = extend.InputParser('Plan.implementEndogenize');
                parser.addRequired('Plan', @(x) isa(x, 'Plan'));
                parser.addRequired('DatesToEndogenize', @(x) isequal(x, @all) || DateWrapper.validateDateInput(x));
                parser.addRequired('NamesToEndogenize', @(x) isequal(x, @all) || ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            parser.parse(this, dates, names);
            if setToValue~=uint16(0)
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
                if setToValue~=uint16(0)
                    % Endogenize
                    if this.AnticipationStatusOfExogenous(pos)
                        this.IdOfAnticipatedEndogenized(pos, inxOfDates) = setToValue;
                    else
                        this.IdOfUnanticipatedEndogenized(pos, inxOfDates) = setToValue;
                    end
                else
                    % Unendogenize
                    this.IdOfAnticipatedEndogenized(pos, inxOfDates) = setToValue;
                    this.IdOfUnanticipatedEndogenized(pos, inxOfDates) = setToValue;
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

