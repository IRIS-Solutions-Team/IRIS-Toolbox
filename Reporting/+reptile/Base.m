classdef Base < handle
    properties
        Caption = char.empty(1, 0)
        Container = cell.empty(1, 0)
        Options = reptile.Options( )
    end


    properties (Constant, Abstract)
        CanBeParent 
    end


    properties (Dependent)
        NumChildren
    end


    methods
        function this = Base(parent, caption, varargin)
            persistent parser
            if nargin==0
                return
            end
            if isempty(parser)
                parser = extend.InputParser('reptile.Base');
                parser.addRequired('Parent', @(x) isempty(x) || isa(x, 'reptile.Base'));
                parser.addRequired('Caption', @(x) ischar(x) || isa(x, 'string'));
                parser.addOptional('Options', @(x) iscellstr(x(1:2:end)));
            end
            parser.parse(parent, caption, varargin);
            if ~isempty(caption)
                this.Caption = caption;
            end
            if ~isempty(parent)
                this.Options = parent.Options;
                parent.add(this);
            end
            if ~isempty(varargin)
                this.Options = update(this.Options, varargin{:});
            end
        end%


        function add(this, varargin)
            if nargin<=1
                return
            end
            for i = 1 : numel(varargin)
                if ~isa(varargin{i}, 'reptile.Base')
                    error( 'reptile:Base:CannotAddToReptile', ...
                           'Cannot add a non-report object to the report');
                end
                if ~this.isAddable(varargin{i})
                    error( 'reptile:Figure:CannotAddToReptileFigure', ...
                           'Cannot add this type of object to %s: %s ', ...
                           class(this), class(varargin{i}) );
                end
                this.Container = [ this.Container, varargin(i) ];
            end
        end%


        function flag = isAddable(this, child)
            flag = any(strcmpi(class(this), child.CanBeParent));
        end%


        function this = set.Caption(this, value)
            if ischar(value) || isa(value, 'string')
                    this.Caption = value;
                    return
            end
            error( 'reptile:Base:InvalidValueCaption', ...
                   'Invalid value assigned to Caption' );
        end%


        function n = get.NumChildren(this)
            n = numel(this.Container);
        end%
    end
end
