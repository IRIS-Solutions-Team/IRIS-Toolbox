function [answ, isValid, query] = implementGet(this, query, varargin)

TYPE = @int8;
answ = [ ];
isValid = true;
compare = @(x, y) any(strcmpi(x, y));

if strncmpi(query, 'Quantity.', 9) || strncmpi(query, 'Quantity:', 9)
    property = query(10:end);
    try
        answ = this.(property);
        return
    end
end

if compare(query, {'Name', 'List'})
    answ = this.Name;
    return

elseif compare(query, { ...
            'ylist', 'xlist', 'elist', 'plist', 'glist', ...
            'ydescript', 'xdescript', 'edescript', 'pdescript', 'gdescript', ...
            'yalias', 'xalias', 'ealias', 'palias', 'galias' ...
        })
    ixType = getType(query);
    prop = getProperty(query);
    answ = this.(prop)(ixType);
    return
        
elseif compare(query, 'Descript')
    answ = cell2struct(this.Label, this.Name, 2);
    return
        
elseif compare(query, 'Alias')
    answ = cell2struct(this.Alias, this.Name, 2);
    return

else
    isValid = false;

end

return


    function ixType = getType(query)
        switch upper(query(1))
            case 'Y'
                ixType = this.Type==TYPE(1);
            case 'X'
                ixType = this.Type==TYPE(2);
            case 'E'
                ixType = this.Type==TYPE(31) | this.Type==TYPE(32);
            case 'P'
                ixType = this.Type==TYPE(4);
            case 'G'
                ixType = this.Type==TYPE(5);
        end
    end


    function prop = getProperty(query) 
        switch upper( query(2:end) )
            case 'LIST'
                prop = 'Name';
            case 'DESCRIPT'
                prop = 'Label';
            case 'ALIAS'
                prop= 'Alias';
        end
    end
end

