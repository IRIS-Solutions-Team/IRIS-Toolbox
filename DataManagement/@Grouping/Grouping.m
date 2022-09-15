
classdef Grouping < iris.mixin.UserDataContainer ...
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
        function this = Grouping(m, type, varargin)
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
            % * `IncludeExtras=false` [ `true` | `false` ] - Include two extra
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
            % -Copyright (c) 2007-2022 IRIS Solutions Team.

            this = this@iris.mixin.UserDataContainer( );
            this = this@iris.mixin.GetterSetter( );

            if nargin==0
                return
            end

            if nargin==1 && isa(m, 'Grouping')
                this = m;
                return
            end

            persistent ip
            if isempty(ip)
                ip = extend.InputParser();
                ip.addRequired('model', @(x) isa(x, 'model') || isa(x, 'Model'));
                ip.addRequired('type', @(x) ischar(x) || isstring(x));
                ip.addParameter('IncludeExtras', @(x) isequal(x, true) || isequal(x, false));
            end
            opt = parse(ip, m, type, varargin{:});

            this = prepareGrouping(m, this, type, opt);
        end




        varargout = add(varargin)
        varargout = detail(varargin)
        varargout = eval(varargin)
        varargout = isempty(varargin)
        varargout = remove(varargin)
        varargout = split(varargin)
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
