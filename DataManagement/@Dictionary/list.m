function list(this, keyFilter, valueFilter)
% list  Display list of keys with size and class descriptions of values

%--------------------------------------------------------------------------

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

dispIndent = iris.get('DispIndent');
keys = this.Keys(:);
keys = dispIndent + keys + ": ";

count = numel(this.Keys);
info = cell(count, 1);
inxKeep = true(count, 1);

for i = 1 : count
    if isa(keyFilter, 'function_handle')
        try
            pass = keyFilter(this.Keys{i});
        catch
            pass = false;
        end
        if ~isequal(pass, true)
            inxKeep(i) = false;
            continue
        end
    end
    ithValue = this.Values{i};
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
    if isnumeric(ithValue) && isrow(ithValue) && numelTestPassed
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
    keysAsChar = strjust(char(keys(inxKeep)));
    infoAsChar = char(info(inxKeep));
    listAsChar = strcat(keysAsChar, infoAsChar);
    textual.looseLine( );
    disp(listAsChar);
end

textual.looseLine( );

end%

