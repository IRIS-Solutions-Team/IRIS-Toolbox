function varargout = myfind(this, caller, varargin)
% myfind  Find equations or names by their labels or descriptions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if strcmpi(caller, 'findeqtn')
    list = this.Equation.Input;
    label = this.Equation.Label;
else
    list = this.Quantity.Name;
    label = this.Quantity.Label;
end

if isequal(varargin{1}, '-rexp')
    isRexp = true;
    varargin(1) = [ ];
elseif isa(varargin{1}, 'rexp')
    isRexp = true;
    varargin{1} = char(varargin{1});
else
    isRexp = false;
end

varargout = cell(size(varargin));
for i = 1 : length(varargin)
    if isRexp
        ix = regexp(label, sprintf('^%s$', varargin{i}));
        ix = ~cellfun(@isempty, ix);
        varargout{i} = list(ix);
    elseif length(varargin{i})>3 ...
            && strcmp(varargin{i}(end-2:end), '...')
        ix = strncmp(list, varargin{i}(1:end-3), length(varargin{i})-3);
        if any(ix)
            varargout{i} = list(find(ix, 1));
        end
    else
        ix = strcmp(label, varargin{i});
        if any(ix)
            varargout{i} = list{find(ix, 1)};
        end
    end
end

end
