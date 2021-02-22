function s = extractInput(s, kind)
% extractInput  Extract dynamic or steady part from input equation
%
% IRIS backed function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

inputClass = class(s);

if ~iscellstr(s)
    s = cellstr(s);
end

pos = strfind(s, '!!');
ixFor = find( ~cellfun(@isempty, pos) );
if strcmpi(kind, 'Dynamic')
    for i = ixFor
        s{i} = [s{i}(1:pos{i}-1), ';'];
        if s{i}(end)~=';'
            s{i}(end+1) = ';';
        end
    end
elseif strcmpi(kind, 'Steady')
    for i = ixFor
        s{i} = s{i}(pos{i}+2:end);
        if s{i}(end)~=';'
            s{i}(end+1) = ';';
        end
    end
else
    throw( exception.Base('General:Internal', 'error') );
end

if strcmpi(inputClass, 'char')
    s = char(s);
elseif strcmpi(inputClass, 'string')
    s = string(s);
end

end%

