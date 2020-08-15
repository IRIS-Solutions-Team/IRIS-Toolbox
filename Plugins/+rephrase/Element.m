classdef Element ...
    < matlab.mixin.Copyable

    properties (Abstract, Constant)
        Type
    end


    properties
        Title (1, :) string = ""
        Settings (1, 1) struct = rephrase.Element.DEFAULT_ELEMENT_SETTINGS
        Content
    end


    properties (Hidden)
        Parent
        DataRequests (1, :) string = string.empty(1, 0)
    end


    properties (Constant, Hidden)
        DEFAULT_ELEMENT_SETTINGS = struct( ...
            "Class", "" ...
        )
    end


    methods
        function this = Element(varargin)
            if nargin==0
                return
            end
            this.Title = varargin{1};
            varargin(1) = [ ];
            for i = 1 : 2 : numel(varargin)
                name = erase(varargin{i}, "=");
                name = replaceBetween(name, 1, 1, upper(extractBetween(name, 1, 1)));
                this.Settings.(name) = varargin{i+1};
            end
        end%


        function show(this, level, last);
            %(
            if nargin<2
                last = false;
                level = '';
                textual.looseLine( );
            end
            if isempty(level)
                fprintf('%s', [level, '    ']);
                addToLevel = '    ';
            else
                fprintf('%s', [level, '|-- ']);
                addToLevel = '|   ';
            end
            fprintf('%s "%s"\n', this.Type, this.Title);
            if isa(this, 'rephrase.Container')
                for i = 1 : numel(this.Content)
                    if last
                        addToLevel = '    ';
                    end
                    show(this.Content{i}, [level, addToLevel], i==numel(this.Content));
                end
            end
            if isempty(level)
                textual.looseLine( );
            end
            %)
        end%
    end


    methods (Access=protected)
        function new = copyElement(this)
            new = copyElement@matlab.mixin.Copyable(this);
            if iscell(new.Content)
                for i = 1 : numel(new.Content)
                    if isa(new.Content{i}, 'rephrase.Element')
                        new.Content{i} = copy(new.Content{i});
                    end
                end
            end
        end% 
    end
end

