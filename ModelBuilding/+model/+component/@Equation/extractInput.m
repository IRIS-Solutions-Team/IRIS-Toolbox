function s = extractInput(s, kind)

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

end
