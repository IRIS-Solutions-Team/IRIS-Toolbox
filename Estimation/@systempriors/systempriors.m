% systempriors  System Priors (systempriors Objects).
%
% System priors are priors imposed on the system properties of a model as
% whole, such as shock response functions, frequency response functions, 
% correlations, or spectral densities; moreover, systempriors objects also
% allow for priors on combinations of parameters. The system priors can be
% combined with priors on individual parameters.
%
% Systempriors methods:
%
% Constructor
% ============
%
% * [`systempriors`](systempriors/systempriors) - Create new empty system priors object.
%
%
% Setting up priors
% ==================
%
% * [`prior`](systempriors/prior) - Add new prior to system priors object.
%
%
% Evaluating system priors
% =========================
%
% * [`eval`](systempriors/eval) - 
%
%
% Getting information about system priors
% ========================================
%
% * [`detail`](systempriors/detail) - Display details of system priors object.
% * [`isempty`](systempriors/isempty) - True if system priors object is empty.
% * [`length`](systempriors/length) - Number or priors in system priors object.
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef systempriors < shared.UserDataContainer & shared.GetterSetter
    properties
        Eval = cell(1, 0)
        PriorFn = cell(1, 0)
        Bounds = zeros(2, 0)
        UserString = cell(1, 0)
        Quantity = model.Quantity( )
        SystemFn = struct( )
        ShkSize = zeros(1, 0)
    end 




    methods
        varargout = detail(varargin)
        varargout = disp(varargin)
        varargout = eval(varargin)
        varargout = prior(varargin)
        varargout = isempty(varargin)
        varargout = length(varargin)        
    end
    


    
    methods (Access=protected, Hidden)
        varargout = defineSystemFunc(varargin)
    end




    methods (Hidden)
        varargout = chkConsistency(varargin)
    end
    
    


    methods
        function this = systempriors(varargin)
            % systempriors  Create new empty system priors object.
            %
            % Syntax
            % =======
            %
            %     S = systempriors(M)
            %
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object on whose system properties the priors will
            % be imposed.
            %
            %
            % Output arguments
            % =================
            %
            % * `S` [ systempriors ] - New empty system priors object.
            %
            %
            % Description
            % ============
            %
            % Example
            % ========
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.

            TYPE = @int8;

            %--------------------------------------------------------------------------
            
            if isempty(varargin)
               return
            end
            
            if length(varargin)==1 && isa(varargin{1}, 'systempriors')
                this = varargin{1};
                return
            end
            
            if length(varargin)==1 && isa(varargin{1}, 'model')
                m = varargin{1};
                this.Quantity = getp(m, 'Quantity');
                ne = sum(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
                if islinear(m)
                    this.ShkSize = repmat(model.DEFAULT_STD_LINEAR, 1, ne);
                else
                    this.ShkSize = repmat(model.DEFAULT_STD_NONLINEAR, 1, ne);
                end
                this = defineSystemFunc(this, m);
            end
        end 
    end 
end 
