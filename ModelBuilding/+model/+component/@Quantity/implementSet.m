function [this, isValidRequest, isValidValue] = implementSet(this, request, value, varargin)

TYPE = @int8;
isValidRequest = true;
isValidValue = true;

switch request
    case {'descript', 'alias'}
        if strcmp(query, 'descript')
            prop = 'Label';
        else
            prop = 'Alias';
        end
        if isstruct(value)
            nQuan = length(this.Name);
            for i = 1 : nQuan
                name = this.Name{i};
                if isfield(value, name) && ischar(value.(name))
                    this.(prop){i} = value.(name);
                end
            end
        else
            isValidValue = false;
        end
                
    case {'ydescript','xdescript','edescript','pdescript','gdescript', ...}
            'yalias','xalias','ealias','palias','galias'}
        if ~isempty(strfind(query,'descript'))
            prop = 'Label';
        else
            prop = 'Alias';
        end
        switch query(1)
            case 'y'
                ixType = this.Type==TYPE(1);
            case 'x'
                ixType = this.Type==TYPE(2);
            case 'e'
                ixType = this.Type==TYPE(31) ...
                    | this.Type==TYPE(32);
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
        
    otherwise
        isValidRequest = false;
end

end