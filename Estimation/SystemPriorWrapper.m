% System Prior Wrapper 
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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef SystemPriorWrapper < handle
    properties
        Quantity = model.component.Quantity.empty(1, 0)
        SystemPriors = SystemPrior.empty(1, 0)
        SystemProperties = SystemProperty.empty(1, 0)
        LogDensityOutOfBounds = -Inf
    end




    properties (SetAccess=protected)
        BeenSealed = false
    end




    properties (Dependent)
        FunctionHeader
        OutputNames
    end




    methods
        function add(this, element)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('SystemPriorWrapper.add');
                pp.addRequired('SystemPriorWrapper', @(x) isa(x, 'SystemPriorWrapper') && ~isempty(x.Quantity));
                pp.addRequired('NewElement', @(x) isa(x, 'SystemPrior') || isa(x, 'SystemProperty'));
            end
            pp.parse(this, element);
            if isa(element, 'SystemProperty')
                addSystemProperty(this, element);
            elseif isa(element, 'SystemPrior')
                addSystemPrior(this, element);
            end
        end%


        function addSystemProperty(this, systemProperty)
            persistent pp
            if isempty(pp)
                pp = extend.InputParser('SystemPriorWrapper.addSystemProperty');
                addRequired(pp, 'SystemPriorWrapper', @(x) isa(x, 'SystemPriorWrapper') && ~isempty(x.Quantity));
                addRequired(pp, 'SystemProperty', @(x) isa(x, 'SystemProperty'));
            end
            pp.parse(this, systemProperty);
            if this.BeenSealed
                exception.Base('SystemPriorWrapper:SystemPropertyToSealed', 'error');
            end
            checkUniqueNames(this, systemProperty.OutputNames);
            this.SystemProperties(1, end+1) = systemProperty;
        end%


        function addSystemPrior(this, varargin)
            if isempty(varargin)
                return
            end
            if this.BeenSealed
                throw( exception.Base('SystemPriorWrapper:SystemPriorToSealed', 'error') );
            end
            if all(cellfun(@(x) isa(x, 'SystemPrior'), varargin))
                add = [varargin{:}];
            else
                add = SystemPrior(varargin{:});
            end
            numAdd = numel(add);
            this.SystemPriors(1, end+(1:numAdd)) = add;
        end%


        function seal(this)
            if this.BeenSealed
                return
            end
            seal(this.SystemPriors, this);
            this.BeenSealed = true;
        end%


        function checkUniqueNames(this, names)
            listOfAllNames = [this.Quantity.Name, this.OutputNames];
            indexOfUniqueNames = ~ismember(names, listOfAllNames);
            if ~all(indexOfUniqueNames)
                throw( exception.Base('SystemPriorWrapper:NonuniqueOutputName', 'error'), ...
                       names{~indexOfUniqueNames} );
            end
        end%


        function flag = existsOutputName(this, name)
            flag = any(strcmp(name, this.OutputNames));
        end%


        function namedReferences = getNamedReferencesForOutputName(this, name)
            namedReferences = cell.empty(1, 0);
            for i = 1 : numel(this.SystemProperties)
                if any(strcmp(this.SystemProperties(i).OutputNames, name))
                    namedReferences = this.SystemProperties(i).NamedReferences;
                    break
                end
            end
        end%


        function replace = replaceSystemPropertyReferences(systemPriorWrapper, outputName, reference)
            namedReferences = getNamedReferencesForOutputName(systemPriorWrapper, outputName);
            arguments = textual.splitArguments(reference);
            arguments = strtrim(arguments);
            for i = 1 : min(numel(arguments), numel(namedReferences))
                index__ = strcmp(arguments{i}, namedReferences{i});
                if any(index__)
                    arguments{i} = sprintf('%g', find(index__));
                end
            end
            replace = sprintf('%s,', arguments{:});
            replace = ['(', replace(1:end-1), ')'];
        end%


        function [minusLogDensity, minusLogDensityContributions, priorEval] = eval(this, model)
            if ~this.BeenSealed
                seal(this);
            end
            systemProperty = SystemProperty(model);
            nv = length(model);
            numProperties = numel(this.SystemProperties);
            numPriors = numel(this.SystemPriors);
            logDensityContributions = nan(1, numPriors, nv);
            priorEval = nan(1, numPriors, nv);
            outputNames = this.OutputNames;
            numOfOutputs = length(outputNames);
            for v = 1 : nv
                update(systemProperty, model, v);
                outputs = cell(1, numOfOutputs);
                count = 0;
                for i = 1 : numProperties
                    systemProperty.Function = this.SystemProperties(i).Function;
                    systemProperty.MaxNumOfOutputs = this.SystemProperties(i).MaxNumOfOutputs;
                    systemProperty.OutputNames = this.SystemProperties(i).OutputNames;
                    systemProperty.Specifics = this.SystemProperties(i).Specifics;
                    ithNumOfOutputs = this.SystemProperties(i).NumOfOutputs;
                    eval(systemProperty, model, v);
                    outputs(count+(1:ithNumOfOutputs)) = systemProperty.Outputs(1:end);
                    count = count + ithNumOfOutputs;
                end
                for i = 1 : numPriors
                    p = this.SystemPriors(i); 
                    x = p.Function(systemProperty.Values, systemProperty.StdCorr, outputs{:});
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
        end%


        function h = get.FunctionHeader(this)
            h = 'Value, StdCorr';
            outputNames = this.OutputNames;
            for i = 1 : numel(outputNames)
                h = [h, ', ', outputNames{i}];
            end
            h = ['@(', h, ')'];
        end%


        function list = get.OutputNames(this)
            if isempty(this.SystemProperties)
                list = cell.empty(1, 0);
                return
            end
            list = [ this.SystemProperties.OutputNames ];
        end%
    end




    methods (Static) % Static constructors
        function this = forModel(model)
            this = SystemPriorWrapper( );
            this = prepareSystemPriorWrapper(model, this);
        end%
    end
end
