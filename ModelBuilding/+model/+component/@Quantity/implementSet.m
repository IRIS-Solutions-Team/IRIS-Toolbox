function [this, isValidRequest, isValidValue] = implementSet(this, query, value, varargin)

TYPE = @int8;
isValidRequest = true;
isValidValue = true;
numQuantities = length(this.Name);
compare = @(x, y) any(strcmpi(x, y));

if strncmpi(query, 'descript', 8) || strcmpi(query, 'alias')
    if lower(query(1))=='d'
        prop = 'Label';
    else
        prop = 'Alias';
    end
    if isstruct(value)
        for i = 1 : numQuantities
            name = this.Name{i};
            if isfield(value, name) && ischar(value.(name))
                this.(prop){i} = value.(name);
            end
        end
    else
        isValidValue = false;
    end
                

elseif compare(query, ...
    {'ydescript','xdescript','edescript','pdescript','gdescript', ...
    'yalias','xalias','ealias','palias','galias'})
    if lower(query(2))=='d'
        prop = 'Label';
    else
        prop = 'Alias';
    end
    switch lower(query(1))
        case 'y'
            ixType = this.Type==TYPE(1);
        case 'x'
            ixType = this.Type==TYPE(2);
        case 'e'
            ixType = this.Type==TYPE(31) | this.Type==TYPE(32);
        case 'p'
            ixType = this.Type==TYPE(4);
        case 'g'
            ixType = this.Type==TYPE(5);
    end
    if iscellstr(value) && length(value)==sum(ixType)
        this.(prop)(ixType) = value;
    else
        isValidValue = false;
    end
        
else
    isValidRequest = false;
end

end
