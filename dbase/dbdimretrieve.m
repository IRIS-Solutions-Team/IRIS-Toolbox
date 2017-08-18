function varargout = dbdimretrieve(This,Dim,Ix)
% dbdimretrieve  Retrieve specified slices in specified dimension from database entries.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

list = fieldnames(This);
if isempty(list)
    varargout{1} = This;
    return
end
isEnd = isequal(Ix,'end');
nList = length(list);
ixSuccess = false(1,nList);

for i = 1 : nList
    name = list{i};
    s = size(This.(name));
    if Dim > length(s)
        s(end+1:Dim) = 1;
    end
    ref = cell(1,length(s));
    ref(:) = {':'};
    if isEnd
        ref{Dim} = s(Dim);
    else
        ref{Dim} = Ix;
    end
    if isa(This.(name), 'tseries')
        try %#ok<TRYNC>
            This.(name) = This.(name){ref{:}};
            ixSuccess(i) = true;
        end
    elseif isnumeric(This.(name)) ...
            || islogical(This.(name)) ...
            || iscell(This.(name))
        try %#ok<TRYNC>
            This.(name) = This.(name)(ref{:});
            ixSuccess(i) = true;
        end
    end
end

if any(~ixSuccess)
    This = rmfield(This,list(~ixSuccess));
end
varargout{1} = This;

end
