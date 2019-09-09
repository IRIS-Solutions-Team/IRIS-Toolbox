classdef (CaseInsensitiveProperties=true) Options
    properties
        Range = @auto
        Highlight = double.empty(1, 0)
        Zeroline = true
        Orientation = 'landscape'
        Subplot = @auto
        Legend = @auto
        LegendLocation = 'Best'
    end


    properties (Constant)
        LegendLocationList = set(0, 'DefaultLegendLocation')
    end


    methods
        function this = Options(varargin)
            if nargin==0
                return
            end
            this = update(this, varargin{:});
        end%
        

        function this = update(this, varargin)
            for i = 1 : 2 : numel(varargin)
                name = varargin{i};
                name = strrep(name, '=', '');
                value = varargin{i+1};
                try
                    this.(name) = value;
                catch Err
                    fprintf('\n%s\n\n', Err.message);
                    warning( 'reptile:Options:FailedToSetOption', ...
                             '\nFailed to set this option: %s ', ...
                             name );
                end
            end
        end%


        function this = set.Subplot(this, value)
            if isequal(value, @auto)
                this.Subplot = @auto;
                return
            end
            if isnumeric(value) && all(value==round(value)) && all(value>0)
                if numel(value)==1
                    this.Subplot = [value, value];
                    return
                elseif numel(value)==2
                   this.Subplot = [value(1), value(2)];
                   return
               end
           end
           error( 'reptile:Options:InvalidValueSubplot', ...
                  'Invalid value assigned to option Subplot' );
        end%


        function this = set.Orientation(this, value)
            if any(strcmpi(value, {'landscape', 'portrait'}))
                this.Orientation = lower(value);
                return
            end
            error( 'reptile:Options:InvalidValueOrientation', ...
                  'Invalid value assigned to option Orientation' );
        end%


        function this = set.Range(this, value)
            if isequal(value, @auto) || isequal(value, Inf) ...
               || isa(value, 'DateWrapper') || isnumeric(value)
               this.Range = value;
               return
            end
            error( 'reptile:Options:InvalidValueRange', ...
                   'Invalid value assigned to option Range' );
        end%



        function this = set.Legend(this, value)
            if isequal(value, @auto) || isequal(value, true) ...
               || isequal(value, false)
               this.Legend = value;
               return
            end
            error( 'reptile:Options:InvalidValueLegend', ...
                   'Invalid value assigned to option Legend' );
        end%


        function this = set.LegendLocation(this, value)
            if strcmpi(value, 'none') 
                this.Legend = false;
                this.LegendLocation = 'Best';
                return
            end
            if any(strcmpi(value, this.LegendLocationList))
                this.LegendLocation = value;
                return
            end
            error( 'reptile:Options:InvalidValueLegendLocation', ...
                   'Invalid value assigned to option LegendLocation' );
        end%


        function this = set.Highlight(this, value)
            if isempty(value)
                this.Highlight = double.empty(1, 0);
                return
            end
            if isnumeric(value) || isa(value, 'DateWrapper')
                this.Highlight = value;
                return
            end
            error( 'reptile:Options:InvalidValueHighlight', ...
                   'Invalid value assigned to option Highlight' );
        end%


        function this = set.Zeroline(this, value)
            if isequal(value, true) || isequal(value, false)
                this.Zeroline = value;
                return
            end
            error( 'reptile:Options:InvalidValueZeroline', ...
                   'Invalid value assigned to option Zeroline' );
        end%
    end
end

