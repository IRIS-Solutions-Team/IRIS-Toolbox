
classdef Tolerance

    properties
        Solve = iris.mixin.Tolerance.DEFAULT_SOLVE
        Steady = iris.mixin.Tolerance.DEFAULT_STEADY
        Eigen = iris.mixin.Tolerance.DEFAULT_EIGEN
        Sevn2Patch = iris.mixin.Tolerance.DEFAULT_SEVN2PATCH
        Mse = iris.mixin.Tolerance.DEFAULT_MSE
        DiffStep = iris.mixin.Tolerance.DEFAULT_DIFF_STEP
    end


    properties (Constant, Hidden)
        DEFAULT_SOLVE = eps()^(5/9)
        DEFAULT_STEADY = 1e-12
        DEFAULT_EIGEN = eps()^(5/9)
        DEFAULT_SEVN2PATCH = eps()^(5/9)
        DEFAULT_MSE = eps()^(7/9)
        DEFAULT_DIFF_STEP = eps^(1/3)
    end


    methods
        function this = reset(this)
            this = iris.mixin.Tolerance();
        end%
    end


    methods (Access=protected)
        function this = setFromStruct(this, input)
            list = {'Solve', 'Steady', 'Eigen', 'Sevn2Patch', 'Mse', 'DiffStep'};
            for i = 1 : numel(list)
                if isfield(input, list{i})
                    this.(list{i}) = input.(list{i});
                end
            end
        end%


        function value = verifySet(this, prop, value)
            if validate.numericScalar(value, eps(), Inf)
                return
            end
            if isequal(value, @auto)
                value = this.(sprint('DEFAULT_%s', upper(prop)));
                return
            end
            thisError = [
                "Tolerance:InvalidInputValue"
                "Invalid input value when setting this Tolerance level: Tolerance.%s"
            ];
            throw(exception.Base(thisError, 'error'), prop);
        end%
    end


    methods % Set methods
    %(
        function this = set.Solve(this, value)
            this.Solve = verifySet(this, 'Solve', value);
        end%


        function this = set.Steady(this, value)
            this.Steady = verifySet(this, 'Steady', value);
        end%


        function this = set.Eigen(this, value)
            this.Eigen = verifySet(this, 'Eigen', value);
        end%


        function this = set.Sevn2Patch(this, value)
            this.Sevn2Patch = verifySet(this, 'Sevn2Patch', value);
        end%


        function this = set.Mse(this, value)
            this.Mse = verifySet(this, 'Mse', value);
        end%


        function this = set.DiffStep(this, value)
            this.DiffStep = verifySet(this, 'DiffStep', value);
        end%
    %)
    end

end

