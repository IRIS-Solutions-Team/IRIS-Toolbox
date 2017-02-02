function [Ln,Cp] = myinfline(Ax,Dir,Loc,varargin)
% myinfline  [Not a public function] Add infintely stretched line at specified position.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

Ln = zeros(1,0);
Cp = zeros(1,0);

% Look for non-legend axes objects one level deep; this allows figure
% handles to be entered instead of axes objects.
Ax = findobj(Ax,'type','axes','-depth',1,'-not','tag','legend');

if isempty(Ax) || isempty(Dir) || isempty(Loc)
    return
end

nAx = length(Ax);
if nAx > 1
    for i = 1 : nAx
        [h,c] = grfun.myinfline(Ax(i),Dir,Loc,varargin{:});
        Ln = [Ln,h]; %#ok<AGROW>
        Cp = [Cp,c]; %#ok<AGROW>
    end
    return
end

pp = inputParser( );
pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp.addRequired('Dir',@(x) ischar(x) && any(strncmpi(x,{'h','v'},1)));
pp.addRequired('Pos',@isnumeric);
pp.parse(Ax,Dir,Loc);

[opt,lineOpt] = passvalopt('grfun.infline',varargin{:});
lineOpt(1:2:end) = strrep(lineOpt(1:2:end),'=','');

%--------------------------------------------------------------------------

isVertical = strncmpi(Dir,'v',1);

% Check for plotyy peers, and return the background axes object.
% Ax = grfun.mychkforpeers(Ax);

% Vertical lines: If this is a time series graph, convert the vline
% position to a date grid point.
if isVertical
    if isequal(getappdata(Ax, 'IRIS_SERIES'), true)
        Loc = dat2dec(Loc,'centre');
        freq = getappdata(Ax, 'IRIS_FREQ');
        if ~isempty(freq) && isnumericscalar(freq) ...
                && any(freq == [0,1,2,4,6,12,52])
            dx = 0.5 / max(1,freq);
            switch opt.timeposition
                case 'before'
                    Loc = Loc - dx;
                case 'after'
                    Loc = Loc + dx;
            end
        end
    end
end

nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

if true % ##### MOSW
    % Matlab only
    %-------------
    infLim = 1e10;
    bounds = objbounds(Ax);
    zCoor = 0;
else
    % Octave only
    %-------------
    infLim = 1e5; %#ok<UNRCH>
    bounds = mosw.objbounds(Ax);
    zCoor = -1;
end

nLoc = numel(Loc);
for i = 1 : nLoc
    if isVertical
        xData = Loc([i,i]);
        yData = infLim*[-1,1] + bounds([3,4]);
    else
        xData = infLim*[-1,1] + bounds([1,2]);
        yData = Loc([i,i]);
    end
    zData = zCoor*ones(size(xData));
    h = line(xData,yData,zData,'color',[0,0,0], ...
        'yLimInclude','off','xLimInclude','off','parent',Ax);
    
    Ln = [Ln,h]; %#ok<AGROW>
    
    % Add annotation.
    if ~isempty(opt.caption) && isVertical
        c = grfun.mycaption(Ax,Loc(i), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,c]; %#ok<AGROW>
    end
    
    
    if true % ##### MOSW
        % Matlab only
        %-------------
        % Do nothing.
    else
        % Octave only
        %-------------
        % Order lines first among children so that they are effectively excluded
        % from legend. Plotting them between highligh areas and other objects is
        % guaranteed by their z-coordinates.
        ch = get(Ax,'children'); %#ok<UNRCH>
        if length(ch) > 1
            ch(ch == h) = [ ];
            ch = [h;ch];
            set(Ax,'children',ch);
        end
    end
end

% Reset `'nextPlot='` to its original value.
set(Ax,'nextPlot',nextPlot);

% Make sure zLim includes zCoor.
zLim = get(Ax,'zLim');
zLim(1) = min(zLim(1),zCoor);
zLim(2) = max(zLim(2),0);
set(Ax,'zLim',zLim);

if isempty(Ln)
    return
end

if ~isempty(lineOpt)  
    set(Ln,lineOpt{:});
end

% Tag the lines and captions for `qstyle`.
if isVertical
    set(Ln,'tag','vline');
    set(Cp,'tag','vline-caption');
    bkgLabel = 'VLine';
else
    set(Ln,'tag','hline');
    bkgLabel = 'HLine';
end

for i = 1 : numel(Ln)
    setappdata(Ln(i), 'IRIS_BACKGROUND', bkgLabel);
end

if true % ##### MOSW
    % Matlab only
    %-------------
    grfun.mymovetobkg(Ax);
else
    % Octave only
    %-------------
    % Do nothing.
end

if opt.excludefromlegend
    % Exclude the line object from legend.
    grfun.excludefromlegend(Ln);
end

end
