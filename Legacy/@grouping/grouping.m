% grouping  Grouping and Aggregation of Contributions (grouping Objects)
%
% Grouping objects can be used for aggregating the contributions of shocks
% in model simulations, [`model/simulate`](model/simulate), or aggregating
% the contributions of measurement variables in Kalman filtering, 
% [`model/filter`](model/filter).
%
% Grouping methods:
%
% Constructor
% ============
%
% * [`grouping`](grouping/grouping) - Create new empty grouping object
%
%
% Getting information about groups
% =================================
%
% * [`detail`](grouping/detail) - Details of a grouping object
% * [`isempty`](grouping/isempty) - True for empty grouping object
%
%
% Setting up and using groups
% ============================
%
% * [`addgroup`](grouping/addgroup) - Add measurement variable group or shock group to grouping object
% * [`eval`](grouping/eval) - Evaluate contributions in input database S using grouping object G
%
%
% Getting on-line help on groups
% ===============================
%
%     help grouping
%     help grouping/function_name
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team


classdef grouping < iris.mixin.UserDataContainer ...
                  & iris.mixin.CommentContainer ...
                  & iris.mixin.GetterSetter 
    properties (Hidden)
        Type = ''
        GroupNames = cell(1, 0)
        GroupContents = cell(1, 0)
        
        List = cell(1, 0)
        Label = cell(1, 0)        
        IsLog = struct( )
    end
    
    
    
    
    properties (Hidden, Dependent)
        OtherContents
    end
    
    
    
    
    properties (Constant)
        OTHER_NAME = 'Other';
    end
    
    
    
    
    methods
        function this = grouping(varargin)
            % grouping  Create new empty grouping object.
            %
            % Syntax
            % =======
            %
            %     g = grouping(m, type, ...)
            %
            %
            % Input arguments
            % ================
            %
            % * `m` [ model ] - Model object.
            %
            % * `type` [ `'shock'` | `'measurement'` ] - Type of grouping object.
            %
            %
            % Output arguments
            % =================
            %
            % * `g` [ grouping ] - New empty grouping object.
            %
            %
            % Options
            % ========
            %
            % * `IncludeExtras=false` [ `true` | `false` ] - Include two extra
            % decomposition columns, `Init+Const+Dtrend` and `Nonlinear`, produced by
            % the `simulate( )` function, in the list of constributions available in
            % this grouping.
            %
            %
            % Description
            % ============
            %
            %
            % Example
            % ========
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2022 IRIS Solutions Team.
            
            this = this@iris.mixin.UserDataContainer( );
            this = this@iris.mixin.GetterSetter( );
            islogicalscalar = @(x) islogical(x) && isscalar(x);
            
            if isempty(varargin)
                return
            end
            
            if length(varargin)==1 && isa(varargin{1}, 'grouping')
                this = varargin{1};
                return
            end
            
            m = varargin{1};
            type = varargin{2};
            varargin(1:2) = [ ];

            defaults = {
                'IncludeExtras', false, islogicalscalar
            };

            opt = passvalopt(defaults, varargin{:});
            
            pp = inputParser( );
            pp.addRequired('m', @(x) isa(x, 'model'));
            pp.addRequired('type', @(x) ischar(x) || isstring(x));
            pp.parse(m, type);

            this = prepareGrouping(m, this, type, opt);
        end

        
        
        
        varargout = addgroup(varargin)
        varargout = detail(varargin)
        varargout = eval(varargin)
        varargout = isempty(varargin)
        varargout = rmgroup(varargin)
        varargout = splitgroup(varargin)
        varargout = get(varargin)
        varargout = set(varargin)
       
        
        
        
        function otherContents = get.OtherContents(This)
            allGroupContents = any([This.GroupContents{:}], 2);
            otherContents = ~allGroupContents;
        end
    end
    
    
    
    
    methods (Hidden)
        function flag = checkConsistency(this)
            flag = checkConsistency@iris.mixin.GetterSetter(this) ...
                   && checkConsistency@iris.mixin.UserDataContainer(this);
        end
        
        
        
        
        function disp(varargin)
            implementDisp(varargin{:});
            textual.looseLine( );
        end%
    end




    methods (Access=protected, Hidden)
        implementDisp(varargin)
    end
end
