function [this, isValidRequest, isValidValue] = implementSet(this, request, value, varargin)

isValidRequest = true;
isValidValue = true;

switch lower(request)
    case {'label', 'eqtnlabel'}
        if iscellstr(value) && length(value)==length(this.Label)
            this.Label(:) = value(:);
        else
            isValidValue = false;
        end
        
    case 'eqtnalias'
        if iscellstr(value) && length(value)==length(this.Alias)
            this.Alias(:) = value(:);
        else
            isValidValue = false;
        end
        
    case {'ylabel', 'mlabel', 'xlabel', 'tlabel', 'dlabel', 'llabel', ...
            'yeqtnalias', 'malias', 'xeqtnalias', 'talias', 'deqtnalias', 'dalias', 'leqtnalias', 'lalias'}
        if ~isempty(strfind(query, 'label'))
            prop = 'Label';
        else
            prop = 'Alias';
        end
        ixEmpty = cellfun(@isempty, this.Input);
        switch query(1)
            case {'y', 'm'}
                ixType = this.Type==1;
            case {'x', 't'}
                ixType = this.Type==2;
            case 'd'
                ixType = this.Type==3 & ~ixEmpty;
            case 'l'
                ixType = this.Type==4;
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
