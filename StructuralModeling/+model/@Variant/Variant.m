classdef Variant
    properties
        Values = double.empty(1, 0, 0)
        StdCorr = double.empty(1, 0, 0)

        FirstOrderSolution = repmat({double.empty(0, 0, 0)}, 1, 10)
        FirstOrderExpansion = repmat({double.empty(0, 0, 0)}, 1, 5)

        IxInit = logical.empty(1, 0, 0)
        EigenValues = double.empty(1, 0, 0)
        EigenStability = int8.empty(1, 0, 0)

        PreallocateFunc
    end


    properties
        IndexOfStdCorrAllowed = logical.empty(1, 0, 0)
    end
    
    
    properties (Constant)
        SOLUTION_TRANSITION = [1, 2, 3, 4, 7, 8, 10]
        SOLUTION_MEASUREMENT = [4, 5, 6, 9] 
        LIST_OF_ARRAY_PROPERTIES = {'Values', 'StdCorr', 'IxInit', 'EigenValues', 'EigenStability'}
        LIST_OF_CELL_PROPERTIES = {'FirstOrderSolution', 'FirstOrderExpansion'}
    end


    methods
        function this = Variant( ...
                numVariants, quantity, vector, ahead, ...
                numHashed, numObserved, defaultStd, defaultFloor, preallocateFunc ...
            )

            if nargin==0
                return
            end
            if nargin>=9
                this.PreallocateFunc = preallocateFunc;
            end
            this = createIndexOfStdCorrAllowed(this, quantity);
            this = preallocateValues(this, numVariants, quantity);
            this = preallocateStdCorr(this, quantity, defaultStd);
            % this = preallocateFloors(this, quantity, defaultFloor);
            this = preallocateSolution(this, vector, ahead, numHashed, numObserved);
        end%


        function this = createIndexOfStdCorrAllowed(this, quantity)
            ixe = quantity.Type==31 | quantity.Type==32;
            ne = nnz(ixe);
            typeOfShocks = quantity.Type(ixe);
            ix31 = typeOfShocks==31;
            inxCorrAllowed = true(ne);
            inxCorrAllowed(ix31, ~ix31) = false;
            inxCorrAllowed(~ix31, ix31) = false;
            inxTril = tril(ones(ne), -1)==1;
            this.IndexOfStdCorrAllowed = [true(1, ne), inxCorrAllowed(inxTril).'];
        end%


        function this = preallocateValues(this, numVariants, quantity)
            numQuantities = numel(quantity);
            if checkSize(this.Values, [1, numQuantities, numVariants])
                this.Values(:) = NaN;
            else
                this.Values = nan(1, numQuantities, numVariants);
            end
            ixe = quantity.Type==31 | quantity.Type==32;
            % Steady state of shocks cannot be changed from 0+0i.
            this.Values(1, ixe, :) = 0;
            % Steady state of exogenous variables preset to default.
            ixg = quantity.Type==5;
            this.Values(1, ixg, :) = model.DEFAULT_STEADY_EXOGENOUS;
            % Steady state of ttrend cannot be changed from 0+1i.
            inxTimeTrend = strcmp(quantity.Name, model.Quantity.RESERVED_NAME_TTREND);
            this.Values(1, inxTimeTrend, :) = model.STEADY_TTREND;
        end%


        function this = preallocateStdCorr(this, quantity, defaultStd)
            nv = size(this.Values, 3);
            ne = nnz(quantity.Type==31 | quantity.Type==32);
            numStdCorr = ne + ne*(ne-1)/2;
            if checkSize(this.StdCorr, [1, numStdCorr, nv])
                this.StdCorr(:) = 0;
            else
                this.StdCorr = zeros(1, numStdCorr, nv);
            end
            if nargin<3
                return
            end
            if isnumeric(defaultStd) && numel(defaultStd)==1 && defaultStd>=0
                this.StdCorr(1, 1:ne, :) = defaultStd;
            end
        end%


        % function this = preallocateFloors(this, quantity, defaultFloor)
            % inxFloors = ...
                % startsWith(quantity.Name, quantity.FLOOR_PREFIX) & quantity.Type==4;
            % this.Values(1, inxFloors, :) = defaultFloor;
        % end%


        function this = preallocateSolution(this, vector, ahead, numHashed, numObserved)
            nv = size(this.Values, 3);
            [ny, nxi, nb, nf, ne] = sizeSolution(vector);
            [~, kxi, ~, kf] = sizeSystem(vector);
            nh = numHashed;
            nz = numObserved;
            func = this.PreallocateFunc;

            this.FirstOrderSolution{1} = func(nxi, nb, nv);             % T
            this.FirstOrderSolution{2} = func(nxi, ne*(1+ahead), nv);   % R
            this.FirstOrderSolution{3} = func(nxi, 1, nv);              % K
            this.FirstOrderSolution{4} = func(ny, nb, nv);              % Z
            this.FirstOrderSolution{5} = func(ny, ne, nv);              % H
            this.FirstOrderSolution{6} = func(ny, 1, nv);               % D
            this.FirstOrderSolution{7} = func(nb, nb, nv);              % U
            this.FirstOrderSolution{8} = func(nxi, nh*(1+ahead), nv);   % Y - add-factors in hashed equations
            this.FirstOrderSolution{9} = func(max(ny, nz), nb, nv);     % Zb - non-transformed measurement.
            this.FirstOrderSolution{10} = func(nxi, nb, nv);            % T0 - non-transformed (rectangular) transition matrix
            
            this.FirstOrderExpansion{1} = func(nb, kf, nv); % Xa
            this.FirstOrderExpansion{2} = func(nf, kf, nv); % Xf
            this.FirstOrderExpansion{3} = func(kf, ne, nv); % Ru
            this.FirstOrderExpansion{4} = func(kf, kf, nv); % J
            this.FirstOrderExpansion{5} = func(kf, nh, nv); % Yu -- nonlin addfactors.
            
            this.EigenValues = func(1, kxi, nv);
            this.EigenStability = zeros(1, kxi, nv, 'int8');
            this.IxInit = true(1, nb, nv);
        end%
        
        
        function this = resetTransition(this, variantsRequested, vector, numHashed, numObserved)
            nv = size(this.Values, 3);
            [~, ~, ~, ~, ne] = sizeSolution(vector);

            % Preallocate all solution and expansion matrices first if they
            % are missing.
            if isempty(this.FirstOrderSolution{1})
                this = preallocateSolution(this, vector, 0, numHashed, numObserved);
            end

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
            this.EigenStability(1:end, 1:end, variantsRequested) = 0;
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


        function numUnitRoots = getNumOfUnitRoots(this, variantsRequested)
            if nargin<2 || isequal(variantsRequested, Inf) || isequal(variantsRequested, @all)
                variantsRequested = ':';
            end
            numUnitRoots = sum(this.EigenStability(:, :, variantsRequested)==1, 2);
        end%


        function stableRoots = getStableRoots(this, variantRequested)
            inxStableRoots = this.EigenStability(:, :, variantRequested)==0;
            stableRoots = this.EigenValues(inxStableRoots);
        end%




        function n = length(this)
            n = size(this.Values, 3);
        end%




        function n = numel(this)
            n = size(this.Values, 3);
        end%




        function this = subscripted(this, varargin)
            if numel(varargin)==1
                % Subscripted reference this(lhsRef)
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
                && isa(this, 'model.Variant') && isa(varargin{2}, 'model.Variant')
                % this(lhsRef) = obj(rhsRef)
                % rhsRef is either ':' or [1, 1, ..., 1] to match lhsRef
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
                throw( exception.Base('General:InvalidReference', 'error'), 'model' ); %#ok<GTARG>
            end
        end%




        function this = set.StdCorr(this, newStdCorr)
            temp = newStdCorr(:, ~this.IndexOfStdCorrAllowed, :);
            if ~all(temp(:)==0)
                thisError = { 'model:Variant:set:StdCorr'
                              'Cross-correlation between measurement and transition shocks cannot be set to nonzero' };
                throw( exception.Base(thisError, 'error') );
            end
            this.StdCorr = newStdCorr;
        end%




        function varargout = getIthFirstOrderSolution(this, variantsRequested)
            if nargout==1
                numOutput = numel(this.FirstOrderSolution);
            else
                numOutput = nargout;
            end

            if nargin<3
                pos = 1 : numOutput;
            end

            x = cell(1, numOutput);
            if size(this.Values, 3)==1 && (isequal(variantsRequested, 1) || strcmp(variantsRequested, ':'))
                x(1:numOutput) = this.FirstOrderSolution(1:numOutput);
            else
                for i = 1 : numOutput
                    x{i} = this.FirstOrderSolution{i}(:, :, variantsRequested);
                end
            end

            varargout = cell(1, nargout);
            if nargout==1
                varargout{1} = x;
            else
                varargout(1:nargout) = x(1:nargout);
            end
        end%


        function stdcorr = getIthStdcorr(this, variantsRequested)
            stdcorr = this.StdCorr(1, :, variantsRequested);
        end%


        function inxInit = getIthIndexInitial(this, variantsRequested)
            inxInit = this.IxInit(:, :, variantsRequested);
        end%


        function varargout = getIthFirstOrderExpansion(this, variantsRequested)
            if size(this.Values, 3)==1 && (isequal(variantsRequested, 1) || strcmp(variantsRequested, ':'))
                x = this.FirstOrderExpansion;
            else
                x = cell(size(this.FirstOrderExpansion));
                for i = 1 : numel(this.FirstOrderExpansion)
                    x{i} = this.FirstOrderExpansion{i}(:, :, variantsRequested);
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


    methods
        varargout = getIthRectangularSolution(varargin)
    end


    properties (Dependent)
        InxInit
        InxOfInit
    end




    methods 
        function value = get.InxInit(this)
            value = this.IxInit;
        end%


        function value = get.InxOfInit(this)
            value = this.IxInit;
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
