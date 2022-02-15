% Type `web Grouping/index.md` for help on this class
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

classdef Grouping < shared.UserDataContainer ...
                  & shared.CommentContainer ...
                  & shared.GetterSetter 
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
        function this = Grouping(varargin)
            % Grouping  Create new empty Grouping object.
            %
            % Syntax
            % =======
            %
            %     g = Grouping(m, type, ...)
            %
            %
            % Input arguments
            % ================
            %
            % * `m` [ model ] - Model object.
            %
            % * `type` [ `'shock'` | `'measurement'` ] - Type of Grouping object.
            %
            %
            % Output arguments
            % =================
            %
            % * `g` [ Grouping ] - New empty Grouping object.
            %
            %
            % Options
            % ========
            %
            % * `'IncludeExtras='` [ `true` | *`false`* ] - Include two extra
            % decomposition columns, `Init+Const+Dtrend` and `Nonlinear`, produced by
            % the `simulate( )` function, in the list of constributions available in
            % this Grouping.
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
            % -Copyright (c) 2007-2021 IRIS Solutions Team.
            
            this = this@shared.UserDataContainer( );
            this = this@shared.GetterSetter( );
            
            if isempty(varargin)
                return
            end
            
            if length(varargin)==1 && isa(varargin{1}, 'Grouping')
                this = varargin{1};
                return
            end
            
            m = varargin{1};
            type = varargin{2};
            varargin(1:2) = [ ];
            opt = passvalopt('Grouping.Grouping', varargin{:});
            
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
            flag = checkConsistency@shared.GetterSetter(this) ...
                   && checkConsistency@shared.UserDataContainer(this);
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
