function this = rename(this, method, varargin)

% >=R2019b
arguments
    this model.component.Quantity
    method (1, 1) string {mustBeMember(method, ["pair", "list"])}
end
% >=R2019b

if isempty(this.OriginalNames)
    this.OriginalNames = this.Name;
end

%--------------------------------------------------------------------------

renamePairs = cell(length(varargin), 2);
validSpec = true(size(varargin));
validOriginalNames = true(size(varargin));
validNewName = true(size(varargin));
newNames = this.Name;
for i = 1 : numel(varargin)
    ithRename = varargin{i};
    match = regexp(varargin{i}, '\w+', 'match');
    validSpec(i) = numel(match)==2;
    if ~validSpec(i)
        continue
    end

    renamePairs(i, 1:2) = match(:);
    ell = lookup(this, renamePairs{i, 1});
    indexOriginalNames = ell.IxName;
    validOriginalNames(i) = any(indexOriginalNames);
    if ~validOriginalNames(i)
        continue
    end
    
    validNewName(i) = isstrprop(renamePairs{i, 2}(1), 'alpha');
    if ~validNewName(i)
        continue
    end

    newNames{indexOriginalNames} = renamePairs{i, 2};
end

assert( ...
    all(validSpec), ...
    'model:component:Quantity:rename:IllegalSpec', ...
    'Illegal rename specification: %s \n', ...
    varargin{~validSpec} ...
);

assert( ...
    all(validOriginalNames), ...
    'model:component:Quantity:rename:IllegalOriginalNames', ...
    'This name does not exist: %s \n', ...
    renamePairs{~validOriginalNames, 1} ...
);

assert( ...
    all(validNewName), ...
    'model:component:Quantity:rename:IllegalNewName', ...
    'This is not a valid name: %s \n', ....
    renamePairs{~validNewName, 2} ...
);

[flag, duplicateNames] = textual.nonunique(newNames);
if flag
    THIS_ERROR = { 'Model:Component:Quantity:DuplicateNames'
                   'This is a duplicate name after renaming: %s \n' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           duplicateNames{:} );
end

this.Name = newNames;

end%

