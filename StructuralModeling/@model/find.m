function varargout = find(this, caller, varargin)
% find  Find equations or quantities by their labels.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if any(strcmpi(varargin, '-rexp'))
    throw( ...
       exception.Base('Obsolete:RexpFlag', 'error') ...
    ); 
end

isTranspose = false;
switch caller
    case 'eqn'
        list = this.Equation.Input;
        label = this.Equation.Label;
        isTranspose = true;
    case 'qty'
        list = this.Quantity.Name;
        label = this.Quantity.Label;
end

varargout = cell(size(varargin));
for i = 1 : numel(varargin)
    if isa(varargin{i}, 'rexp')
        % Query is a rexp (regular expression); return a cell array. 
        start = regexp(label, varargin{i}, 'once');
        ix = ~cellfun(@isempty, start);
        if isTranspose
            varargout{i} = list(ix).';
        end
    else
        % Query is a char, possibly ending with an ellipsis; return a char (first hit).
        if strncmp(fliplr(varargin{i}), '...', 3)
            ix = strncmp(label, varargin{i}(1:end-3), length(varargin{i})-3);
        else
            ix = strcmp(label, varargin{i});
        end 
        if any(ix)
            pos = find(ix, 1);
            varargout{i} = list{pos};
        end
    end
end

end
