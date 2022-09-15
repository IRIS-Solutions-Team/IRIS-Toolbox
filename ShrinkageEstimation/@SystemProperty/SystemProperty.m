classdef SystemProperty < handle
    properties
        % Function  Function to call to evaluate SystemProperty
        Function = [ ]

        % MaxNumOfOutputs  Maximum number of output arguments from SystemProperty.Function
        MaxNumOfOutputs = 0

        % OutputNames  Names assigned to output arguments from SystemProperty.Function
        OutputNames = cell.empty(1, 0)

        NamedReferences = cell(1, 0)
        IncludeModel = false
        Outputs = cell.empty(1, 0)

        SizeSolution = nan(1, 7);
        FirstOrderTriangular = cell(1, 9)
        IndexInitial = logical.empty(1, 0, 0)
        FirstOrderExpansion = cell(1, 5)
        CovShocks = double.empty(0)
        Values = double.empty(1, 0)
        StdCorr = double.empty(1, 0)
        EigenValues = double.empty(1, 0)
        EigenStability = int8.empty(1, 0)

        CallerData = struct( )

        Tolerance = iris.mixin.Tolerance( )
    end


    properties (Dependent)
        % NumOfOutputs  Actual number of output arguments from SystemProperty.Function requested by user
        NumOfOutputs

        NumUnitRoots
        NumObserved
        NumStates
        NumBackward
        NumForward
        NumShocks
        NumExogenous
        NumObservedStates
    end


    methods
        function this = SystemProperty(model)
            [ny, nxi, nb, nf, ne, ng, nz] = sizeSolution(model);
            this.SizeSolution = [ny, nxi, nb, nf, ne, ng, nz];
            this.Tolerance = tolerance(model);
        end%


        function update(this, model, variantRequested)
            nv = length(model);
            if nargin<3 && nv==1
                variantRequested = 1;
            end
            this.FirstOrderTriangular = getIthFirstOrderSolution(model, variantRequested);
            this.IndexInitial = getIthIndexInitial(model, variantRequested);
            this.FirstOrderExpansion = getIthFirstOrderExpansion(model, variantRequested);
            this.CovShocks = getIthOmega(model, variantRequested);
            [this.EigenValues, this.EigenStability] = eig(model, variantRequested);
            this.Values = getIthValues(model, variantRequested);
            this.StdCorr = getIthStdCorr(model, variantRequested);
            if this.IncludeModel
                vthModel = model;
                if length(model)>1 || variantRequested>1
                    vthModel.Variant = subscripted(vthModel.Variant, variantRequested);
                end
                this.Model = vthModel;
            end
        end%


        function eval(this, model, modelVariant)
            nv = length(model);
            if nargin<3 && nv==1
                modelVariant = 1;
            end
            preallocateOutputs(this);
            this.Function(model, this, modelVariant);
        end%


        function preallocateOutputs(this)
            this.Outputs = cell(1, this.NumOfOutputs);
        end%
    end


    methods
        function this = set.OutputNames(this, outputNames)
            outputNames = cellstr(outputNames);
            numOutputs = numel(outputNames);
            if numOutputs>this.MaxNumOfOutputs
                throw( exception.Base('SystemPriorWrapper:NamesExceedMaxOfNumOfOutputs', 'error') );
            end
            if ~all(cellfun(@isvarname, outputNames))
                throw( exception.Base('SystemPriorWrapper:IllegalOutputName', 'error') );
            end
            [flag, duplicateNames] = textual.nonunique(outputNames);
            if flag
                throw( exception.Base('SystemPriorWrapper:NonuniqueOutputName', 'error'), ...
                       duplicateNames{:} );
            end
            this.OutputNames = outputNames;
        end%


        function n = get.NumOfOutputs(this)
            n = numel(this.OutputNames);
        end%


        function ny = get.NumObserved(this)
            ny = this.SizeSolution(1);
        end%


        function nxi = get.NumStates(this)
            nxi = this.SizeSolution(2);
        end%


        function nb = get.NumBackward(this)
            nb = this.SizeSolution(3);
        end%


        function nf = get.NumForward(this)
            nf = this.SizeSolution(4);
        end%


        function ne = get.NumShocks(this)
            ne = this.SizeSolution(5);
        end%


        function ng = get.NumExogenous(this)
            ng = this.SizeSolution(6);
        end%

        function nz = get.NumObservedStates(this)
            nz = this.SizeSolution(7);
        end%


        function numUnitRoots = get.NumUnitRoots(this)
            numUnitRoots = nnz(this.EigenStability==1);
        end%
    end
end

