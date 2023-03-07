%{
% 
% # `databank.list` ^^(+databank)^^
% 
% {== List databank fields adding date range to time series fields ==}
% 
% 
% ## Syntax
% 
%     databank.list(db)
% 
% 
% ## Input Arguments
% 
% __`db`__ [ struct | Dictionary ]
% > 
% > Databank whose fields will be listed on the screen, with information on
% > date ranges added to time series fields.
% > 
% 
% ## Description
% 
% 
% ## Example
% 
% ```matlab
% d = struct();
% d.a = 1;
% d.b = Series(qq(2020,1), rand(20, 1));
% d.c = Series(yy(2020), rand(10, 1));
% d.d = "abcd";
% databank.list(d)
% ```
% 
%}
% --8<--


function list(inputDatabank, keyFilter, valueFilter)

if nargin<2
    keyFilter = [ ];
elseif validate.string(keyFilter)
    keyFilter = @(x) contains(x, keyFilter);
end

if nargin<3
    valueFilter = [ ];
elseif validate.string(valueFilter)
    valueFilter = @(x) isa(x, valueFilter);
end

if isa(inputDatabank, 'Dictionary')
    allNames = keys(inputDatabank);
    allValues = values(inputDatabank);
else
    allNames = string(fieldnames(inputDatabank));
    allValues = struct2cell(inputDatabank);
end
allNames = reshape(allNames, [ ], 1);

dispIndent = iris.get('DispIndent');
dispNames = dispIndent + allNames + ": ";

count = numel(allNames);
info = cell(count, 1);
inxKeep = true(count, 1);

for i = 1 : count
    if isa(keyFilter, 'function_handle')
        try
            pass = keyFilter(allNames(i));
        catch
            pass = false;
        end
        if ~isequal(pass, true)
            inxKeep(i) = false;
            continue
        end
    end
    ithValue = allValues{i};
    if isa(valueFilter, 'function_handle')
        try
            pass = valueFilter(ithValue);
        catch
            pass = false;
        end
        if ~isequal(pass, true)
            inxKeep(i) = false;
            continue
        end
    end
    n = numel(ithValue);
    numelTestPassed = n>=1 && n<=10;
    if isa(ithValue, 'DateWrapper') && isscalar(ithValue)
        info{i} = " " + dater.toDefaultString(ithValue);
        info{i} = char(info{i});
    elseif ~isa(ithValue, 'DateWrapper') && isnumeric(ithValue) && isrow(ithValue) && numelTestPassed
        info{i} = sprintf(' %g', ithValue);
        if n>1
            info{i}(1) = '';
            info{i} = [' [', info{i}, ']'];
        end
    elseif islogical(ithValue) && isrow(ithValue) && numelTestPassed
        info{i} = sprintf(' %g', ithValue);
        if n>1
            info{i}(1) = '';
            info{i} = [' [', info{i}, ']'];
            info{i} = strrep(info{i}, '1', 'true');
            info{i} = strrep(info{i}, '0', 'false');
        end
    elseif ischar(ithValue) && isrow(ithValue) && n<=50
        info{i} = sprintf(' ''%s''', ithValue);
    elseif isa(ithValue, 'string') && isscalar(ithValue) && strlength(ithValue)<=50
        info{i} = sprintf(' "%s"', ithValue);
    else
        ithClass = class(ithValue);
        if isa(ithValue, 'Series') ...
           && ~isempty(ithValue)
            ithClass = sprintf( '%s %s:%s', ...
                                ithClass, ...
                                dater.toDefaultString(ithValue.Start), ...
                                dater.toDefaultString(ithValue.End) );
        end
        ithSize = size( ithValue );
        ithSizeString = sprintf( '%gx', ithSize );
        ithSizeString = [' [', ithSizeString(1:end-1)];
        info{i} = [ithSizeString, ' ', ithClass, ']'];
    end
end

if any(inxKeep)
    keysAsChar = strjust(char(dispNames(inxKeep)));
    infoAsChar = char(info(inxKeep));
    listAsChar = strcat(keysAsChar, infoAsChar);
    textual.looseLine( );
    disp(listAsChar);
end

textual.looseLine( );

end%

