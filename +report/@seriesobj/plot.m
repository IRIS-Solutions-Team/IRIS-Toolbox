function [LegEnt,H,Time,Data,Grid] = plot(This,Ax)
% plot  [Not a public function] Draw report/series object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = This.parent;

dateOpt = {
    'dateTick=',par.options.datetick, ...
    'dateFormat=',par.options.dateformat, ...
    'freqLetters=',par.options.freqletters, ...
    'months=',par.options.months, ...
    'standinMonth=',par.options.standinmonth, ...
    };

if size(This.data{1}(:,:),2) > 0
    
    switch func2str(This.options.plotfunc)
        case 'plotcmp'
            % axes(ax);
            [~,H,rr,lhsRange,lhsData,lhsGrid, ...
                rhsRange,rhsData] = ...
                plotcmp(par.options.range,This.data{1}, ...
                dateOpt{:}, ...
                This.options.plotoptions{:}); %#ok<ASGLU>
            Time = lhsRange;
            Data = lhsData;
            Grid = lhsGrid;
        case {'predplot','plotpred'}
            [H,~,~,Time,Data,Grid] = plotpred( ...
                Ax,par.options.range, ...
                This.data{1}{:,1}, ...
                This.data{1}{:,2:end}, ...
                dateOpt{:}, ...
                This.options.plotoptions{:});
        otherwise
            [plotOpt,etc] = passvalopt('tseries.plot', ...
                dateOpt{:},This.options.plotoptions{:});
            [~,H,Time,Data,Grid] = tseries.myplot( ...
                This.options.plotfunc, ...
                Ax,par.options.range,[ ],This.data{1},'',plotOpt,etc{:});
    end
    
    % Create legend entries.
    nData = size(Data,2);
    [LegEnt,isExcluded] = mylegend(This,nData);
    if isExcluded && ~isempty(H)
        grfun.excludefromlegend(H);
    end
    
else
    
    % No data plotted.
    H = [ ];
    Time = [ ];
    Data = [ ];
    Grid = [ ];
    LegEnt = { };
    
end

end
