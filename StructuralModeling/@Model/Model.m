% Type `web Model/index.md` for help on this class
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

classdef Model ...
    < model ...
    & matlab.mixin.CustomDisplay ...
    & shared.Plan ...
    & shared.DataProcessor


    properties (Constant)
        FILE_NAME_WHEN_INPUT_STRING = "[input-string]"
    end


    methods % Constructor
        function this = Model(varargin)
% model  Create new Model object from model file
%{
% ## Syntax ##
%
%
%     m = Model(fileName, ...)
%     m = Model(modelFile, ...)
%     m = Model(m, ...)
%
%
% ## Input Arguments ##
%
%
% __`fileName`__ [ char | cellstr | string ]
% >
% Name(s) of model file(s) that will be loaded and converted to a new model
% object.
%
%
% __`modelFile`__ [ model.File ]
% >
% Object of model.File class.
%
%
% __`m`__ [ Model ]
% >
% Rebuild a new model object from an existing one; see Description for when
% you may need this.
%
%
% ## Output Arguments ##
%
%
% __`M`__ [ model ]
% >
% New model object based on the input model code file or files.
%
%
% ## Options ##
%
%
% __`Assign=struct( )`__ [ struct | *empty* ]
% >
% Assign model parameters and/or steady states from this database at the
% time the model objects is being created.
%
%
% __`AutoDeclareParameters=false`__ [ `true` | `false` ]
% >
% If `true`, skip parameter declaration in the model file, and determine
% the list of parameters automatically as residual names found in equations
% but not declared.
%
%
% __`BaseYear=@config`__ [ numeric | `@config` ]
% >
% Base year for constructing deterministic time trends; `@config` means the
% base year will be read from iris configuration.
%
%
% __`Comment=''`__ [ char ]
% >
% Text comment attached to the model object.
%
%
% __`CheckSyntax=true`__ [ `true` | `false` ]
% >
% Perform syntax checks on model equations; setting `CheckSyntax=false` may
% help reduce load time for larger model objects (provided the model file
% is known to be free of syntax errors).
%
%
% __`Epsilon=eps^(1/4)`__ [ numeric ]
% >
% The minimum relative step size for numerical differentiation.
%
%
% __`Linear=false`__ [ `true` | `false` ]
% >
% Indicate linear models.
%
%
% __`MakeBkw=@auto`__ [ `@auto` | `@all` | cellstr | char ]
% >
% Variables included in the list will be made part of the vector of
% backward-looking variables; `@auto` means the variables that do not have
% any lag in model equations will be put in the vector of forward-looking
% variables.
%
%
% __`AllowMultiple=false`__ [ true | false ]
% >
% Allow each variable, shock, or parameter name to be declared (and
% assigned) more than once in the model file.
%
%
% __`Optimal={ }`__ [ cellstr ]
% >
% Specify optimal policy options, see below; only applies when the keyword
% [`min`](irislang/min) is used in the model file.
%
%
% __`OrderLinks=true`__ [ `true` | `false` ]
% >
% Reorder `!links` so that they can be executed sequentially.
%
%
% __`RemoveLeads=false`__ [ `true` | `false` ]
% >
% Remove all leads (aka forward-looking variables) from the state-space
% vector and keep included only current dates and lags; the leads are not a
% necessary part of the model solution and can dropped e.g. for memory
% efficiency reasons in larger model objects.
%
%
% __`SteadyOnly=false`__ [ `true` | `false` ]
% >
% Read in only the steady-state versions of equations (if available).
%
%
% __`Std=@auto`__ [ numeric | `@auto` ]
% >
% Default standard deviation for model shocks; `@auto` means `1` for linear
% models and `log(1.01)` for nonlinear models.
%
%
% __`UserData=[ ]`__ [ ... ]
% >
% Attach user data to the model object.
%
%
% ## Options for Optimal Policy Models ##
%
%
% The following options for optimal policy models need to be
% nested within the `'Optimal='` option.
%
%
% __`MultiplierPrefix='Mu_'`__ [ char ]
% >
% Prefix used to create names for lagrange multipliers associated with the
% optimal policy problem; the prefix is followed by the equation number.
%
%
% __`Nonnegative={ }`__ [ cellstr ]
% >
% List of variables
% constrained to be nonnegative.
%
%
% __`Type='discretion'`__ [ `'commitment'` | `'discretion'` ]
% >
% Type of optimal policy; `'discretion'` means leads (expectations) are
% taken as given and not differentiated w.r.t. whereas `'commitment'` means
% both lags and leads are differentiated w.r.t.
%
%
% ## Description ##
%
%
% ### Loading a Model File ###
%
%
% The `model` function can be used to read in a [model
% file](irislang/Contents) named `FileName`, and create a model object `M`
% based on the model file. You can then work with the model object in your
% own m-files, using using the IRIS [model functions](model/Contents) and
% standard Matlab functions.
%
% If `FileName` is a cell array of more than one file names
% then all files are combined together in order of appearance.
%
%
% ### Rebuilding an Existing Model Object ###
%
%
% When calling the function `model` with an existing model object as the
% first input argument, the model will be rebuilt from scratch. The typical
% instance where you may need to call the constructor this way is changing
% the `RemoveLeads=` option. Alternatively, the new model object can be
% simply rebuilt from the model file.
%
%
% ## Example ##
%
%
% Read in a model code file named `my.model`, and declare the model as
% linear:
%
%     m = Model('my.model', 'Linear=', true);
%
%
% ## Example ##
%
%
% Read in a model code file named `my.model`, declare the model as linear,
% and assign some of the model parameters:
%
%     m = Model('my.model', 'Linear=', true, 'Assign=', P);
%
% Note that this is equivalent to
%
%     m = Model('my.model', 'Linear=', true);
%     m = assign(m, P);
%
% unless some of the parameters passed in to the `model` fuction are needed
% to evaluate [`!if`](irislang/if) or [`!switch`](irislang/switch)
% expressions.
%}

            if nargin==0
                return
            % elseif nargin==1 && isa(varargin{1}, 'Model')
                % this = varargin{1};
            % elseif nargin==1 && isstruct(varargin{1})
                % this = struct2obj(this, varargin{1});
            elseif nargin>=1 && ( ...
                ischar(varargin{1}) || iscellstr(varargin{1}) || isstring(varargin{1}) ...
                || isa(varargin{1}, 'model.File') ...
            )
                modelFile = varargin{1};
                varargin(1) = [];
                [this, opt, parserOpt, optimalOpt] = processConstructorOptions(this, varargin{:});
                [this, opt] = file2model(this, modelFile, opt, opt.Preparser, parserOpt, optimalOpt);
                this = build(this, opt);
            else
                exeption.error([
                    "Model:InvalidConstructorCall"
                    "Invalid call to Model constructor."
                ]);
            end
        end%
    end % methods


    methods % Public Interface
        %(
        varargout = access(varargin)
        varargout = analyticGradients(varargin)
        varargout = byAttributes(varargin)
        varargout = changeLogStatus(varargin)
        varargout = checkInitials(varargin)
        varargout = findEquation(varargin)
        varargout = getBounds(varargin)
        varargout = kalmanFilter(varargin)
        varargout = equationStartsWith(varargin)
        varargout = isLinear(varargin)
        varargout = printWithValues(varargin)
        varargout = replaceNames(varargin)
        varargout = rescaleStd(varargin)
        varargout = resetBounds(varargin)
        varargout = setBounds(varargin)
        varargout = simulate(varargin)
        varargout = solutionMatrices(varargin)
        varargout = table(varargin)
        varargout = quickAssign(varargin)
        %)
    end % methods


    methods (Access=protected) % Custom Display
        %(
        function groups = getPropertyGroups(this)
            x = struct( ... 
                "FileName", this.FileName, ...
                "Comment", string(this.Comment), ...
                "IsLinear", this.IsLinear, ...
                "IsGrowth", this.IsGrowth, ...
                "NumVariants", countVariants(this), ...
                "NumVariantsSolved", countVariantsSolved(this), ...
                "NumMeasurementEquations", countMeasurementEquations(this), ...
                "NumTransitionEquations", countTransitionEquations(this), ... 
                "SizeTransitionMatrix", sizeTransitionMatrix(this), ...
                "NumExportFiles", countExportFiles(this), ...
                "UserData", this.UserData ...
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
            if this.IsLinear
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


        varargout = postprocessFilterOutput(varargin)
        varargout = getIdInitialConditions(varargin)
        varargout = getInxOfInitInPresample(varargin)
        varargout = getIthRectangularSolution(varargin)
        varargout = implementGet(varargin)
        varargout = prepareHashEquations(varargin)
        varargout = prepareLinearSystem(varargin)
        varargout = prepareRectangular(varargin)
        varargout = simulateFrames(varargin)
    end % methods


    methods (Access=protected, Hidden)
        varargout = varyParams(varargin)
    end % methods


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


    methods (Hidden) % Interface for shared.Plan
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
                model.component.Pairing.getAutoswaps(pairingVector, this.Quantity);
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

