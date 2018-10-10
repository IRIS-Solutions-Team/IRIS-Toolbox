function rpt = parse(rpt)

x10 = sprintf('\n'); %#ok<SPRINTFN>
x13 = sprintf('\r');
rpt = strrep(rpt, [x10, x13], x10);
rpt = strrep(rpt, [x13, x10], x10);
rpt = strrep(rpt, x13, x10);
rpt = [rpt, x10];

rpt = regexprep( rpt, '^[ ]+', '', 'lineanchors' );
rpt = regexprep( rpt, '\n\n', '\n' );
rpt = regexprep( rpt, '%%%[^\n]*', '');
rpt = regexprep( rpt, '%#[^\n]*\n', '', 'lineanchors' );
rpt = [rpt, x10];

stripCaptionFunc = @stripCaption;
stripExpressionFunc = @stripExpression;
resolveOptionsFunc = @resolveOptions;

% Report
rpt = regexprep( rpt, ...
                 '^%% \*\*([^\n]*)\*\*[ ]*(#[^\n]*)?\n', ...
                 '\n%# $0reptile___.Report = reptile.Report([ ], ''${stripCaptionFunc($1)}'' ${resolveOptionsFunc($2)});\n', ...
                 'lineanchors' );
             

% Figure %% Summary
rpt = regexprep( rpt, ...
                 '^%% ([^\n#]*)[ ]*(#[^\n]*)?\n', ...
                 '\n%# $0reptile___.Figure = reptile.Figure(reptile___.Report, ''${stripCaptionFunc($1)}'' ${resolveOptionsFunc($2)} );\n', ...
                 'lineanchors' );
             

% Axes % Inflation
rpt = regexprep( rpt, ...
                 '^% ([^\*#\n][^\n#]*)[ ]*(#[^\n]*)?\n', ...
                 '\n%# $0    reptile___.Axes = reptile.Axes(reptile___.Figure, ''${stripCaptionFunc($1)}'' ${resolveOptionsFunc($2)} );\n', ...
                 'lineanchors' );
             

% Empty Series {  }
rpt = regexprep( rpt, ...
                 '^\{[ ]*\}[^\n]*\n', ...
                 '\n%# $0        reptile___.Series = reptile.EmptySeries(reptile___.Axes);\n', ...
                 'lineanchors' );
             

% Series { "Label" x*y }
rpt = regexprep( rpt, ...
                 '^\{[ ]*("[^"\n]*")?([^\}\n]*)\}[ ]*(#[^\n]*)?\n', ...
                 '\n%# $0        reptile___.Series = reptile.Series(reptile___.Axes, ''${stripCaptionFunc($1)}'', ''${stripExpressionFunc($2)}'' ${resolveOptionsFunc($3)} );\n', ...
                 'lineanchors' );
             

% Subplot [3, 3]
rpt = regexprep( rpt, ...
                 '^\[[ ]*(\d+)[ ]*,[ ]*(\d+)[ ]*\][^\n]*', ...
                 '\n%# $0\nreptile___.Figure.Options.Subplot = [$1, $2];', ...
                 'lineanchors' );
                 
rpt = regexprep( rpt, '^[ ]*\.+[ ]*\n', '', 'lineanchors' );
             
end%




function c = stripCaption(c)
    c = strip(c);
    c = strip(c, '"');
    c = strip(c);
end%


function c = stripExpression(c)
    c = strip(c);
    c = strip(c, ',');
    c = strip(c);
end%


function c = resolveOptions(c)
    tokens = regexp(c, '#(\w+)[ ]*=[ ]*([^#]*)', 'tokens');
    c = '';
    if isempty(tokens)
        return
    end
    for i = 1 : numel(tokens)
        c = [c, ','];
        tokens{i}{2} = stripExpression(tokens{i}{2});
        c = [c, sprintf(' ''%s='', %s', tokens{i}{1}, tokens{i}{2})];
    end
end%

