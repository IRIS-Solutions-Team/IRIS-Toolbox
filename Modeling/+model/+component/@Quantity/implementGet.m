function [answ, isValid, query] = implementGet(this, query, varargin)

TYPE = @int8;
answ = [ ];
isValid = true;
compare = @(x, y) any(strcmpi(x, y));

query1 = lower(query);
query1 = strrep(query1, 'list', 'names');
query1 = strrep(query1, 'descriptions', 'descript');
query1 = strrep(query1, 'description', 'descript');
query1 = strrep(query1, 'aliases', 'alias');

if strncmpi(query1, 'Quantity.', 9) || strncmpi(query1, 'Quantity:', 9)
    property = query1(10:end);
    try
        answ = this.(property);
        return
    end
end

if compare(query1, {'Names', 'AllNames'})
    answ = this.Name;
    return

elseif compare(query1, { ...
            'ynames', 'xnames', 'enames', 'pnames', 'gnames', ...
            'ydescript', 'xdescript', 'edescript', 'pdescript', 'gdescript', ...
            'yalias', 'xalias', 'ealias', 'palias', 'galias' ...
        })
    ixType = getType(query1);
    prop = getProperty(query1);
    answ = this.(prop)(ixType);
    return
        
elseif compare(query1, {'Descript', 'Desc', 'Description', 'Descriptions'})
    answ = cell2struct(this.Label, this.Name, 2);
    return
        
elseif compare(query1, 'Alias')
    answ = cell2struct(this.Alias, this.Name, 2);
    return

elseif compare(query1, 'CanBeExogenized:Simulate')
    answ = this.Type==TYPE(1) | this.Type==TYPE(2);
    return

elseif compare(query1, 'CanBeEndogenized:Simulate')
    answ = this.Type==TYPE(31) | this.Type==TYPE(32);
    return

else
    isValid = false;

end

return


    function ixType = getType(query1)
        if strcmpi(query1(1), 'y')
            ixType = this.Type==TYPE(1);
        elseif strcmpi(query1(1), 'x')
            ixType = this.Type==TYPE(2);
        elseif strcmpi(query1(1), 'e') 
            ixType = this.Type==TYPE(31) | this.Type==TYPE(32);
        elseif strcmpi(query1(1), 'p')
            ixType = this.Type==TYPE(4);
        elseif strcmpi(query1(1), 'g')
            ixType = this.Type==TYPE(5);
        end
    end%


    function prop = getProperty(query1) 
        if compare(query1(2:end), {'List', 'Name', 'Names'})
            prop = 'Name';
        elseif compare(query1(2:end), {'Descript', 'Description', 'Descriptions'})
            prop = 'Label';
        elseif compare(query1(2:end), {'Alias', 'Aliases'})
            prop = 'Alias';
        end
    end%
end%

