function plot(this, ax)
% plot  Draw report/graph object
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

if isempty(this.children)
    return
end

% Clear the axes object.
cla(ax);

% Run user-supplied style pre-processor on the axes object.
if ~isempty(this.options.preprocess)
    grfun.mystyleprocessor(ax, this.options.preprocess);
end

% Array of legend entries.
legEnt = cell(1, 0);

nChild = length(this.children);

lhsInx = false(1, nChild);
rhsInx = false(1, nChild);
annotateInx = false(1, nChild);
isLhsOrRhsOrAnnotate( );
isRhs = any(rhsInx);

if isRhs
    % Plot functions `@plotyy`, `@plotcmp`, `@barcon` not allowed.
    chkPlotFunc( );
    % Legend location cannot be `best` in LHS-RHS plots. This is a Matlab
    % issue.
    getLegendLocation( );
    % Create an axes object for the RHS plots.
    openRhsAxes( );
end

if isequal(this.options.grid, @auto)
    this.options.grid = ~isRhs;
end

if isequal(this.options.tight, @auto)
    this.options.tight = ~isRhs;
end

hold(ax(1), 'all');
if isRhs
    hold(ax(end), 'all');
end

legEnt = cell(1, nChild);
ixLegLhs = true(1, nChild);
doPlot( );

if this.options.grid
    grid(ax(end), 'on');
end

if ~isequal(this.options.zeroline, false)
    zerolineOpt = { };
    if iscell(this.options.zeroline)
        zerolineOpt = this.options.zeroline;
    end
    grfun.zeroline(ax(end), zerolineOpt{:});
end

% Make the y-axis tight if requested by the user. Only after that the vline
% children can be plotted.
if this.options.tight
    visual.backend.setAxesTight(ax(end));
end

% Add title and subtitle (must be done before the legend).
titleCell = {this.title, this.subtitle};
ixEmpty = cellfun(@isempty, titleCell);
titleCell(ixEmpty) = [ ];
if ~isempty(titleCell)
    ti = title(titleCell, 'interpreter', 'none');
    if ~isempty(this.options.titleoptions)
        set(ti, this.options.titleoptions{:});
    end
end

% Add legend.
lg = [ ];
if isequal(this.options.legend, true) ...
        || (isnumeric(this.options.legend) && ~isempty(this.options.legend))
    if isnumeric(this.options.legend) && ~isempty(this.options.legend)
        % Select only the legend entries specified by the user.
        legEnt = legEnt(this.options.legend);
    end
    legEntLhs = [ legEnt{ixLegLhs} ];
    % legEntRhs = [ legEnt{~ixLegLhs} ]; %#ok<NASGU>
    while ~isempty(legEntLhs) && iscell(legEntLhs) && ~iscellstr(legEntLhs)
        legEntLhs = legEntLhs{1};
    end
    % TODO: Create legend for RHS data.
    if ~isempty(legEnt) && ~all(cellfun(@isempty, legEnt))
        if strcmp(this.options.legendlocation, 'bottom')
            lg = grfun.bottomlegend(ax(1), legEntLhs{:});
        else
            lg = legend(ax(1), legEntLhs{:}, 'location', this.options.legendlocation);
            if ~isempty(this.options.legendoptions)
                set(lg, this.options.legendoptions{:});
            end
        end
    end
end

if isRhs
    grfun.swaplhsrhs(ax(1), ax(2));
end

% Plot highlight and vline. These are excluded from legend.
for i = find(annotateInx)
    plot(this.children{i}, ax(1));
end

% Annotate axes.
if ~isempty(this.options.xlabel)
    xlabel(ax(1), this.options.xlabel);
end
if ~isempty(this.options.ylabel)
    ylabel(ax(1), this.options.ylabel);
end
if ~isempty(this.options.zlabel)
    zlabel(ax(1), this.options.zlabel);
end

if ~isempty(this.options.style)
    % Apply styles to the axes object and its children.
    grfun.style(this.options.style, ax, 'warning', false);
    if ~isempty(lg)
        % Apply styles to the legend axes.
        grfun.style(this.options.style, lg, 'warning', false);
    end
end

% Run user-supplied axes options.
if ~isempty(this.options.axesoptions)
    set(ax(1), this.options.axesoptions{:});
    if isRhs
        set(ax(end), this.options.axesoptions{:});
        set(ax(end), this.options.rhsaxesoptions{:});
    end
end

% Run user-supplied style post-processor.
if ~isempty(this.options.postprocess)
    grfun.mystyleprocessor(ax, this.options.postprocess);
end

return


    function openRhsAxes( )
        ax = plotyy(ax, NaN, NaN, NaN, NaN);
        delete(get(ax(1), 'children'));
        delete(get(ax(2), 'children'));
        set(ax, ...
            'box', 'off', ...
            'YColor', get(ax(1), 'XColor'), ...
            'XLimMode', 'auto', 'XTickMode', 'auto', ...
            'YLimMode', 'auto', 'YTickMode', 'auto');
        ax(1).XRuler.Visible = 'on';
        ax(2).XRuler.Visible = 'on';
        set(ax(2), 'ColorOrder', get(ax(1), 'ColorOrder'));
        set(ax, 'ColorOrderIndex', 1);
    end


    function doPlot( )
        for ii = 1 : nChild
            if lhsInx(ii)
                % Plot on the LHS
                legEnt{ii} = plot(this.children{ii}, ax(1));
            elseif rhsInx(ii)
                % Plot on the RHS
                legEnt{ii} = plot(this.children{ii}, ax(2));
                ixLegLhs(ii) = false;
            end
            if isRhs
                % In graphs with LHS and RHS axes, keep the color order index the same in
                % Ax(1) and Ax(2) at all times.
                cix = get(ax, 'ColorOrderIndex');
                cix = max([cix{:}]);
                set(ax, 'ColorOrderIndex', cix);
            end
        end
    end


    function isLhsOrRhsOrAnnotate( )
        for ii = 1 : nChild
            ch = this.children{ii};
            if isfield(ch.options, 'yaxis')
                if strcmpi(ch.options.yaxis, 'right')
                    rhsInx(ii) = true;
                else
                    lhsInx(ii) = true;
                end
            else
                annotateInx(ii) = true;
            end
        end
        
    end


    function chkPlotFunc( )
        invalid = { };
        for ii = find(lhsInx | rhsInx)
            ch = this.children{ii};
            plotFunc = ch.options.plotfunc;
            if ~( ...
                    isequal(plotFunc, @plot) ...
                    || isequal(plotFunc, @bar) ...
                    || isequal(plotFunc, @stem) ...
                    || isequal(plotFunc, @area) ...
                )
                invalid{end+1} = func2str(ch.options.plotfunc); %#ok<AGROW>
            end
        end
        if ~isempty(invalid)
            utils.error('graphobj:plot', ...
                ['This plot function is not allowed in graphs ', ...
                'with LHS and RHS axes: %s.'], ...
                invalid{:});
        end
    end


    function getLegendLocation( )
        if strcmpi(this.options.legendlocation, 'best')
            this.options.legendlocation = 'South';
            utils.warning('graphobj:plot', ...
                ['Legend location cannot be ''Best'' in LHS-RHS graphs. ', ...
                '(This is a Matlab issue.) Setting the location to ''South''.']);
        end
    end
end
