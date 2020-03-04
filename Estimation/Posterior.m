classdef Posterior < handle
    properties
        ParameterNames = cell.empty(1, 0)
        ObjectiveFunction
        Initial = double.empty(1, 0)
        LowerBounds = double.empty(1, 0)
        UpperBounds = double.empty(1, 0)
        PriorDistributions = cell.empty(1, 0)
        IndexPriors = logical.empty(1, 0)
        SystemPriors = SystemPriorWrapper.empty(1, 0)

        HonorBounds = false
        EvaluateData = false
        EvaluateParamPriors = false
        EvaluateSystemPriors = false
    end




    properties (SetAccess=protected)
        Optimum = double.empty(1, 0)
        Hessian = repmat({double.empty(0)}, 1, 3)
        ObjectiveAtOptimum = NaN
        IndexLowerBoundsHit = logical.empty(1, 0)
        IndexUpperBoundsHit = logical.empty(1, 0)
        ExitFlag = NaN
        IndexValidDiff = logical.empty(1, 0)
        LineInfo = double.empty(1, 0)
        LineInfoFromData = double.empty(1, 0)
        LineInfoFromOwnPrior = double.empty(1, 0)
        LineInfoFromSystemPriors = double.empty(1, 0)
    end




    properties (Dependent)
        NumParameters
        IsConstrained
        PropOfLineInfoFromData
        ProposalCov
    end




    properties (Constant)
        IS_OPTIM_TBX = ~isempty(ver('optim'))
    end

    


    methods
        function this = Posterior(varargin)
        %(
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'Posterior')
                this = varargin{1};
                return
            end
            numParameters = varargin{1};
            initialize(this, numParameters);
        %)
        end%




        function initialize(this, numParameters)
        %(
            this.Initial = nan(1, numParameters);
            this.ParameterNames = sprintfc('X%g', 1:numParameters);
            this.PriorDistributions = cell(1, numParameters);
            this.IndexPriors = false(1, numParameters);
            this.LowerBounds = -inf(1, numParameters);
            this.UpperBounds = inf(1, numParameters);
            this.Optimum = nan(1, numParameters);
            this.Hessian = repmat({nan(numParameters)}, 1, 3);
            this.IndexLowerBoundsHit = false(1, numParameters);
            this.IndexUpperBoundsHit = false(1, numParameters);
            this.IndexValidDiff = true(1, numParameters);
            this.LineInfo = zeros(1, numParameters);
            this.LineInfoFromData = zeros(1, numParameters);
            this.LineInfoFromOwnPrior = zeros(1, numParameters);
            this.LineInfoFromSystemPriors = zeros(1, numParameters);
        %)
        end%
            



        function maximizePosteriorMode(this, estimationWrapper)
        %(
            if this.NumParameters==0
                thisWarning = [
                    "Model:NoParameterToEstimate"
                    "No parameter is specified to be estimated."
                ];
                throw(exception.Base(thisWarning, 'warning'));
                return
            end
            checkBoundsConsistency(this);
            checkInitial(this);

            run(estimationWrapper, this.ObjectiveFunction, this.Initial, this.LowerBounds, this.UpperBounds);
            this.Optimum(:) = estimationWrapper.Optimum(:);
            this.ObjectiveAtOptimum = estimationWrapper.ObjectiveAtOptimum;
            this.Hessian{1}(:, :) = estimationWrapper.Hessian(:, :);
            this.IndexLowerBoundsHit(:) = estimationWrapper.IndexLowerBoundsHit(:);
            this.IndexUpperBoundsHit(:) = estimationWrapper.IndexUpperBoundsHit(:);

            repairToHonorBounds(this);
            diffObjectiveAtOptimum(this);
        %)
        end%
            



        function [mldParamPriors, p] = evalParamPriors(this, x)
        %(
            p = zeros(1, numel(x));
            for i = find(this.IndexPriors)
                ithPriorDistribution = this.PriorDistributions{i};
                if isa(ithPriorDistribution, 'distribution.Distribution')
                    p(i) = ithPriorDistribution.logPdf(x(i));
                elseif isa(ithPriorDistribution, 'function_handle')
                    p(i) = ithPriorDistribution(x(i));
                else
                    p(i) = NaN;
                end
                if (~isfinite(p(i)) || imag(p(i))~=0) && nargout<2
                    mldParamPriors = Inf;
                    return
                end
            end
            mldParamPriors = -sum(p); % Minus log density
        %)
        end%




        function x = drawParameters(this, numOfDraws)
        %(
            numOfParameters = this.NumParameters;
            x = nan(numOfDraws, numOfParameters);
            for i = 1 : numOfParameters
                x(:, i) = this.PriorDistributions{i}(numOfDraws, 1);
                indexWithin = x(:, i)>=this.LowerBounds(i) & x(:, i)<=this.UpperBounds(i);
                while ~all(indexWithin)
                    pos = find(~indexWithin, 1);
                    x(pos, i) = this.PriorDistributions{i}( );
                    indexWithin(pos) = x(pos, i)>=this.LowerBounds(i) & x(pos, i)<=this.UpperBounds(i);
                end
            end
        %)
        end%
    end




    methods (Access=protected)
        function checkBoundsConsistency(this)
        %(
            numParameters = this.NumParameters;
            inxConsistent = this.LowerBounds<this.UpperBounds;
            if ~all(inxConsistent)
                thisError = [
                    "Model:InconsistentBounds"
                    "The upper bound for this parameter is not above its lower bound: %s"
                ];
                throw( ...
                    exception.Base(thisError, 'error'), ...
                    this.ParameterNames(~inxConsistent) ...
                );
            end
        %)
        end%



        
        function checkInitial(this)
        %(
            [~, ~, namesBelow, namesAbove] = checkBounds(this, this.Initial);
            assert( ...
                isempty(namesBelow), ...
                exception.Base('Posterior:InitialBelowLowerBound', 'error'), ...
                namesBelow{:} ...
            );
            assert( ...
                isempty(namesAbove), ...
                exception.Base('Posterior:InitialAboveUpperBound', 'error'), ...
                namesAbove{:} ...
            );
            [~, ldParamPriors] = evalParamPriors(this, this.Initial);
            indexValidPriors = isfinite(ldParamPriors) & imag(ldParamPriors)==0;
            assert( ...
                all(indexValidPriors), ...
                exception.Base('Posterior:InvalidPriorAtInitial', 'error'), ...
                this.ParameterNames{~indexValidPriors} ...
            );
        %)
        end%




        function [inxBelow, inxAbove, namesBelow, namesAbove] = checkBounds(this, x)
        %(
            if this.HonorBounds
                inxBelow = x(:)<this.LowerBounds(:);
                inxAbove = x(:)>this.UpperBounds(:);
            else
                inxBelow = false(size(x));
                inxAbove = false(size(x));
            end
            if nargout>2
                namesBelow = this.ParameterNames(inxBelow);
                namesAbove = this.ParameterNames(inxAbove);
            end
            inxBelow = reshape(inxBelow, size(x));
            inxAbove = reshape(inxAbove, size(x));
        %)
        end%




        function repairToHonorBounds(this)
        %(
            if ~this.HonorBounds
                return
            end
            [inxBelow, inxAbove, namesBelow, namesAbove] = checkBounds(this, this.Optimum);
            if any(inxBelow)
                this.Optimum(inxBelow) = this.LowerBounds(inxBelow);
                throw( ...
                    exception.Base('Posterior:repairToHonorBounds', 'warning'), ...
                    'lower', namesBelow{:} ...
                );
            end
            if any(inxAbove)
                this.Optimum(inxAbove) = this.UpperBounds(inxAbove);
                throw( ...
                    exception.Base('Posterior:repairToHonorBounds', 'warning'), ...
                    'upper', namesAbove{:} ...
                );
            end
        %)
        end%




        function diffObjectiveAtOptimum(this)
        %(
            numParameters = this.NumParameters;
            indexDiagonal = logical(eye(numParameters)); % Index of diagonal elements
            h = eps( )^(1/4) * max(abs(this.Optimum), 1); % Differentiation step
            for i = 1 : numParameters
                x0 = this.Optimum;
                if this.IndexLowerBoundsHit(i)
                    % Lower bound hit; move the central point up.
                    x0(i) = x0(i) + 1.5*h(i);
                elseif this.IndexUpperBoundsHit(i)
                    % Upper bound hit; move the central point down.
                    x0(i) = x0(i) - 1.5*h(i);
                end
                xp = x0;
                xm = x0;
                xp(i) = x0(i) + h(i);
                xm(i) = x0(i) - h(i);
                [obj0, l0, p0, s0] = this.ObjectiveFunction(x0);
                [objp, lp, pp, sp] = this.ObjectiveFunction(xm);
                [objm, lm, pm, sm] = this.ObjectiveFunction(xp);
                h2 = h(i)^2;
                
                % Diff total objective function.
                ithDiffObj = (objp - 2*obj0 + objm) / h2;
                if ithDiffObj<=0 || ~isfinite(ithDiffObj)
                    sgm = 4*max(abs(x0(i)), 1);
                    ithDiffObj = 1/sgm^2;
                    this.IndexValidDiff(i) = false;
                end
                this.LineInfo(i) = ithDiffObj;
                
                % Diff data likelihood
                if this.EvaluateData
                    this.LineInfoFromData(i) = (lp - 2*l0 + lm) / h2;
                end

                % Diff parameter priors
                if this.EvaluateParamPriors
                    this.LineInfoFromOwnPrior(i) = (pp - 2*p0 + pm) / h2;
                end
                
                % Diff system priors
                if this.EvaluateSystemPriors
                    this.LineInfoFromSystemPriors(i) = (sp - 2*s0 + sm) / h2;
                end
            end

            if all(isnan(this.Hessian{1}(:)))
                this.Hessian{1}(indexDiagonal) = this.LineInfo;
            end

            if this.EvaluateParamPriors
                this.Hessian{2} = diag(this.LineInfoFromOwnPrior);
            else
                this.Hessian{2} = zeros(numParameters);
            end

            if this.EvaluateSystemPriors
                this.Hessian{3} = nan(numParameters);
                this.Hessian{3}(indexDiagonal) = this.LineInfoFromSystemPriors;
            else
                this.Hessian{3} = zeros(numParameters);
            end
        %)
        end%
    end




    methods % Dependent properties, get and set methods for properties
        function flag = get.IsConstrained(this)
            flag = any(~isinf(this.LowerBounds)) || any(~isinf(this.UpperBounds));
        end%


        function n = get.NumParameters(this)
            n = length(this.Initial);
        end%


        function p = get.PropOfLineInfoFromData(this)
            p = nan(1, this.NumParameters);
            inxPositiveLineInfo = this.LineInfo>0;
            p = this.LineInfoFromData(inxPositiveLineInfo) ./ this.LineInfo(inxPositiveLineInfo);
            p(p<0 | ~isfinite(p)) = NaN;
        end%


        function c = get.ProposalCov(this)
            c = diag(1 ./ this.LineInfo);
        end%
    end
end
