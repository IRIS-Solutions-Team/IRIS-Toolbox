function this = add(this, child, varargin)
% Go down this object and all its descendants and find the
% youngest among possible parents.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = [ ];
x = this;

child.hInfo = this.hInfo;

while true
    if any(strcmpi(shortclass(x), child.childof)) ...
            && accepts(x)
        par = x;
    end
    if isempty(x.children)
        break
    end
    x = x.children{end};
end

% `x` is now the last child in the last generation.
if ~isequal(par, [ ])
    % Set parent first so that it is available in `specargin` and `setoptions`.
    child.parent = par;
    [child, varargin] = specargin(child, varargin{:});
    child = setoptions(child, par.options, varargin{:});    
    par.children{end+1} = child;
else
    label1 = shortclass(child);
    if ~isempty(child.title)
        label1 = [label1, ' ''', child.title, ''''];
    end
    label2 = shortclass(x);
    if ~isempty(x.title)
        label2 = [label2, ' ''', x.title, ''''];
    end
    utils.error('report', ...
        'This is not the right place to add %s after %s.', ...
        label1, label2);
end

end
