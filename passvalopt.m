
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function varargout = passvalopt(spec, varargin)

if iscell(spec)
    spec = list2struct(spec);
else
    error('Invalid specs for default options and validators');
end


defaultName = spec.Name;
defaultPrimaryName = spec.PrimaryName;
changed = spec.Changed;
validate = spec.Validate;
opt = spec.Options;

% Return list of unused options.
listUnused = cell(1, 0);

if ~isempty(varargin)
    if iscellstr(varargin(1:2:end)) || all(cellfun(@isstring, varargin(1:2:end)))
        % Called passvalopt(Spec, 'Name', Value,...).
        % This is the preferred way.
        userName = cellstr(varargin(1:2:end));
        userValue = varargin(2:2:end);
        
    elseif nargin==2 && isstruct(varargin{1})
        % Called passvalopt(Spec, struct).
        userName = fieldnames(varargin{1});
        userValue = struct2cell(varargin{1})';
        
    elseif nargin==2 && iscell(varargin{1})
        % Called passvalopt(Spec, {'Name', Value}).
        userName = varargin{1}(1:2:end);
        userValue = varargin{1}(2:2:end);
    else
        utils.error('iris:passvalopt', ...
            'Incorrect list of user options.');
    end
    
    if length(userName)>length(userValue)
        utils.error('iris:passvalopt', ...
            'No value assigned to the last option: %s', ...
            varargin{end});
    end
    
    % Remove non-alphanumeric characters from user names; this is primarily
    % meant to deal with the optional equal signs in option names.
    userName = regexp(userName, '[a-zA-Z]\w*', 'once', 'match');
    
    % List of primary option names specified by the user; this is used to check
    % conflicting options.
    userPrimaryName = { };
    
    for i = 1 : length(userName)
        if isempty(userName{i})
            continue
        end
        pos = strcmpi(userName{i}, defaultName);
        if any(pos)
            pos = find(pos,1);
            name = defaultPrimaryName{pos};
            userPrimaryName{end+1} = name; %#ok<AGROW>
            opt.(name) = userValue{i};
            changed.(name) = userName{i};
        else
            listUnused{end+1} = userName{i}; %#ok<AGROW>
            listUnused{end+1} = userValue{i}; %#ok<AGROW>
        end
    end
    
    if nargout==1 && ~isempty(listUnused)
        throw( ...
            exception.Base('Deprecated', 'error'), ...
            listUnused{1:2:end} ...
            );
    end
    
    % Validate the user-supplied options; default options are NOT validated.
    lsInvalid = { };
    list = fieldnames(opt);
    for i = 1 : numel(list)
        if isempty(changed.(list{i}))
            continue
        end
        value = opt.(list{i});
        validFunc = validate.(list{i});
        if ~isempty(validFunc)
            if ~feval(validFunc,value)
                lsInvalid{end+1} = changed.(list{i}); %#ok<AGROW>
                lsInvalid{end+1} = func2str(validate.(list{i})); %#ok<AGROW>
            end
        end
    end

    if ~isempty(lsInvalid)
        throw( ...
            exception.Base('Options:FailsValidation', 'error'), ....
            lsInvalid{:} ...
        );
    end
end

% __Evaluate @auto Options__
list = fieldnames(opt);
for i = 1 : length(list)
    value = opt.(list{i});
    if isequal(value, @auto)
        try %#ok<TRYNC>
            opt = feval(['iris.options.auto.', list{i}], opt);
        end
    end
end

varargout = { opt, listUnused };

end%


function y = list2struct(x)
    y = struct( );
    if isempty(x)
        return
    end

    if size(x, 1)==1 && size(x, 2)>3
        x = reshape(x, 3, size(x, 2)/3).';
    end

    lsName = x(:, 1);
    nName = numel(lsName);
    lsName = regexp(lsName, '[a-zA-Z]\w*', 'match');
    lsPrimaryName = { };
    options = struct( );
    changed = struct( );
    validate = struct( );

    for i = 1 : nName
        name = lsName{i};
        primaryName = name{1};
        n = length(name);
        % List of primary names.
        lsPrimaryName = [lsPrimaryName, repmat( { primaryName }, 1, n)]; %#ok<AGROW>
        options.(name{1}) = x{i, 2};
        % If this option is changed, save the exact name the user used so that an
        % error can refer to it should the user value fail to validate.
        changed.(name{1}) = '';
        % Anonymous functions to validate user supplied values.
        validate.(name{1}) = x{i, 3};
    end

    % List of all possible names; name{i} maps into primaryName{i}.
    lsName = [ lsName{:} ];

    y.Name = lsName; % List of all possible option names.
    y.PrimaryName = lsPrimaryName; % List of corresponding primary names.
    y.Options = options; % Struct with primary names and default values.
    y.Changed = changed; % Struct with empty chars, to be filled with the names used actually by the user.
    y.Validate = validate; % Struct with validating functions.
end%

