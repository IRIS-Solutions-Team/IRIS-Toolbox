classdef Variant
    properties
        Values = double.empty(1, 0, 0)
        StdCorr = double.empty(1, 0, 0)
        FirstOrderSolution = repmat({double.empty(0, 0, 0)}, 1, 9)
        FirstOrderExpansion = repmat({double.empty(0, 0, 0)}, 1, 5)
        IxInit = logical.empty(1, 0, 0)
        EigenValues = double.empty(1, 0, 0)
        EigenStability = int8.empty(1, 0, 0)
    end


    properties
        IndexOfStdCorrAllowed = logical.empty(1, 0, 0)
    end
    
    
    properties (Constant)
        SOLUTION_TRANSITION = [1, 2, 3, 4, 7, 8]
        SOLUTION_MEASUREMENT = [4, 5, 6, 9] 
        LIST_OF_ARRAY_PROPERTIES = {'Values', 'StdCorr', 'IxInit', 'EigenValues', 'EigenStability'}
        LIST_OF_CELL_PROPERTIES = {'FirstOrderSolution', 'FirstOrderExpansion'}
    end


    methods
        function this = Variant( numOfVariants, quantity, vector, ahead, ...
                                 numOfHashed, numOfObserved, ...
                                 defaultStd, defaultFloor )
            if nargin==0
                return
            end
            this = createIndexOfStdCorrAllowed(this, quantity);
            this = preallocateValues(this, numOfVariants, quantity);
            this = preallocateStdCorr(this, quantity, defaultStd);
            this = preallocateFloors(this, quantity, defaultFloor);
            this = preallocateSolution(this, vector, ahead, numOfHashed, numOfObserved);
        end%


        function this = createIndexOfStdCorrAllowed(this, quantity)
            TYPE = @int8;
            ixe = quantity.Type==TYPE(31) | quantity.Type==TYPE(32);
            ne = nnz(ixe);
            typeOfShocks = quantity.Type(ixe);
            ix31 = typeOfShocks==TYPE(31);
            inxOfCorrAllowed = true(ne);
            inxOfCorrAllowed(ix31, ~ix31) = false;
            inxOfCorrAllowed(~ix31, ix31) = false;
            inxOfTril = tril(ones(ne), -1)==1;
            this.IndexOfStdCorrAllowed = [true(1, ne), inxOfCorrAllowed(inxOfTril).'];
        end%
        

        function this = preallocateValues(this, numOfVariants, quantity)
            TYPE = @int8;
            numOfQuantities = length(quantity);
            if checkSize(this.Values, [1, numOfQuantities, numOfVariants])
                this.Values(:) = NaN;
            else
                this.Values = nan(1, numOfQuantities, numOfVariants);
            end
            ixe = quantity.Type==TYPE(31) | quantity.Type==TYPE(32);
            % Steady state of shocks cannot be changed from 0+0i.
            this.Values(1, ixe, :) = 0;
            % Steady state of exogenous variables preset to default.
            ixg = quantity.Type==TYPE(5);
            this.Values(1, ixg, :) = model.DEFAULT_STEADY_EXOGENOUS;
            % Steady state of ttrend cannot be changed from 0+1i.
            inxOfTimeTrend = strcmp(quantity.Name, model.RESERVED_NAME_TTREND);
            this.Values(1, inxOfTimeTrend, :) = model.STEADY_TTREND;
        end%


        function this = preallocateStdCorr(this, quantity, defaultStd)
            TYPE = @int8;
            nv = size(this.Values, 3);
            ne = nnz(quantity.Type==TYPE(31) | quantity.Type==TYPE(32));
            numOfStdCorr = ne + ne*(ne-1)/2;
            if checkSize(this.StdCorr, [1, numOfStdCorr, nv])
                this.StdCorr(:) = 0;
            else
                this.StdCorr = zeros(1, numOfStdCorr, nv);
            end
            if nargin<3
                return
            end
            if isnumeric(defaultStd) && numel(defaultStd)==1 && defaultStd>=0
                this.StdCorr(1, 1:ne, :) = defaultStd;
            end
        end%


        function this = preallocateFloors(this, quantity, defaultFloor)
            TYPE = @int8;
            inxOfFloors = ...
                strncmp(quantity.Name, model.FLOOR_PREFIX, length(model.FLOOR_PREFIX)) ...
                & quantity.Type==TYPE(4);
            this.Values(1, inxOfFloors, :) = defaultFloor;
        end%

        
        function this = preallocateSolution(this, vector, ahead, numOfHashed, numOfObserved)
            TYPE = @int8;
            nv = size(this.Values, 3);
            [ny, nxi, nb, nf, ne] = sizeOfSolution(vector);
            [~, kxi, ~, kf] = sizeOfSystem(vector);
            nh = numOfHashed;
            nz = numOfObserved;

            this.FirstOrderSolution{1} = nan(nxi, nb, nv);             % T
            this.FirstOrderSolution{2} = nan(nxi, ne*(1+ahead), nv);   % R
            this.FirstOrderSolution{3} = nan(nxi, 1, nv);              % K
            this.FirstOrderSolution{4} = nan(ny, nb, nv);              % Z
            this.FirstOrderSolution{5} = nan(ny, ne, nv);              % H
            this.FirstOrderSolution{6} = nan(ny, 1, nv);               % D
            this.FirstOrderSolution{7} = nan(nb, nb, nv);              % U
            this.FirstOrderSolution{8} = nan(nxi, nh*(1+ahead), nv);   % Y - add-factors in hashed equations
            this.FirstOrderSolution{9} = nan(max(ny, nz), nb, nv);     % Zb - non-transformed measurement.
            
            this.FirstOrderExpansion{1} = nan(nb, kf, nv); % Xa
            this.FirstOrderExpansion{2} = nan(nf, kf, nv); % Xf
            this.FirstOrderExpansion{3} = nan(kf, ne, nv); % Ru
            this.FirstOrderExpansion{4} = nan(kf, kf, nv); % J
            this.FirstOrderExpansion{5} = nan(kf, nh, nv); % Yu -- nonlin addfactors.
            
            this.EigenValues = nan(1, kxi, nv);
            this.EigenStability = zeros(1, kxi, nv, 'int8');
            this.IxInit = true(1, nb, nv);
        end%
        
        
        function this = resetTransition(this, variantsRequested, vector, numOfHashed, numOfObserved)
            TYPE = @int8;
            nv = size(this.Values, 3);
            [~, ~, ~, ~, ne] = sizeOfSolution(vector);

            % Preallocate all solution and expansion matrices first if they
            % are missing.
            if isempty(this.FirstOrderSolution{1})
                this = preallocateSolution(this, vector, 0, numOfHashed, numOfObserved);
            end

            % Solution matrix R depends on the length of expansion, and
            % needs to be updated.
            %nnActual = size(this.FirstOrderSolution{2}, 2);
            %nnRequired = ne*(1 + ahead);
            %if nnActual<nnRequired
            %    this.FirstOrderSolution{2} = [this.FirstOrderSolution{2}, nan(nxi, nnRequired-nnActual, nv)];
            %elseif nnActual>nnRequired
            %    this.FirstOrderSolution{2} = this.FirstOrderSolution{2}(:, :, 1:nnRequired);
            %end

            % Solution matrix Y depends on the length of expansion, and
            % needs to be updated.
            %nnActual = size(this.FirstOrderSolution{8}, 2);
            %nnRequired = numOfHashed*(1 + ahead);
            %if nnActual<nnRequired
            %    this.FirstOrderSolution{8} = [this.FirstOrderSolution{8}, nan(nxi, nnRequired-nnActual, nv)];
            %elseif nnActual>nnRequired
            %    this.FirstOrderSolution{8} = this.FirstOrderSolution{8}(:, :, 1:nnRequired);
            %end

            for i = this.SOLUTION_TRANSITION
                % If FirstOrderSolution{i} is empty, then FirstOrderSolution{i}(:, :, 1) = NaN
                % creates a non-empty array. Prevent this by assigning
                % FirstOrderSolution{i}(1:end, 1:end, 1) = NaN.
                this.FirstOrderSolution{i}(1:end, 1:end, variantsRequested) = NaN;
            end

            for i = 1 : numel(this.FirstOrderExpansion)
                this.FirstOrderExpansion{i}(1:end, 1:end, variantsRequested) = NaN;
            end

            this.EigenValues(1:end, 1:end, variantsRequested) = NaN;
            this.EigenStability(1:end, 1:end, variantsRequested) = TYPE(0);
            this.IxInit(1:end, 1:end, variantsRequested) = true;
        end%


        function this = resetMeasurement(this, variantsRequested)
            % If FirstOrderSolution{i} is empty, then FirstOrderSolution{i}(:, :, 1) = NaN
            % creates a non-empty array. Prevent this by assigning
            % FirstOrderSolution{i}(1:end, 1:end, 1) = NaN.
            for i = this.SOLUTION_MEASUREMENT
                this.FirstOrderSolution{i}(1:end, 1:end, variantsRequested) = NaN;
            end
        end%


        function numOfUnitRoots = getNumOfUnitRoots(this, variantsRequested)
            TYPE = @int8;
            if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
                variantsRequested = ':';
            end
            numOfUnitRoots = sum(this.EigenStability(:, :, variantsRequested)==TYPE(1), 2);
        end%


        function stableRoots = getStableRoots(this, variantRequested)
            TYPE = @int8;
            inxOfStableRoots = this.EigenStability(:, :, variantRequested)==TYPE(0);
            stableRoots = this.EigenValues(inxOfStableRoots);
        end%


        function sx = combineStdCorr(this, variantsRequested, stdCorr, stdScale, numOfPeriods)
            thisStdCorr = this.StdCorr(:, :, variantsRequested);
            thisStdCorr = permute(thisStdCorr, [2, 1, 3]);
            if ~isempty(stdCorr) || ~isempty(stdScale)
                sizeOfStdCorr = size(stdCorr, 2);
                sizeOfStdScale = size(stdScale, 2);
                last = max([1, sizeOfStdCorr, sizeOfStdScale]);
                if sizeOfStdCorr<last
                    stdCorr = [stdCorr, nan(size(stdCorr, 1), last-sizeOfStdCorr)];
                end
                if sizeOfStdScale<last
                    stdScale = [stdScale, nan(size(stdScale, 1), last-sizeOfStdScale)];
                end
                sx = repmat(thisStdCorr, 1, last);
                inxOfStdScale = ~isnan(stdScale);
                if any(inxOfStdScale(:))
                    ne = size(stdScale, 1);
                    temp = sx(1:ne, :, :);
                    temp(inxOfStdScale) = temp(inxOfStdScale) .* stdScale(inxOfStdScale);
                    sx(1:ne, :, :) = temp;
                end
                inxOfStdCorr = ~isnan(stdCorr);
                if any(inxOfStdCorr(:))
                    sx(inxOfStdCorr) = stdCorr(inxOfStdCorr);
                end
                % Add model StdCorr if the last user-supplied data point is before
                % the end of the sample.
                if size(sx, 2)<numOfPeriods
                    sx = [sx, thisStdCorr];
                end
            else
                sx = thisStdCorr;
            end
        end%


        function n = length(this)
            n = size(this.Values, 3);
        end%


        function n = numel(this)
            n = size(this.Values, 3);
        end%


        function this = subscripted(this, varargin)
            if numel(varargin)==1
                % Subscripted reference this(lhsRef).
                lhsRef = varargin{1};
                for i = 1 : length(this.LIST_OF_ARRAY_PROPERTIES)
                    property = this.LIST_OF_ARRAY_PROPERTIES{i};
                    this.(property) = this.(property)(:, :, lhsRef);
                end
                for i = 1 : length(this.LIST_OF_CELL_PROPERTIES)
                    property = this.LIST_OF_CELL_PROPERTIES{i};
                    n = numel(this.(property));
                    for j = 1 : n
                        this.(property){j} = this.(property){j}(:, :, lhsRef);
                    end
                end
            elseif numel(varargin)==2 && isempty(varargin{2})
                % Subscripted assignment with empty RHS this(lhsRef) = [ ]
                lhsRef = varargin{1};
                for i = 1 : length(this.LIST_OF_ARRAY_PROPERTIES)
                    property = this.LIST_OF_ARRAY_PROPERTIES{i};
                    this.(property)(:, :, lhsRef) = [ ];
                end
                for i = 1 : length(this.LIST_OF_CELL_PROPERTIES)
                    property = this.LIST_OF_CELL_PROPERTIES{i};
                    n = numel(this.(property));
                    for j = 1 : n
                        this.(property){j}(:, :, lhsRef) = [ ];
                    end
                end
            elseif numel(varargin)==3 ...
                && isa(this, 'model.component.Variant') && isa(varargin{2}, 'model.component.Variant')
                % Proper assignment this(lhsRef) = obj(rhsRef)
                % rhsRef is either ':' or [1, 1, ..., 1] to match lhsRef.
                lhsRef = varargin{1};
                rhsObj = varargin{2};
                rhsRef = varargin{3};
                for i = 1 : length(this.LIST_OF_ARRAY_PROPERTIES)
                    property = this.LIST_OF_ARRAY_PROPERTIES{i};
                    this.(property)(:, :, lhsRef) = rhsObj.(property)(:, :, rhsRef);
                end
                for i = 1 : length(this.LIST_OF_CELL_PROPERTIES)
                    property = this.LIST_OF_CELL_PROPERTIES{i};
                    n = numel(this.(property));
                    for j = 1 : n
                        this.(property){j}(:, :, lhsRef) = rhsObj.(property){j}(:, :, rhsRef);
                    end
                end
            else
                throw( ...
                    exception.Base('General:InvalidReference', 'error'), ...
                    'model' ...
                ); %#ok<GTARG>
            end
        end%


        function this = set.StdCorr(this, newStdCorr)
            temp = newStdCorr(:, ~this.IndexOfStdCorrAllowed, :);
            assert( ...
                all(temp(:)==0), ...
                'model:Variant:set:StdCorr', ...
                'Cross-correlation between measurement and transition shocks cannot be set to nonzero values.' ...
            );
            this.StdCorr = newStdCorr;
        end%


        function varargout = getIthFirstOrderSolution(this, v)
            if nargout==1
                numOutput = numel(this.FirstOrderSolution);
            else
                numOutput = nargout;
            end
            x = cell(1, numOutput);
            if size(this.Values, 3)==1 && (v==1 || v==':')
                x(1:numOutput) = this.FirstOrderSolution(1:numOutput);
            else
                for i = 1 : numOutput
                    x{i} = this.FirstOrderSolution{i}(:, :, v);
                end
            end
            varargout = cell(1, nargout);
            if nargout==1
                varargout{1} = x;
            else
                varargout(1:nargout) = x(1:nargout);
            end
        end%


        function indexInitial = getIthIndexInitial(this, v)
            indexInitial = this.IxInit(:, :, v);
        end%


        function varargout = getIthFirstOrderExpansion(this, v)
            if size(this.Values, 3)==1 && (v==1 || v==':')
                x = this.FirstOrderExpansion;
            else
                x = cell(size(this.FirstOrderExpansion));
                for i = 1 : numel(this.FirstOrderExpansion)
                    x{i} = this.FirstOrderExpansion{i}(:, :, v);
                end
            end
            varargout = cell(1, nargout);
            if nargout==1
                varargout{1} = x;
            else
                varargout(1:nargout) = x(1:nargout);
            end
        end%
    end
end


%
% Local Functions
%


function flag = checkSize(obj, size2)
    size1 = size(obj);
    ndims1 = length(size1);
    ndims2 = length(size2);
    if ndims1<ndims2
        size1(end+1:ndims2) = 1;
    elseif ndims1>ndims2
        size2(end+1:ndims1) = 1;
    end
    flag = all(size1==size2);
end%
