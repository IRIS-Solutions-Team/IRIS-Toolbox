% extractInput  Extract dynamic or steady part from input equation
%
% -[IrisToolbox] Macroeconomic Modeling Toolboxl
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function s = extractInput(s, equationSwitch)

inputClass = string(class(s));

if ~iscellstr(s)
    s = cellstr(s);
end

pos = strfind(s, '!!');
ixFor = find( ~cellfun(@isempty, pos) );
if lower(string(equationSwitch))=="dynamic"
    for i = ixFor
        s{i} = [s{i}(1:pos{i}-1), ';'];
        if s{i}(end)~=';'
            s{i}(end+1) = ';';
        end
    end
elseif lower(string(equationSwitch))=="steady"
    for i = ixFor
        s{i} = s{i}(pos{i}+2:end);
        if s{i}(end)~=';'
            s{i}(end+1) = ';';
        end
    end
else
    throw( exception.Base('General:Internal', 'error') );
end

if inputClass=="char"
    s = char(s);
elseif inputClass=="string"
    s = string(s);
end

end%

