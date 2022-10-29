% Type `help Model/index` for help on this class

classdef Model ...
    < model ...
    & matlab.mixin.CustomDisplay ...
    & iris.mixin.Plan ...
    & iris.mixin.DataProcessor


    properties (Constant)
        INTERCEPT_STRING = "[const]"
    end


    methods % Constructor
        function this = Model(varargin)
            if nargin==0
                return
            end

            if isa(varargin{1}, 'Model')
                this = varargin{1};
                return
            end

            if ischar(varargin{1}) || isstring(varargin{1}) || iscellstr(varargin{1})
                exception.warning([
                    "Deprecated"
                    "Deprecated: When creating a Model object from a source file, "
                    "use the Model.fromFile(___) constructor function instead."
                ]);
                this = Model.fromFile(varargin{:});
                return
            end

            modelSource = varargin{1};
            varargin(1) = [];

            [opt, parserOpt, optimalOpt] = this.processConstructorOptions(varargin{:});
            [this, opt] = file2model(this, modelSource, opt, opt.Preparser, parserOpt, optimalOpt);
            this = build(this, opt);
        end%
    end % methods


    methods % Duplicate @model public interface
        %(
        varargout = acf(varargin)
        varargout = activateLink(varargin)
        varargout = addToDatabank(varargin)
        varargout = alter(varargin)
        varargout = assign(varargin)
        varargout = beenSolved(varargin)
        varargout = blazer(varargin)
        varargout = bn(varargin)
        varargout = checkSteady(varargin)
        varargout = deactivateLink(varargin)
        varargout = diffloglik(varargin)
        varargout = diffsrf(varargin)
        varargout = eig(varargin)
        varargout = emptydb(varargin)
        varargout = estimate(varargin)
        varargout = expand(varargin)
        varargout = failed(varargin)
        varargout = fevd(varargin)
        varargout = ffrf(varargin)
        varargout = findeqtn(varargin)
        varargout = findname(varargin)
        varargout = fisher(varargin)
        varargout = fmse(varargin)
        varargout = get(varargin)
        varargout = horzcat(varargin)
        varargout = icrf(varargin)
        varargout = ifrf(varargin)
        varargout = isLinkActive(varargin)
        varargout = isempty(varargin)
        varargout = ismissing(varargin)
        varargout = isname(varargin)
        varargout = isnan(varargin)
        varargout = isstationary(varargin)
        varargout = length(varargin)
        varargout = lhsmrhs(varargin)
        varargout = rescaleStd(varargin)
        varargout = reset(varargin)
        varargout = solve(varargin)
        varargout = steady(varargin)
        varargout = system(varargin)
        %)
    end


    methods % Public interface
        %(
        varargout = access(varargin)
        varargout = analyticGradients(varargin)
        varargout = byAttributes(varargin)
        varargout = changeGrowthStatus(varargin)
        varargout = changeLinearStatus(varargin)
        varargout = changeLogStatus(varargin)
        varargout = checkInitials(varargin)
        varargout = equationStartsWith(varargin)
        varargout = findEquation(varargin)
        varargout = getBounds(varargin)
        varargout = isLinear(varargin)
        varargout = isLog(varargin)
        varargout = kalmanFilter(varargin)
        varargout = print(varargin)
        varargout = quickAssign(varargin)
        varargout = repeatedDataLik(varargin)
        varargout = replaceNames(varargin)
        varargout = resetBounds(varargin)
        varargout = setBounds(varargin)
        varargout = simulate(varargin)
        varargout = solutionMatrices(varargin)
        varargout = systemMatrices(varargin)
        varargout = table(varargin)

        function varargout = islinear(varargin)
            [varargout{1:nargout}] = isLinear(varargin{:});
        end%

        function varargout = islog(varargin)
            [varargout{1:nargout}] = isLog(varargin{:});
        end%

        function varargout = isStationary(varargin)
            [varargout{1:nargout}] = isstationary(varargin{:});
        end%
        %)
    end % methods


    methods (Access=protected) % Custom Display
        %(
        function groups = getPropertyGroups(this)
            x = struct( ... 
                'FileName', this.FileName, ...
                'Comment', string(this.Comment), ...
                'LinearStatus', this.LinearStatus, ...
                'GrowthStatus', this.GrowthStatus, ...
                'NumVariants', countVariants(this), ...
                'NumVariantsSolved', countVariantsSolved(this), ...
                'NumMeasurementEquations', countMeasurementEquations(this), ...
                'NumTransitionEquations', countTransitionEquations(this), ... 
                'SizeTransitionMatrix', sizeTransitionMatrix(this), ...
                'NumExportFiles', countExportFiles(this), ...
                'UserData', this.UserData ...
            );
            groups = matlab.mixin.util.PropertyGroup(x);
        end% 


        function displayScalarObject(this)
            groups = getPropertyGroups(this);
            disp(getHeader(this));
            disp(groups.PropertyList);
        end%


        function displayNonScalarObject(this)
            displayScalarObject(this);
        end%


        function header = getHeader(this)
            dimString = matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
            adjective = " ";
            if isempty(this)
                adjective = adjective + "Empty ";
            end
            if this.LinearStatus
                adjective = adjective + "Linear";
            else
                adjective = adjective + "Nonlinear";
            end
            header = "  " + string(dimString) + string(adjective) + " " + string(className) + string(newline( ));
        end%
        %)
    end % methods


    methods (Hidden) 
        varargout = checkInitialConditions(varargin)


        function value = countVariantsSolved(this)
            [~, inx] = isnan(this, 'Solution');
            value = nnz(~inx);
        end%


        varargout = postprocessKalmanOutput(varargin)
        varargout = getIdInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = getIthRectangularSolution(varargin)
        varargout = implementGet(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = prepareLinearSystem(varargin)
        varargout = prepareRectangular(varargin)

        function this = removeUserEquations(this)
            this.Equation = removeUserEquations(this.Equation);
        end%

        varargout = simulateFrames(varargin)
        varargout = steadyUser(varargin)
    end % methods


    methods (Access=protected, Hidden)
        varargout = varyParams(varargin)
    end


    methods (Static, Hidden) % Simulation methods
        %(
        varargout = simulateFirstOrder(varargin)
        varargout = simulateSelective(varargin)
        varargout = simulateStacked(varargin)
        varargout = simulateStatic(varargin)
        varargout = simulateNone(varargin)
        varargout = splitIntoFrames(varargin)
        %)
    end


    methods (Static) % Static constructors
        %(
        varargout = fromFile(varargin)
        varargout = fromSnippet(varargin)
        varargout = fromSource(varargin)
        varargout = fromString(varargin)
        %)
    end


    methods
        function value = countMeasurementEquations(this)
            value = nnz(this.Equation.Type==1);
        end%


        function value = countTransitionEquations(this)
            value = nnz(this.Equation.Type==2);
        end%


        function value = sizeTransitionMatrix(this)
            [~, nxi, nb] = sizeSolution(this);
            value = [nxi, nb];
        end%


        function value = countExportFiles(this)
            value = numel(this.Export);
        end%
    end % methods


    methods (Hidden) % Interface for iris.mixin.Plan
        %(
        function names = getEndogenousForPlan(this)
            names = getNamesByType(this.Quantity, 1, 2);
        end%


        function names = getExogenousForPlan(this)
            names = getNamesByType(this.Quantity, 31, 32);
        end%


        function value = getAutoswapsForPlan(this)
            pairingVector = this.Pairing.Autoswaps.Simulate;
            [namesExogenized, namesEndogenized] = ...
                model.Pairing.getAutoswaps(pairingVector, this.Quantity);
            value = [ namesExogenized(:), namesEndogenized(:) ];
        end%


        function sigmas = getSigmasForPlan(this)
            ne = nnz(getIndexByType(this.Quantity, 31, 32));
            sigmas = this.Variant.StdCorr(:, 1:ne, :);
            sigmas = reshape(sigmas, ne, 1, [ ]);
        end%
        %)
    end % methods
end % classdef

