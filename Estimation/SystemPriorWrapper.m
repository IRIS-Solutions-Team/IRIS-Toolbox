% System Priors 
%
% The `SystemPriorWrapper` class is an interface for creating prior
% densities associated with the properties of a model as a whole system (as
% opposed to prior densities associated with individual parameters in
% isolation), and using them in model estimation. The properties are
% referred to as system properties, and the priors as system priors.
%
% The system properties that can be subjected to prior densities include
%
% * model simulations including shock responses
% * frequency responses
% * autocovariances and autocorrelations
% * functions involving any number of individual parameters
% * any functions or combinations of the above
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef SystemPriorWrapper < handle
    properties
        Quantity = model.component.Quantity.empty(1, 0)
        SystemPrior = system.Prior.empty(1, 0)
        SystemPropertySpecifics = cell.empty(1, 0)
        SystemPropertyNames = cell.empty(1, 0)
        LogDensityOutOfBounds = -Inf
    end


    properties (Dependent)
        FunctionHeader
    end


    methods
        function this = SystemPriorWrapper(varargin)
            if nargin==0
                return
            end
            if nargin==1 && isa(varargin{1}, 'SystemPriors')
                this = varargin{1};
                return
            end
            this = prepareSystemPriors(varargin{1}, this);
        end


        function addSystemProperty(this, name, sp)
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('SystemPriorWrapper.addSystemProperty');
                INPUT_PARSER.addRequired('SystemPriorWrapper', @(x) isa(x, 'SystemPriorWrapper'));
                INPUT_PARSER.addRequired('Name', @(x) ischar(x) || isa(x, 'string'));
                INPUT_PARSER.addRequired('SystemProperty', @(x) isa(x, 'system.Property'));
            end
            INPUT_PARSER.parse(this, name, sp);
            this.SystemPropertyNames{1, end+1} = strtrim(char(name));
            this.SystemPropertySpecifics{1, end+1} = sp.Specifics;
        end


        function addSystemPrior(this, expression, distribution, varargin)
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('SystemPriorWrapper.addSystemPrior');
                INPUT_PARSER.addRequired('SystemPriorWrapper', @(x) isa(x, 'SystemPriorWrapper'));
                INPUT_PARSER.addRequired('Expression', @(x) ischar(x) || isa(x, 'string'));
                INPUT_PARSER.addRequired('Distribution', @(x) isa(x, 'distribution.Abstract'));
                INPUT_PARSER.addParameter('LowerBound', -Inf, @(x) isnumeric(x) && isscalar(x));
                INPUT_PARSER.addParameter('UpperBound', Inf, @(x) isnumeric(x) && isscalar(x));
            end
            INPUT_PARSER.parse(this, expression, distribution, varargin{:});
            opt = INPUT_PARSER.Options;
            this.SystemPrior(1, end+1) = system.Prior( ...
                expression, distribution, opt.LowerBound, opt.UpperBound ...
            );
        end


        function seal(this)
            seal(this.SystemPrior, this);
        end


        function [minusLogDensity, minusLogDensityContributions, priorEval] = eval(this, model)
            TYPE = @int8;
            systemProperty = system.Property( );
            nv = length(model);
            numProperties = numel(this.SystemPropertyNames);
            numPriors = numel(this.SystemPrior);
            minusLogDensity = nan(1, 1, nv);
            minusLogDensityContributions = nan(1, numPriors, nv);
            logDensityContributions = nan(1, numPriors, nv);
            priorEval = nan(1, numProperties, nv);
            for v = 1 : nv
                systemProperty.FirstOrderSolution = getIthFirstOrderSolution(model, v);
                systemProperty.CovShocks = getIthOmega(model, v);
                [systemProperty.EigenValues, systemProperty.EigenStability] = eig(model, v);
                systemProperty.NumUnitRoots = nnz(systemProperty.EigenStability==TYPE(1));
                values = getIthValues(model, v);
                stdCorr = getIthStdCorr(model, v);
                propertyEval = cell(1, numProperties);
                for i = 1 : numProperties
                    systemProperty.Specifics = this.SystemPropertySpecifics{i};
                    propertyEval{1, i} = systemProperty.Specifics.Function(systemProperty);
                end
                for i = 1 : numPriors
                    p = this.SystemPrior(i); 
                    x = p.Function(values, stdCorr, propertyEval{:});
                    if x>=p.LowerBound && x<=p.UpperBound
                        c = p.Distribution.logPdf(x);
                    else
                        c = this.LogDensityOutOfBounds;
                    end
                    priorEval(1, i, v) = x;
                    logDensityContributions(1, i, v) = c;
                end
            end
            minusLogDensityContributions = -logDensityContributions;
            minusLogDensity = sum(minusLogDensityContributions, 2);
        end


        function h = get.FunctionHeader(this)
            h = 'Value, StdCorr';
            for i = 1 : numel(this.SystemPropertyNames)
                h = [h, ', ', this.SystemPropertyNames{i}];
            end
            h = ['@(', h, ')'];
        end
    end
end
