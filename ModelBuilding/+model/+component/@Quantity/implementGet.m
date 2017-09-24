function [answ, isValid, query] = implementGet(this, query, varargin)

TYPE = @int8;
answ = [ ];
isValid = true;

switch lower(query)
    case {'name', 'list'}
        answ = this.Name;
        
    case {'quantity:name'}
        answ = this.Name;
        
    case {'quantity:type'}
        answ = this.Type;
        
    case { 'ylist', 'xlist', 'elist', 'plist', 'glist', ...
            'ydescript', 'xdescript', 'edescript', 'pdescript', 'gdescript', ...
            'yalias', 'xalias', 'ealias', 'palias', 'galias' }
        ixType = getType(query);
        prop = getProperty(query);
        answ = this.(prop)(ixType);
        
    case {'quantity:label', 'descript'}
        answ = cell2struct(this.Label, this.Name, 2);
        
    case {'quantity:alias', 'alias'}
        answ = cell2struct(this.Alias, this.Name, 2);
        
    otherwise
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

