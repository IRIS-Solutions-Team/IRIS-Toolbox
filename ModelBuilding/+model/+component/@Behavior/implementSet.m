function [this, isValidRequest, isValidValue] = implementSet(this, request, value, varargin)

% TYPE = @int8;
isValidRequest = true;
isValidValue = true;

switch upper(request)
    case 'BEHAVIOR'
        ls = fieldnames(this);
        for i = 1 : numel(ls)
            this.(ls{i}) = value{1}.(ls{i});
        end
        return
        
    case 'BEHAVIOR:INVALIDDOTASSIGN'
        this.InvalidDotAssign = value;

    case 'BEHAVIOR:DOTREFERENCEFUNC'
        this.DotReferenceFunc = value;
        
    otherwise
        isValidRequest = false;
end

end
