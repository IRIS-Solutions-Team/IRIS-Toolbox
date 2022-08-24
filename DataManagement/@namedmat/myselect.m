function [X, Pos] = myselect(X, rowNames, colNames, varargin)

rowSelection = varargin{1};
varargin(1) = [ ];

isColSelect = ~isempty(varargin);
if isColSelect
    colSelection = varargin{1};
    varargin(1) = [ ]; %#ok<NASGU>
else
    colSelection = rowSelection;
end

if ischar(rowSelection)
    rowSelection = regexp(rowSelection, '[\w\{\}\(\)\+\-]+', 'match');
end
rowSelection = string(rowSelection);

if ischar(colSelection)
    colSelection = regexp(colSelection, '[\w\{\}\(\)\+\-]+', 'match');
end
colSelection = string(colSelection);

usrRowSelect = rowSelection;
usrColSelect = colSelection;

%--------------------------------------------------------------------------

rowSelection = reshape(rowSelection, 1, [ ]);
colSelection = reshape(colSelection, 1, [ ]);
rowNames = reshape(rowNames, 1, [ ]);
colNames = reshape(colNames, 1, [ ]);

rowSelection = locallyRemoveLog(rowSelection);
colSelection = locallyRemoveLog(colSelection);
rowNames = locallyRemoveLog(rowNames);
colNames = locallyRemoveLog(colNames);


rowPos = nan(size(rowSelection));
colPos = nan(size(colSelection));

% Match row and columns selections against row and columns names.
for i = 1 : length(rowSelection)
    pos = find(strcmp(rowNames, rowSelection(i)), 1);
    if ~isempty(pos)
        rowPos(i) = pos;
    end
end
for i = 1 : length(colSelection)
    pos = find(strcmp(colNames, colSelection(i)), 1);
    if ~isempty(pos)
        colPos(i) = pos;
    end
end

% Check for not-found positions.
ixNanRow = isnan(rowPos);
ixNanCol = isnan(colPos);
checkNotFound( );
rowPos(ixNanRow) = [ ];
colPos(ixNanCol) = [ ];
nRowSel = length(rowPos);
nColSel = length(colPos);

X = double(X);
s = size(X);
X = X(:, :, :);
X = X(rowPos, colPos, :);
if length(s) > 2
    X = reshape(X, [nRowSel, nColSel, s(3:end)]);
end
Pos = {rowPos, colPos};

return


    function checkNotFound( )
        msg = { };
        if isColSelect
            % Row and column selections entered separately.
            if ~any(ixNanRow) && ~any(ixNanCol)
                return
            end
            for ii = find(ixNanRow)
                msg{end+1} = 'row'; %#ok<AGROW>
                msg{end+1} = usrRowSelect{ii}; %#ok<AGROW>
            end
            for ii = find(ixNanCol)
                msg{end+1} = 'column'; %#ok<AGROW>
                msg{end+1} = usrColSelect{ii}; %#ok<AGROW>
            end
        else
            % Row and column selections entered as one list.
            ixNan = ixNanRow & ixNanCol;
            if ~any(ixNan)
                return
            end
            for ii = find(ixNan)
                msg{end+1} = 'row or column'; %#ok<AGROW>
                msg{end+1} = usrRowSelect{ii}; %#ok<AGROW>
            end
        end
        utils.error('namedmat:myselect', ...
            'This is not a valid %s name: ''%s''.', ...
            msg{:});
    end 
end%


function c = locallyRemoveLog(c)
    c = strtrim(c);
    c = regexprep(c, '^log\((.*?)\)$', '$1', 'once');
    c = regexprep(c, '^log_(.*?)$', '$1', 'once');
end%

