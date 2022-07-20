function C = any2str(X,Prec)
% any2str  [Not a public function] Convert various types of complex data into a Matlab syntax string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

try
    Prec; %#ok<VUNUS>
catch
    Prec = 15;
end

%--------------------------------------------------------------------------

if isnumeric(X) || ischar(X) || islogical(X)
    C = xxNumeric(X,Prec);
elseif iscell(X)
    C = xxCell(X,Prec);
elseif isstruct(X)
    C = xxStruct(X,Prec);
elseif isa(X, 'function_handle')
    C = char(X) ;
else
    utils.error('utils', ...
        'ANY2STR cannot currently handle this type of data: %s.', ...
        class(X));
end    

end


% Subfuntions...


%**************************************************************************


function C = xxNumeric(X,Prec)
nd = ndims(X);
if nd == 2
    C = mat2str(X,Prec);
else
    ref = cell(1,nd);
    ref(1:nd-1) = {':'};
    C = sprintf('cat(%g',nd);
    for i = 1 : size(X,nd)
        ref{nd} = i;
        C = [C,',',xxNumeric(X(ref{:}),Prec)];
    end
    C = [C,')'];
end
end % xxNumeric( )


%**************************************************************************


function C = xxCell(X,Prec)
if isempty(X)
  s = size(X);
  C = ['cell(',sprintf('%g',s(1)),sprintf(',%g',s(2:end)),')'];
  return
end
nd = ndims(X);
if nd == 2
    C = xxCell2D(X,Prec);
else
    ref = cell(1,nd);
    ref(1:nd-1) = {':'};
    C = sprintf('cat(%g',nd);
    for i = 1 : size(X,nd)
        ref{nd} = i;
        C = [C,',{',xxNumeric(X{ref{:}},Prec),'}'];
    end
    C = [C,')'];
end
end % xxCell( )


%**************************************************************************


function C = xxCell2D(X,Prec)
[nRow,nCol] = size(X);
C = '{';
for i = 1 : nRow
    for j = 1 : nCol
        if j > 1
            C = [C,','];
        end
        C = [C,utils.any2str(X{i,j},Prec)]; %#ok<*AGROW>
    end
    if i < nRow
        C = [C,';'];
    end
end
C = [C,'}'];
end % xxCell2D( )


%**************************************************************************


function C = xxStruct(X,Prec)
len = length(X);
if len ~= 1
    utils.error('utils', ...
        'ANY2STR cannot currently handle struct arrays.');
end
    
list = fieldnames(X);
C = 'struct(';
for i = 1 : length(list)
    c1 = utils.any2str(X.(list{i}),Prec);
    if iscell(X.(list{i}))
        c1 = ['{',c1,'}'];
    end
    if i > 1
        C = [C,','];
    end
    C = [C,'''',list{i},''',',c1];
end
C = [C,')'];
end % xxStruct( )
