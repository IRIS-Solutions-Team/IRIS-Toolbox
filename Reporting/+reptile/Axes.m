classdef Axes < reptile.Base
    properties
        AxesHandle = gobjects(0)
    end


    properties (Constant)
        CanBeParent = {'reptile.Figure'}
    end


    properties (Dependent)
        ShowLegend
        LegendLocation
    end


    methods
        function this = Axes(varargin)
            this = this@reptile.Base(varargin{:});
        end% 


        function add(this, varargin)
            add@reptile.Base(this, varargin{:}); 
        end%


        function axesHandle = plot(this, databank, axesHandle)
            this.AxesHandle = axesHandle;
            if this.NumChildren==0
                return
            end
            eval(this, databank);
            range = resolveRange(this);
            if isempty(range)
                return
            end
            data = collectData(this);
            plot(axesHandle, range, data);
            visual.backend.setAxesTight(axesHandle);
            if ~isempty(this.Caption)
                title(axesHandle, this.Caption);
            end
            grid(axesHandle, 'on');
            showHighlight(this);
            showZeroline(this);
            showLegend(this);
            visual.clickToExpand(this.AxesHandle);
        end%


        function eval(this, databank)
            for i = 1 : this.NumChildren
                eval(this.Container{i}, databank);
            end
        end%


        function range = resolveRange(this)
            range = this.Options.Range;
            if ~isequal(range, @auto) && ~isequal(range, Inf)
                return
            end
            if isempty(range)
                return
            end
            storeStarts = double.empty(1, 0);
            storeEnds = double.empty(1, 0);
            storeFreq = double.empty(1, 0);
            for i = 1 : this.NumChildren
                x = this.Container{i}.Value;
                if isa(x, 'TimeSubscriptable') && ~isnan(double(x.Start))
                    storeStarts = [storeStarts, double(x.Start)]; %#ok<AGROW>
                    storeEnds = [storeEnds, double(x.End)]; %#ok<AGROW>
                    storeFreq = [storeFreq, double(x.Frequency)]; %#ok<AGROW>
                end
            end
            inxToKeep = storeFreq==storeFreq(1);
            if ~any(inxToKeep)
                range = [ ];
                return
            end
            storeStarts = storeStarts(inxToKeep);
            storeEnds = storeEnds(inxToKeep);
            startOfRange = min(storeStarts);
            endOfRange = max(storeEnds);
            range = startOfRange : endOfRange;
        end%


        function data = collectData(this)
            if this.NumChildren==0
                data = double.empty(1, 0);
                return
            end
            tempData = cell(1, this.NumChildren);
            for i = 1 : this.NumChildren
                tempData{i} = this.Container{i}.Value;
            end
            data = horzcat(tempData{:});
        end%


        function legendHandle = showLegend(this)
            if ~this.ShowLegend
                legendHandle = gobjects(0);
                return
            end
            legendEntries = collectLegendEntries(this);
            legend(this.AxesHandle, legendEntries, 'Location', this.Options.LegendLocation);
        end%


        function legendEntries = collectLegendEntries(this)
            if this.NumChildren==0
                legendEntries = cell.empty(1, 0);
                return
            end
            legendEntries = cell.empty(1, 0);
            for i = 1 : this.NumChildren
                legendEntries = [legendEntries, this.Container{i}.LegendEntries]; %#ok<AGROW>
            end
        end%


        function showHighlight(this)
            if ~isempty(this.Options.Highlight)
                visual.highlight(this.AxesHandle, this.Options.Highlight);
            end
        end%


        function showZeroline(this)
            if ~isempty(this.Options.Zeroline)
                visual.zeroline(this.AxesHandle, 'LineWidth=', 0.5);
            end
        end%


        function flag = get.ShowLegend(this)
            if isequal(this.Options.Legend, false) ...
               || isequal(this.Options.Legend, true)
                flag = this.Options.Legend;
                return  
            end
            flag = false;
            for i = 1 : this.NumChildren
                if ~isempty(this.Container{i}.Caption)
                    flag = true;
                    return
                end
            end
        end%
    end
end
