function this = rename(this, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model.component.Quantity.rename');
    INPUT_PARSER.addRequired('Quantity', @(x) isa(x, 'model.component.Quantity'));
    INPUT_PARSER.addRequired('RenamePairs', @iscellstr);
end
INPUT_PARSER.parse(this, varargin);

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

duplicateNames = textual.duplicate(newNames);
assert( ...
    isempty(duplicateNames), ...
    'model:component:Quantity:rename:DuplicateNames', ...
    'This is a duplicate name after renaming: %s \n', ...
    duplicateNames{:} ...
);

this.Name = newNames;

end
