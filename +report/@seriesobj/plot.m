function [legEnt, h, time, data, grid] = plot(this, ax)
% plot  Draw report/series object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = this.parent;

dateOpt = {
    'DateTick=', par.options.DateTick, ...
    'DateFormat=', par.options.dateformat, ...
    'FreqLetters=', par.options.freqletters, ...
    'Months=', par.options.months, ...
    'StandInMonth=', par.options.standinmonth, ...
    };

if size(this.data{1}(:, :), 2) > 0
    
    switch func2str(this.options.plotfunc)
        case 'plotcmp'
            % axes(ax);
            [~, h, rr, lhsRange, lhsData, lhsGrid, ...
                rhsRange, rhsData] = ...
                plotcmp(par.options.range, this.data{1}, ...
                dateOpt{:}, ...
                this.options.plotoptions{:}); %#ok<ASGLU>
            time = lhsRange;
            data = lhsData;
            grid = lhsGrid;
        case {'predplot', 'plotpred'}
            [h, ~, ~, time, data, grid] = plotpred( ...
                ax, par.options.range, ...
                this.data{1}{:, 1}, ...
                this.data{1}{:, 2:end}, ...
                dateOpt{:}, ...
                this.options.plotoptions{:});
        otherwise
            [plotOpt, etc] = passvalopt( ...
                'tseries.plot', ...
                dateOpt{:}, ...
                this.options.plotoptions{:} ...
                );
            [~, h, time, data, grid] = tseries.myplot( ...
                this.options.plotfunc, ...
                ax, par.options.range, [ ], this.data{1}, '', plotOpt, etc{:});
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
