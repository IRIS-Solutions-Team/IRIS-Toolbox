% varobj  Superclass for VAR based model objects.
%
% Backend IRIS class.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

classdef varobj < shared.UserDataContainer & shared.GetterSetter
    properties
        YNames = cell(1, 0); % Endogenous variables.
        ENames = cell(1, 0); % Residuals.
        
        A = [ ]; % Transition matrix.
        Omega = zeros(0); % Covariance matrix of reduced-form residuals.
        EigVal = zeros(1, 0); % Eigenvalues.
        
        Range = zeros(1, 0); % Estimation range.
        IxFitted = false(1, 0); % Index of periods actually fitted.
        
        GroupNames = cell(1, 0); % Groups in panel objects.
    end
    
    
    
    
    methods
        varargout = assign(varargin)
        varargout = datarequest(varargin)
        varargout = horzcat(varargin)
        varargout = isempty(varargin)
        varargout = ispanel(varargin)
        varargout = nfitted(varargin)
    end
    
    
    
    
    methods (Hidden)
        function flag = chkConsistency(this)
            flag = chkConsistency@shared.GetterSetter(this) && ...
                chkConsistency@shared.UserDataContainer(this);
        end

        
        
        
        disp(varargin)
        varargout = myoutpdata(varargin)
        varargout = myselect(varargin)
        varargout = implementGet(varargin)
        varargout = vertcat(varargin)
    end
    
    
    
    
    methods (Access=protected, Hidden)
        varargout = mycompatible(varargin)
        varargout = myenames(varargin)
        varargout = mygroupmethod(varargin)
        varargout = mygroupnames(varargin)
        varargout = myny(varargin)
        varargout = myprealloc(varargin)
        varargout = subsalt(varargin)
        varargout = myynames(varargin)
        varargout = specdisp(varargin)
    end
    
    
    
    
    methods (Static, Hidden)
        varargout = loadobj(varargin)
        varargout = mytelltime(varargin)
    end
    
    
    
    
    methods
        function this = varobj(varargin)
            if isempty(varargin)
                return
            end
            
            if length(varargin)==1 && isa(varargin, 'varobj')
                this = varargin{1};
                return
            end
            
            % Assign endogenous variable names, and create residual names.
            if ~isempty(varargin) ...
                    && ( iscellstr(varargin{1}) || ischar(varargin{1}) )
                this = myynames(this, varargin{1});
                varargin(1) = [ ];
                this = myenames(this, [ ]);
            end
            
            % Bkw compatibility:
            % VAR(YNames,GroupNames)
            if length(varargin)==1 ...
                    && ( ischar(varargin{1}) || iscellstr(varargin{1}) )
                this = mygroupnames(this,varargin{1});
                return
            end
            
            % Standard call:
            % VAR(YNames,...)
            % Options and userdata.
            if ~isempty(varargin) && iscellstr(varargin(1:2:end))
                [opt, ~] = passvalopt('varobj.varobj', varargin{:});
                if ~isempty(opt.userdata)
                    this = userdata(this, opt.userdata);
                end
                if ~isempty(opt.groups)
                    this = mygroupnames(this, opt.groups);
                end
            end
        end
    end
end
