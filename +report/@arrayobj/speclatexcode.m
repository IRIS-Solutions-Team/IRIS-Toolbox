function C = speclatexcode(This)
% speclatexcode  [Not a public function] Latex code for array objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
C = '';

% Test for hline.
isHLineFunc = @(Row) strncmp(Row{1,1},'-----',5) ...
    && all(cellfun(@isempty,Row(1,2:end)));

nCol = size(This.data,2);

% Start of tabular and tabular spec.
if isempty(This.options.colspec)
    colSpec = '';
    for iCol = 1 : nCol
        if any(cellfun(@isnumeric,This.data(:,iCol)))
            colSpec(end+1) = 'r'; %#ok<AGROW>
        else
            colSpec(end+1) = 'l'; %#ok<AGROW>
        end
    end
else
    colSpec = This.options.colspec;
end
if colSpec(1) == '{'
    colSpec(1) = '';
end
if colSpec(end) == '}'
    colSpec(end) = '';
end
This.options.colspec = colSpec;
This.ncol = nCol;
This.nlead = 0;

% Begin the tabular environment; `begin( )` is defined in `tabularobj`.
C = [C,begin(This)];

% The variable `colspec=` will be used to determine the position of the
% content within a makebox.
colSpec(colSpec == '|') = '';
C = [C, br, '\hline' , br ];

% User-supplied heading; it is the user's responsibility to make sure the
% heading is a valid LaTeX tabular row.
nHead = 0;
if ~isempty(This.options.heading)
    if iscell(This.options.heading)
        try
            This.data  = [ ...
                This.options.heading; ...
                This.data; ...
                ];
        catch %#ok<CTCH>
            utils.error('report', ...
                ['The size of a heading cell must be consistent ', ...
                'with the rest of the array data.']);
        end
        nHead = size(This.options.heading,1);
    else
        C = [C, br, This.options.heading];
        if This.options.long
            C = [C, br, '\endhead'];
        end
        nHead = 0;
    end
end

% Cycle over rows.
nRow = size(This.data,1);
for iRow = 1 : nRow
    cRow = '';
    % Test this row for \hline.
    if isHLineFunc(This.data(iRow,:))
        cRow = '\hline';
    else
        % If this is a regular row, cycle over columns and print cell by cell.
        for iCol = 1 : nCol
            doOneCell( );
        end
        cRow = [cRow,' \\']; %#ok<AGROW>
    end
    if This.options.long && iRow == nHead 
        cRow = [cRow, br, '\endhead']; %#ok<AGROW>
    end
    C = [C, br, cRow]; %#ok<AGROW>
end

% End the tabular environment; `finish( )` is defined in `tabularobj`.
C = [C, br, finish(This)];


% Nested functions...


%**************************************************************************
    function doOneCell( )
        c = '';
        iColW = This.options.colwidth(min(iCol,end));
        if ~isempty(This.data{iRow,iCol}) ...
                && isnumeric(This.data{iRow,iCol})
            c = report.arrayobj.sprintf( ...
                This.data{iRow,iCol}, ...
                This.options.format, ...
                This.options);
        elseif ischar(This.data{iRow,iCol})
            c = interpret(This,This.data{iRow,iCol});
        end
        c = report.matrixobj.makebox(...
            c,'',iColW,colSpec(iCol),'');
        cRow = [cRow,c];
        if iCol < nCol
            cRow = [cRow,' & '];
        end
    end % doOneCell( )


end
