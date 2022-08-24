function [this, isValidRequest, isValidValue] = implementSet(this, request, value, varargin)

isValidRequest = true;
isValidValue = true;

if strcmpi(request, 'Behavior')
    ls = fieldnames(this);
    for i = 1 : numel(ls)
        this.(ls{i}) = value{1}.(ls{i});
    end
    return

elseif strcmpi(request, 'Behavior:InvalidDotAssign')
    this.InvalidDotAssign = value;
    return

elseif strcmpi(request, 'Behavior:InvalidDotReference')
    this.InvalidDotReference = value;
    return

elseif strcmpi(request, 'Behavior:DotReferenceFunc')
    this.DotReferenceFunc = value;
    return

elseif strcmpi(request, 'Behavior:LogStyleInSolutionVectors')
    this.LogStyleInSolutionVectors = value;
        
else
    isValidRequest = false;

end

end%

