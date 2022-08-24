
classdef Element ...
    < rephrase.SettingsMixin ...
    & matlab.mixin.Copyable

    properties (Abstract)
        Type
    end


    properties
        Title (1, :) string = ""
        Content
    end


    properties (Hidden)
        Parent
        DataRequests (1, :) string = string.empty(1, 0)
    end


    methods
        function this = Element(varargin)

            this = this@rephrase.SettingsMixin();

            % Workaround for a bug in earlier versions of Matlab
            this.Type = string(this.Type);

            if nargin==0
                return
            end
            this.Title = varargin{1};
            assignOwnSettings(this, varargin{2:end});
        end%


        function show(this, level, last)
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
            printInfo(this);
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


        function printInfo(this)
            %(
            fprintf('%s "%s"', this.Type, this.Title);
            if ~isempty(this.SettingsAssigned)
                fprintf(' %s=', sort(this.SettingsAssigned));
            end
            if ~isempty(this.SettingsInherited)
                fprintf(' %s+', sort(this.SettingsInherited));
            end
            fprintf('\n');
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

