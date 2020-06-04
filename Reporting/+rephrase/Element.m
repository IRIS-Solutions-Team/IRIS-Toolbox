classdef Element ...
    < matlab.mixin.Copyable

    properties (Abstract, Constant)
        Type
    end


    properties
        Parent
        Title (1, :) string = ""
        Settings (1, 1) struct = rephrase.Element.DEFAULT_ELEMENT_SETTINGS
        Content
    end


    properties (Constant, Hidden)
        DEFAULT_ELEMENT_SETTINGS = struct( ...
            "Class", "" ...
        )
    end


    methods
        function this = Element(varargin)
            if isempty(varargin)
                return
            end
            this.Title = varargin{1};
            varargin(1) = [ ];
            for i = 1 : 2 : numel(varargin)
                name = erase(varargin{i}, "=");
                this.Settings.(name) = varargin{i+1};
            end
        end%


        function j = jsonencode(this)
            j = jsonencode(prepareForJson(this));
        end%
    end


    methods (Access=protected)
        function j = prepareForJson(this)
            j = struct( );
            j.Type = char(this.Type);
            j.Title = this.Title;
            j.Settings = this.Settings;
            j.Content = this.Content;
            if isa(this, 'rephrase.Container')
                for i = 1 : numel(j.Content)
                    if isa(j.Content{i}, 'rephrase.Element')
                        j.Content{i} = prepareForJson(j.Content{i});
                    end
                end
            end
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

