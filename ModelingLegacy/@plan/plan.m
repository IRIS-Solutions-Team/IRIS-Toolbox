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
% -Copyright (c) 2007-2018 IRIS Solutions Team
   
classdef plan < shared.UserDataContainer & shared.GetterSetter
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
    
    
    methods
        function this = plan(varargin)
            % plan  Create new empty simulation plan object.
            %
            % Syntax
            % =======
            %
            %     P = plan(Context, M, Range)
            %
            %
            % Input arguments
            % ================
            %
            % * `Context` [ `@simulate` | `@steady` ] - Context for which the plan will
            % be prepared.
            %
            % * `M` [ model ] - Model object that will be simulated subject to this
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
            % [`jforecast`](model/jforecast) functions through the option `'plan='`.
            %
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2018 IRIS Solutions Team.
            
            this = this@shared.UserDataContainer( );
            this = this@shared.GetterSetter( );
            
            if length(varargin)>1
                if isa(varargin{1}, 'function_handle')
                    context = varargin{1};
                    varargin(1) = [ ];
                else
                    context = @dynamic;
                end
                
                [M, Range, this.XList, this.NList, this.CList] = ...
                    irisinp.parser.parse('plan.plan', varargin{:});
                
                this.Start = Range(1);
                this.End = Range(end);
                nPer = round(this.End - this.Start + 1);
                
                % List of names that can be exogenized, endogenized, and conditioned upon.
                if isa(M, 'model')
                    [this.XList,this.NList,this.CList] = myinfo4plan(M);
                end
                
                % Anchors.
                this.XAnch = false(length(this.XList),nPer);
                this.NAnchReal = false(length(this.NList),nPer);
                this.NAnchImag = false(length(this.NList),nPer);
                this.CAnch = false(length(this.CList),nPer);
                
                % Weights for endogenized data points.
                this.NWghtReal = zeros(length(this.NList),nPer);
                this.NWghtImag = zeros(length(this.NList),nPer);
                
                % Autoexogenize.
                this.AutoX = nan(size(this.XList));
                
                if ~isempty(M)
                    try %#ok<TRYNC>
                        a = autoexog(M);
                        lsExg = fieldnames(a.Dynamic);
                        if ~isempty(lsExg)
                            lsExg = lsExg(:).';
                            lsEndg = struct2cell(a.Dynamic);
                            lsEndg = lsEndg(:).';
                            for i = 1 : length(lsExg)
                                ixExg = strcmp(this.XList, lsExg{i});
                                ixEndg = strcmp(this.NList, lsEndg{i});
                                this.AutoX(ixExg) = find(ixEndg);
                            end
                        end
                    end
                end
            end    
        end
        
        
        
        
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
        varargout = disp(varargin)
        
        
        
        
        function flag = chkConsistency(this)
            flag = chkConsistency@shared.GetterSetter(this) && ...
                chkConsistency@shared.UserDataContainer(this);
        end
    end
    

    
    
    methods (Access=protected, Hidden)
        varargout = mychngplan(varargin)
    end
    
    
    
    
    methods
        function varargout = autoexogenise(varargin)
            [varargout{1:nargout}] = autoexogenize(varargin{:});
        end
        
        function varargout = exogenise(varargin)
            [varargout{1:nargout}] = exogenize(varargin{:});
        end
        
        function varargout = endogenise(varargin)
            [varargout{1:nargout}] = endogenize(varargin{:});
        end
    end
end
