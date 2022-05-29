% plan  Model Simulation Plans (plan Objects)
%
% Simulation plans complement the use of the
% [`model/simulate`](model/simulate) or
% [`model/jforecast`](model/jforecast) functions.
%
% You need to use a simulation plan object to set up the following types of
% more complex simulations or forecasts (or a combination of these):
%
% * simulations or forecasts with some of the model variables temporarily
% exogenized;
%
% * simulations with some of the non-linear equations solved in an exact
% non-linear mode;
%
% * forecasts conditioned upon some variables;
%
% The plan object is passed to the [`model/simulate`](model/simulate) or
% [`model/jforecast`](model/jforecast) functions through the `'plan='`
% option.
%
% Plan methods:
%
%
% Constructor
% ============
%
%
% * [`plan`](plan/plan) - Create new empty simulation plan object.
%
%
% Getting information about simulation plans
% ===========================================
%
% * [`detail`](plan/detail) - Display details of a simulation plan.
% * [`get`](plan/get) - Query to plan object.
% * [`nnzcond`](plan/nnzcond) - Number of conditioning data points.
% * [`nnzendog`](plan/nnzendog) - Number of endogenized data points.
% * [`nnzexog`](plan/nnzexog) - Number of exogenized data points.
%
%
% Setting up simulation plans
% ============================
%
% * [`autoexogenize`](plan/autoexogenize) - Exogenize variables and automatically endogenize corresponding shocks.
% * [`condition`](plan/condition) - Condition forecast upon the specified variables at the specified dates.
% * [`endogenize`](plan/endogenize) - Endogenize shocks or re-endogenize variables at the specified dates.
% * [`exogenize`](plan/exogenize) - Exogenize variables or re-exogenize shocks at the specified dates.
% * [`reset`](plan/reset) - Remove all endogenized, exogenized, autoexogenized and conditioned upon data points from simulation plan.
% * [`swap`](plan/swap) - Swap endogeneity and exogeneity of variables and shocks.
%
%
% Referencing plan objects
% ==========================
%
% * [`subsref`](plan/subsref) - Subscripted reference for plan objects.
%
%
% Getting on-line help on simulation plans
% =========================================
%
%     help plan
%     help plan/function_name
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team
   
classdef plan < iris.mixin.UserDataContainer ...
              & iris.mixin.CommentContainer ...
              & iris.mixin.GetterSetter
    properties
        Start = NaN
        End = NaN
        XList = { } % List of names that can be exogenized.
        NList = { } % List of names that can be endogenized.
        CList = { } % List of names upon which it can be conditioned.
        XAnch = [ ] % Exogenized.
        NAnchReal = [ ] % Endogenized real.
        NAnchImag = [ ] % Endogenized imag.
        NWghtReal = [ ] % Weights for endogenized real.
        NWghtImag = [ ] % Weights for endogenized imag.
        CAnch = [ ] % Conditioned.
        AutoX = [ ]
    end


    properties (Dependent)
        Range
    end
    
    
    methods
        function this = plan(varargin)
            % plan  Create new empty simulation plan object.
            %
            % Syntax
            % =======
            %
            %     P = plan(Context, model, Range)
            %
            %
            % Input arguments
            % ================
            %
            % * `Context` [ `@simulate` | `@steady` ] - Context for which the plan will
            % be prepared.
            %
            % * `model` [ model ] - Model object that will be simulated subject to this
            % simulation plan.
            %
            % * `Range` [ numeric | char ] - Simulation range; this range must exactly
            % correspond to the range on which the model will be simulated.
            %
            %
            % Output arguments
            % =================
            %
            % * `P` [ plan ] - New empty simulation plan.
            %
            %
            % Description
            % ============
            %
            % Simulation plans are useful in the following types of more complex
            % simulations or forecats:
            %
            % * simulations or forecasts with some of the model variables temporarily
            % exogenized;
            %
            % * simulations with some of the non-linear equations solved exactly.
            %
            % * forecasts conditioned upon some variables;
            %
            % The plan object is passed to the [simulate](model/simulate) or
            % [`jforecast`](model/jforecast) functions through the option Plan.
            %
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox
            % -Copyright (c) 2007-2022 IRIS Solutions Team
            
            this = this@iris.mixin.UserDataContainer( );
            this = this@iris.mixin.GetterSetter( );
            
            if nargin==0
                return
            end

            if nargin==1 && isa(varargin{1}, 'plan')
                this = varargin{1};
                return
            end

            if isa(varargin{1}, 'function_handle')
                context = varargin{1};
                varargin(1) = [ ];
            else
                context = @dynamic;
            end
            
            persistent parser
            if isempty(parser)
                 parser = extend.InputParser('plan.plan');
                 parser.addRequired('Model', @(x) isa(x, 'model') || isempty(x));
                 parser.addRequired('SimulationRange', @validate.properRange);
                 parser.addOptional('XList', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                 parser.addOptional('NList', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
                 parser.addOptional('CList', cell.empty(1, 0), @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
            end
            parser.parse(varargin{:});
            model = parser.Results.Model;
            this.XList = parser.Results.XList;
            this.NList = parser.Results.NList;
            this.CList = parser.Results.CList;
            
            if isa(model, 'model')
                [this.XList, this.NList, this.CList] = myinfo4plan(model);
            end
            
            this.Range = parser.Results.SimulationRange;
            numOfPeriods = round(this.End - this.Start + 1);
            
            % Anchors
            this.XAnch = false(length(this.XList), numOfPeriods);
            this.NAnchReal = false(length(this.NList), numOfPeriods);
            this.NAnchImag = false(length(this.NList), numOfPeriods);
            this.CAnch = false(length(this.CList), numOfPeriods);
            
            % Weights for endogenized data points.
            this.NWghtReal = zeros(length(this.NList), numOfPeriods);
            this.NWghtImag = zeros(length(this.NList), numOfPeriods);
            
            % Autoexogenize.
            this.AutoX = nan(size(this.XList));
            
            if ~isempty(model)
                try %#ok<TRYNC>
                    a = autoswap(model);
                    lsExg = fieldnames(a.Simulate);
                    if ~isempty(lsExg)
                        lsExg = lsExg(:).';
                        lsEndg = struct2cell(a.Simulate);
                        lsEndg = lsEndg(:).';
                        for i = 1 : length(lsExg)
                            ixExg = strcmp(this.XList, lsExg{i});
                            ixEndg = strcmp(this.NList, lsEndg{i});
                            this.AutoX(ixExg) = find(ixEndg);
                        end
                    end
                end
            end
        end%
        
        
        
        
        varargout = autoexogenize(varargin)
        varargout = condition(varargin)
        varargout = detail(varargin)
        varargout = exogenize(varargin)
        varargout = endogenize(varargin)
        varargout = isempty(varargin)
        varargout = nnzcond(varargin)
        varargout = nnzendog(varargin)
        varargout = nnzexog(varargin)
        varargout = reset(varargin)
        varargout = subsref(varargin)
        varargout = get(varargin)
        varargout = set(varargin)
    end
    
    
    methods (Hidden)
        varargout = mydateindex(varargin)


        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%
        
        
        function flag = checkConsistency(this)
            flag = checkConsistency@iris.mixin.GetterSetter(this) && ...
                checkConsistency@iris.mixin.UserDataContainer(this);
        end%%
    end
    

    
    
    methods (Access=protected, Hidden)
        implementDisp(varargin)
        varargout = mychngplan(varargin)
    end
    
    
    
    
    methods
        function varargout = autoexogenise(varargin)
            [varargout{1:nargout}] = autoexogenize(varargin{:});
        end%
        
        function varargout = exogenise(varargin)
            [varargout{1:nargout}] = exogenize(varargin{:});
        end%
        
        function varargout = endogenise(varargin)
            [varargout{1:nargout}] = endogenize(varargin{:});
        end%
    end


    methods
        function value = get.Range(this)
            value = this.Start : this.End;
        end%%


        function this = set.Range(this, value)
           value = double(value);
           this.Start = value(1);
           this.End = value(end);
        end%%
    end
end
