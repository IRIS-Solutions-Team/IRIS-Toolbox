function X = subsref(This,varargin)
% subsref  [Not a public function] Subscripted reference for namedmat objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

s = varargin{1};
isPreserved = strcmp(s(1).type,'()') && length(s(1).subs) >= 2;

if strcmp(s(1).type,'()')
    
    % Convert char or cellstr row references to positions.
    if (ischar(s(1).subs{1}) || iscellstr(s(1).subs{1})) ...
            && ~isequal(s(1).subs{1},':')
        if ischar(s(1).subs{1})
            usrName = regexp(s(1).subs{1},'\w+','match');
        end
        nUsrName = length(usrName);
        validRowName = true(1,nUsrName);
        rowPos = zeros(1,0);
        for i = 1 : nUsrName
            pos = strcmp(usrName{i},This.rownames);
            if any(pos)
                rowPos = [rowPos,find(pos)]; %#ok<AGROW>
            else
                validRowName(i) = false;
            end
        end
        if any(~validRowName)
            utils.error('namedmat:subsref', ...
                ['This is not a valid row name ', ...
                'in the namedmat object: ''%s''.'], ...
                usrName{~validRowName});
        end
        s(1).subs{1} = rowPos;
    end
    
    % Convert char or cellstr col references to positions.
    if length(s(1).subs) > 1 ...
            && (ischar(s(1).subs{2}) || iscellstr(s(1).subs{2})) ...
            && ~isequal(s(1).subs{2},':')
        if ischar(s(1).subs{2})
            usrName = regexp(s(1).subs{2},'\w+','match');
        end
        nUsrName = length(usrName);
        validColName = true(1,nUsrName);
        colPos = zeros(1,0);
        for i = 1 : nUsrName
            pos = strcmp(usrName{i},This.colnames);
            if any(pos)
                colPos = [colPos,find(pos)]; %#ok<AGROW>
            else
                validColName(i) = false;
            end
        end
        if any(~validColName)
            utils.error('namedmat:subsref', ...
                ['This is not a valid column name ', ...
                'in the namedmat object: ''%s''.'], ...
                usrName{~validColName});
        end
        s(1).subs{2} = colPos;
    end
end

if isPreserved
    rowNames = This.rownames;
    colNames = This.colnames;
    s1 = s(1);
    s1.subs = s1.subs(1);
    rowNames = subsref(rowNames,s1);
    s2 = s(1);
    s2.subs = s2.subs(2);
    colNames = subsref(colNames,s2);
end

X = double(This);
X = subsref(X,s,varargin{2:end});

if isPreserved
    X = namedmat(X,rowNames,colNames);
end

end
