classdef systempriors < shared.UserDataContainer
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
    % Setting up priors
    % ==================
    %
    % * [`prior`](systempriors/prior) - Add new prior to system priors object.
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
    
    
    properties
        Eval = cell(1,0);
        PriorFn = cell(1,0);
        LowerBnd = zeros(1,0);
        UpperBnd = zeros(1,0);
        UserString = cell(1,0);
        Names = cell(1,0);
        NameTypes = zeros(1,0);
        SystemFn = struct( );
        ShkSize = zeros(1,0);
    end % properties

    
    methods
        varargout = detail(varargin)
        varargout = disp(varargin)
        varargout = prior(varargin)
        varargout = isempty(varargin)
        varargout = length(varargin)        
    end % methods
    
    
    methods (Access=protected,Hidden)
        varargout = mydefinesystemfunc(varargin)
    end % methods
    
    
    methods
        function This = systempriors(varargin)
            % systempriors  Create new empty system priors object.
            %
            % Syntax
            % =======
            %
            %     S = systempriors(M)
            %
            % Input arguments
            % ================
            %
            % * `M` [ model ] - Model object on whose system properties the priors will
            % be imposed.
            %
            % Output arguments
            % =================
            %
            % * `S` [ systempriors ] - New empty system priors object.
            %
            % Description
            % ============
            %
            % Example
            % ========
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2017 IRIS Solutions Team.

            %--------------------------------------------------------------------------
            
            if isempty(varargin)
                return
            end
            
            if length(varargin) == 1 ...
                    && isa(varargin{1},'systempriors')
                This = varargin{1};
                return
            end
            
            if length(varargin) == 1 ...
                    && isa(varargin{1},'model')
                m = varargin{1};
                This.Names = implementGet(m,'name');
                This.NameTypes = implementGet(m,'nametype');
                ne = sum(This.NameTypes==3);
                if islinear(m)
                    This.ShkSize = ones(1,ne);
                else
                    This.ShkSize = log(1.01)*ones(1,ne);
                end
                This = mydefinesystemfunc(This,m);
            end
            
        end % systempriors( )
    end % methods
end % classdef
