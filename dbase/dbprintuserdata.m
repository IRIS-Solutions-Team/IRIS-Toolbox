function dbprintuserdata(D,Field,varargin)
% dbprintuserdata  Print names of database tseries along with specified fields of their userdata.
%
% Syntax
% =======
%
%     dbprintuserdata(D,Fields,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database whose tseries objects will be reported.
%
% * `Fields` [ char | cellstr ] - Names of the userdata fields whose
% content will printed (if char or numeric scalar).
%
% Options
% ========
%
% * `'output='` [ `'html'` | *`'prompt'`* ] - Where to display the
% information.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

if ischar(Field)
    Field = {Field};
end

opt = passvalopt('dbase.dbprintuserdata',varargin{:});
isHtml = strcmpi(opt.output,'html');

%--------------------------------------------------------------------------

list = fieldnames(D);
n = max(cellfun(@length,list));
html = '';

for i = 1 : length(list)
    name = list{i};
    doPrint('\t%*s',n,name);
    u = userdata(D.(name));
    if isempty(Field)
        doPrint('\n');
        continue
    end
    for j = 1 : length(Field)
        field = Field{j};        
        try
            if field(1) == '.'
                field(1) = '';
            end
            value = u.(field);
        catch %#ok<CTCH>
            value = { };
        end
        if ischar(value)
            value = regexprep(value,':\s*',': ');
            value = regexprep(value,';\s*','; ');
            value = regexprep(value,',\s*',', ');
            value = strtrim(value);
            value = sprintf('"%s"',value);
        elseif isnumericscalar(value)
            value = sprintf('%g',value); %#ok<PFCEL>
        else
            value = '???';
        end
        if j > 1
            doPrint('\t%*s',n,' ');
        end
        doPrint('  .%s = %s',field,value);
        doPrint('\n');
    end
end

if isHtml
    dbName = inputname(1);
    html = ['<html><head><title>', ...
        dbName,' ',datestr(now( )), ...
        '</title></head>',...'
        '<body><pre>',dbName,'</pre><pre>',html,'</pre></body></html>.'];
    [~,h] = web('-new');
    h.setHtmlText(html);
end

% Nested functions.

%**************************************************************************
    function doPrint(varargin)
        if isHtml
            html = [html,sprintf(varargin{:})];
        else
            fprintf(varargin{:});
        end
    end % doPrint( ).

end