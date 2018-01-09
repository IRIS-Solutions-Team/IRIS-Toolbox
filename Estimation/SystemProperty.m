classdef SystemProperty < handle
    properties
        % Function  Function to call to evaluate SystemProperty
        Function = [ ]

        % MaxNumOutputs  Maximum number of output arguments from SystemProperty.Function
        MaxNumOutputs = 0

        % NumOutputs  Actual number of output arguments from SystemProperty.Function requested by user
        NumOutputs = 0 

        % OutputNames  Names assigned to output arguments from SystemProperty.Function
        OutputNames = cell.empty(1, 0)

        NamedReferences = cell(1, 0)
        IncludeModel = false
        Outputs = cell.empty(1, 0)

        SizeSolution = nan(1, 7);
        FirstOrderTriangular = cell(1, 9)
        FirstOrderExpansion = cell(1, 5)
        CovShocks = double.empty(0)
        Values = double.empty(1, 0)
        StdCorr = double.empty(1, 0)
        EigenValues = double.empty(1, 0)
        EigenStability = int8.empty(1, 0)

        Specifics = struct( )
    end


    properties (Dependent)
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
            [ny, nxi, nb, nf, ne, ng, nz] = sizeOfSolution(model);
            this.SizeSolution = [ny, nxi, nb, nf, ne, ng, nz];
        end


        function update(this, model, variantRequested)
            nv = length(model);
            if nargin<3 && nv==1
                variantRequested = 1;
            end
            this.FirstOrderTriangular = getIthFirstOrderSolution(model, variantRequested);
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
        end


        function eval(this)
            this.Outputs = cell(1, this.NumOutputs);
            this.Function(this);
        end
    end


    methods
        function ny = get.NumObserved(this)
            ny = this.SizeSolution(1);
        end


        function nxi = get.NumStates(this)
            nxi = this.SizeSolution(2);
        end


        function nb = get.NumBackward(this)
            nb = this.SizeSolution(3);
        end


        function nf = get.NumForward(this)
            nf = this.SizeSolution(4);
        end


        function ne = get.NumShocks(this)
            ne = this.SizeSolution(5);
        end


        function ng = get.NumExogenous(this)
            ng = this.SizeSolution(6);
        end

        function nz = get.NumObservedStates(this)
            nz = this.SizeSolution(7);
        end


        function numUnitRoots = get.NumUnitRoots(this)
            TYPE = @int8;
            numUnitRoots = nnz(this.EigenStability==TYPE(1));
        end
    end
end

