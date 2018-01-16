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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

classdef SystemPriorWrapper < handle
    properties
        Quantity = model.component.Quantity.empty(1, 0)
        SystemPriors = SystemPrior.empty(1, 0)
        SystemProperties = SystemProperty.empty(1, 0)
        LogDensityOutOfBounds = -Inf
    end


    properties (SetAccess=protected)
        Sealed = false
    end


    properties (Dependent)
        FunctionHeader
        ListOutputNames
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


        function addSystemProperty(this, outputNames, systemProperty)
            persistent INPUT_PARSER
            if isempty(INPUT_PARSER)
                INPUT_PARSER = extend.InputParser('SystemPriorWrapper.addSystemProperty');
                INPUT_PARSER.addRequired('SystemPriorWrapper', @(x) isa(x, 'SystemPriorWrapper'));
                INPUT_PARSER.addRequired('OutputNames', @(x) ischar(x) || isa(x, 'string') || iscellstr(x));
                INPUT_PARSER.addRequired('SystemProperty', @(x) isa(x, 'SystemProperty'));
            end
            INPUT_PARSER.parse(this, outputNames, systemProperty);
            assert( ...
                ~this.Sealed, ...
                exception.Base('SystemPriorWrapper:SystemPropertyToSealed', 'error') ...
            );
            if ~iscellstr(outputNames)
                outputNames = cellstr(outputNames);
            end
            assert( ...
                all(cellfun(@isvarname, outputNames)), ...
                exception.Base('SystemPriorWrapper:IllegalOutputName', 'error') ...
            );
            indexUnique = checkUniqueNames(this, outputNames);
            assert( ...
                all(indexUnique), ...
                exception.Base('SystemPriorWrapper:NonuniqueOutputName', 'error'), ...
                outputNames{~indexUnique} ...
            );
            numOutputs = numel(outputNames);
            assert( ...
                numOutputs<=systemProperty.MaxNumOutputs, ...
                exception.Base('SystemPriorWrapper:NamesExceedMaxNumOutputs', 'error') ...
            );
            systemProperty.OutputNames = outputNames;
            systemProperty.NumOutputs = numOutputs;
            this.SystemProperties(1, end+1) = systemProperty;
        end


        function addSystemPrior(this, varargin)
            if isempty(varargin)
                return
            end
            assert( ...
                ~this.Sealed, ...
                exception.Base('SystemPriorWrapper:SystemPriorToSealed', 'error') ...
            );
            if all(cellfun(@(x) isa(x, 'SystemPrior'), varargin))
                add = [varargin{:}];
            else
                add = SystemPrior(varargin{:});
            end
            numAdd = numel(add);
            this.SystemPriors(1, end+(1:numAdd)) = add;
        end


        function seal(this)
            seal(this.SystemPriors, this);
            this.Sealed = true;
        end


        function indexUnique = checkUniqueNames(this, names)
            listAllNames = [this.Quantity.Name, this.ListOutputNames];
            indexUnique = ~ismember(names, listAllNames);
        end


        function flag = existsOutputName(this, name)
            flag = any(strcmp(name, this.ListOutputNames));
        end


        function namedReferences = getNamedReferencesForOutputName(this, name)
            namedReferences = cell.empty(1, 0);
            for i = 1 : numel(this.SystemProperties)
                if any(strcmp(this.SystemProperties(i).OutputNames, name))
                    namedReferences = this.SystemProperties(i).NamedReferences;
                    break
                end
            end
        end


        function replace = replaceSystemPropertyReferences(systemPriorWrapper, outputName, reference)
            namedReferences = getNamedReferencesForOutputName(systemPriorWrapper, outputName);
            arguments = textual.splitArguments(reference);
            arguments = strtrim(arguments);
            for i = 1 : min(length(arguments), length(namedReferences))
                ithIndex = strcmp(arguments{i}, namedReferences{i});
                if any(ithIndex)
                    arguments{i} = sprintf('%g', find(ithIndex));
                end
            end
            replace = sprintf('%s,', arguments{:});
            replace = ['(', replace(1:end-1), ')'];
        end


        function [minusLogDensity, minusLogDensityContributions, priorEval] = eval(this, model)
            TYPE = @int8;
            if ~this.Sealed
                seal(this);
            end
            systemProperty = SystemProperty(model);
            nv = length(model);
            numProperties = numel(this.SystemProperties);
            numPriors = numel(this.SystemPriors);
            minusLogDensity = nan(1, 1, nv);
            minusLogDensityContributions = nan(1, numPriors, nv);
            logDensityContributions = nan(1, numPriors, nv);
            priorEval = nan(1, numProperties, nv);
            listOutputNames = this.ListOutputNames;
            numOutputs = length(listOutputNames);
            for v = 1 : nv
                update(systemProperty, model, v);
                outputs = cell(1, numOutputs);
                count = 0;
                for i = 1 : numProperties
                    systemProperty.Function = this.SystemProperties(i).Function;
                    systemProperty.MaxNumOutputs = this.SystemProperties(i).MaxNumOutputs;
                    systemProperty.NumOutputs = this.SystemProperties(i).NumOutputs;
                    systemProperty.Specifics = this.SystemProperties(i).Specifics;
                    ithNumOutputs = this.SystemProperties(i).NumOutputs;
                    eval(systemProperty);
                    outputs(count+(1:ithNumOutputs)) = systemProperty.Outputs(1:end);
                    count = count + ithNumOutputs;
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
        end


        function h = get.FunctionHeader(this)
            h = 'Value, StdCorr';
            listOutputNames = this.ListOutputNames;
            for i = 1 : numel(listOutputNames)
                h = [h, ', ', listOutputNames{i}];
            end
            h = ['@(', h, ')'];
        end


        function list = get.ListOutputNames(this)
            list = [ this.SystemProperties.OutputNames ];
        end
    end
end
