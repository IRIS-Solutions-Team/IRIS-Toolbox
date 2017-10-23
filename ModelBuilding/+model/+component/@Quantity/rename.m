function this = rename(this, varargin)

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model.component.Quantity.rename');
    INPUT_PARSER.addRequired('Quantity', @(x) isa(x, 'model.component.Quantity'));
    INPUT_PARSER.addRequired('RenamePairs', @iscellstr);
end
INPUT_PARSER.parse(this, varargin);

if isempty(this.OriginalName)
    this.OriginalName = this.Name;
end

%--------------------------------------------------------------------------

renamePairs = cell(length(varargin), 2);
validSpec = true(size(varargin));
validOriginalName = true(size(varargin));
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
    indexOriginalName = ell.IxName;
    validOriginalName(i) = any(indexOriginalName);
    if ~validOriginalName(i)
        continue
    end
    
    validNewName(i) = isstrprop(renamePairs{i, 2}(1), 'alpha');
    if ~validNewName(i)
        continue
    end

    newNames{indexOriginalName} = renamePairs{i, 2};
end

assert( ...
    all(validSpec), ...
    'model:component:Quantity:rename:IllegalSpec', ...
    'Illegal rename specification: %s ', ...
    varargin{~validSpec} ...
);

assert( ...
    all(validOriginalName), ...
    'model:component:Quantity:rename:IllegalOriginalName', ...
    'This name does not exist: %s ', ...
    renamePairs{~validOriginalName, 1} ...
);

assert( ...
    all(validNewName), ...
    'model:component:Quantity:rename:IllegalNewName', ...
    'This is not a valid name: %s ', ....
    renamePairs{~validNewName, 2} ...
);

tt = tabulate(newNames);
count = [tt{:, 2}];
indexUnique = count==1;
assert( ...
    all(indexUnique), ...
    'model:component:Quantity:rename:DuplicateNames', ...
    'This is a duplicate name after renaming: %s ', ...
    tt{~indexUnique, 1} ...
);

this.Name = newNames;

end
