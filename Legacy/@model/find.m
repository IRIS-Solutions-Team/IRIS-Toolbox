function [indexOfAllFound, varargout] = find(this, caller, varargin)

if any(strcmpi(varargin, '-rexp'))
    throw( exception.Base('Deprecated', 'error') ); 
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

numOfQueries = numel(varargin);
indexOfAllFound = false(1, numel(list));
varargout = cell(1, numOfQueries);
for i = 1 : numOfQueries
    if isa(varargin{i}, 'rexp')
        % Query is a rexp (regular expression); return a cell array. 
        start = regexp(label, varargin{i}, 'once');
        indexOfFound = ~cellfun(@isempty, start);
        if isTranspose
            varargout{i} = list(indexOfFound).';
        end
    else
        % Query is a char, possibly ending with an ellipsis; return a char (first hit).
        if strncmp(fliplr(varargin{i}), '...', 3)
            indexOfFound = strncmp(label, varargin{i}(1:end-3), length(varargin{i})-3);
        else
            indexOfFound = strcmp(label, varargin{i});
        end 
        if any(indexOfFound)
            pos = find(indexOfFound, 1);
            varargout{i} = list{pos};
        end
    end
    indexOfAllFound = indexOfAllFound | indexOfFound;
end

end
