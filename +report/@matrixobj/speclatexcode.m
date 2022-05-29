function C = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for matrix objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

This.nlead = double(anyrowname(This));
% Start of tabular and tabular spec.
if isempty(This.options.colspec)
    This.options.colspec = colspec(This);
end

C = [C,begin(This)];

C = [C, br, '\hline', br ];
% User-supplied heading.
if ~isempty(This.options.heading)
    C = [C, br, This.options.heading];
end

% Print column names.
if anycolname(This)
    c1 = '';
    for iRow = 1 : This.ncol
        if iRow > 1
            c1 = [c1,' & ']; %#ok<AGROW>
        end
        c2 = interpret(This,This.options.colnames{iRow});
        if ~isequal(This.options.rotatecolnames,false)
            c1 = [c1, ...
                report.tabularobj.turnbox(c2, ...
                This.options.rotatecolnames)]; %#ok<AGROW>
            This.hInfo.package.rotating = true;
        else
            c1 = [c1,c2]; %#ok<AGROW>
        end
    end
    if This.nlead == 1
        c1 = [' & ',c1];
    end
    C = [C,c1,' \\', br, '\hline', br ];
end

% Cycle over the matrix rows.
for iRow = 1 : This.nrow
    if This.nlead == 1
        C = [C, br, '{',...
            interpret(This,This.options.rownames{iRow}),...
            '}']; %#ok<AGROW>
    end
    % Cycle over the matrix columns.
    c1 = cell(1,This.ncol);
    for iCol = 1 : This.ncol
        a = struct( );
        doAttributes( );
        iColW = This.options.colwidth(min(iCol,end));
        c1{iCol} = testnformat(This,a,iColW,'r','');
    end
    for iCol = 1 : This.ncol
        if This.nlead == 1 || iCol > 1
            C = [C,' & ']; %#ok<AGROW>
        end
        C = [C,c1{iCol}]; %#ok<AGROW>
    end
    C = [C,' \\']; %#ok<AGROW>
end

% Finish all environments.
C = [C, br, finish(This)];


% Nested functions...


%**************************************************************************
    function doAttributes( )
        % doattributes  Prepare an attribute struct for cond formatting.
        a.value = This.data(iRow,iCol);
        a.rowvalues = This.data(iRow,:);
        a.colvalues = This.data(:,iCol);
        a.allvalues = This.data;
        a.rowname = This.options.rownames{iRow};
        a.colname = This.options.colnames{iCol};
        a.row = iRow;
        a.col = iCol;
    end % doAttributes( )


end
