function [legEnt, h, time, data, grid] = plot(this, ax)
% plot  Draw report/series object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = this.parent;

dateOpt = {
    , 'DateTick', par.options.DateTick ...
    , 'DateFormat', par.options.dateformat ...
};

if size(this.data{1}(:, :), 2)>0
    
    stringPlotFunc = func2str(this.options.plotfunc);
    switch stringPlotFunc
        case 'plotcmp'
            % axes(ax);
            [~, h, rr, lhsRange, lhsData, lhsGrid, rhsRange, rhsData] = ...
                plotcmp( ...
                    par.options.range, this.data{1}, ...
                    dateOpt{:}, ...
                    this.options.plotoptions{:} ...
                ); %#ok<ASGLU>
            time = lhsRange;
            data = lhsData;
            grid = lhsGrid;
        case {'predplot', 'plotpred'}
            [h, ~, ~, time, data, grid] = plotpred( ...
                ax, par.options.range, ...
                this.data{1}{:, 1}, ...
                this.data{1}{:, 2:end}, ...
                dateOpt{:}, this.options.plotoptions{:} ...
            );
        case 'barcon'
            extras = cell.empty(1, 0);
            if isfield(this.options, 'colormap')
                extras = [extras, {'ColorMap', this.options.colormap}];
            end
            [h, time, data, grid] = Series.implementPlot( ...
                @series.barcon, ...
                ax, par.options.range, this.data{1}, ...
                dateOpt{:}, this.options.plotoptions{:}, extras{:} ...
            );
        otherwise
            [h, time, data, grid] = Series.implementPlot( ...
                this.options.plotfunc, ...
                ax, par.options.range, this.data{1}, ...
                dateOpt{:}, this.options.plotoptions{:} ...
            );
    end
    
    % Create legend entries.
    nData = size(data, 2);
    [legEnt, isExcluded] = mylegend(this, nData);
    if isExcluded && ~isempty(h)
        grfun.excludefromlegend(h);
    end
    
else
    
    % No data plotted.
    h = [ ];
    time = [ ];
    data = [ ];
    grid = [ ];
    legEnt = { };
    
end

end
