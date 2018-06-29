function [this, namesAssigned] = assign(this, varargin)
% assign  Assign parameters, steady states, std deviations or cross-correlations
%
% __Syntax__
%
%     [M, Assigned] = assign(M, P)
%     [M, Assigned] = assign(M, N)
%     [M, Assigned] = assign(M, Name, Value, Name, Value, ...)
%     [M, Assigned] = assign(M, List, Values)
%
%
% __Syntax for Fast Assign__
%
%     % Initialise
%     assign(M, List);
%
%     % Fast assign
%     M = assign(M, Values);
%     ...
%     M = assign(M, Values);
%     ...
%
%
% __Input arguments__
%
% * `M` [ model ] - Model object.
%
% * `P` [ struct ] - Database whose fields refer to parameter
% names, variable names, std deviations, or cross-correlations.
%
% * `N` [ model ] - Another model object from which all parameteres
% (including std erros and cross-correlation coefficients), and
% steady-states values will be assigned that match the name and type in
% `M`.
%
% * `Name` [ char ] - A parameter name, variable name, std
% deviation, cross-correlation, or a regular expression that will be
% matched against model names.
%
% * `Value` [ numeric ] - A value (or a vector of values in case of
% multiple parameterisations) that will be assigned.
%
% * `List` [ cellstr ] - A list of parameter names, variable names, std
% deviations, or cross-correlations.
%
% * `Values` [ numeric ] - A vector of values.
%
%
% __Output arguments__
%
% * `M` [ model ] - Model object with newly assigned parameters and/or
% steady states.
%
% * `Assigned` [ cellstr | `Inf` ] - List of actually assigned parameter
% names, variables names (steady states), std deviations, and
% cross-correlations; `Inf` indicates that all values has been assigned
% from another model object.
%
%
% __Description__
%
% Calls with `Name`-`Value` or `List`-`Value` pairs throw an error if some
% names in the list are not valid names in the model object. Calls with a
% database, `P`, or another model object, `N`, do not perform this check.
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent POS_VALUES INDEX_VALUES_RHS POS_STDCORR INDEX_STDCORR_RHS NAMES_ASSIGNED
TYPE = @int8;

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);

namesAssigned = cell(1, 0);
if isempty(varargin)
    return
end

flags = struct('Level', false, 'Growth', false, 'ExcludeNaNs', false);
readFlags( );

% Number of input arguments with the growth label removed.
n = length(varargin);
ne = sum(ixe);
nStdCorr = ne + ne*(ne-1)/2;
nv = length(this.Variant);
numOfQuantities = length(this.Quantity);
inputNames = cell(1, 0);
invalidLength = cell(1, 0);
invalidImag = cell(1, 0);
invalidLhsNames = cell(1, 0);

% `Assign` and `stdcorr` are logical indices of values that have been
% assigned.
indexValues = false(1, numOfQuantities);
indexStdCorr = false(1, nStdCorr);

if isempty(varargin)
    % Do nothing.
    
elseif isa(varargin{1}, 'model')
    % Assign from another model object:
    % m = assign(m, n);
    % m = assign(m, n, list);
    assignFromModelObj( );
    
elseif n==1 && isnumeric(varargin{1})
    % Quick assignment after iniatialization.
    % m = assign(m, array).
    assert( ...
        ~isempty(POS_VALUES) || ~isempty(POS_STDCORR), ...
        'model:assign', ...
        'Initialize assign( ) before using the function with a single numeric input.' ...
    );
    if any(INDEX_VALUES_RHS)
        this.Variant.Values(1, POS_VALUES, :) = varargin{1}(INDEX_VALUES_RHS);
    end
    if any(INDEX_STDCORR_RHS)
        this.Variant.StdCorr(1, POS_STDCORR, :) = varargin{1}(INDEX_STDCORR_RHS);
    end
    namesAssigned = NAMES_ASSIGNED;
    % Keep persistent variables and return immediately.
    return
    
elseif n<=2 && iscellstr(varargin{1})
    % assign(m, cellstr) initializes quick-assign function.
    % m = assign(m, cellstr, array);
    inputNames = varargin{1}(:).';
    varargin(1) = [ ];
    numNames = length(inputNames);
    ell = lookup(this.Quantity, inputNames);
    posQuantity = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    indexQuantityRhs = ~isnan(posQuantity);
    posQuantity = posQuantity(indexQuantityRhs);
    indexStdCorrRhs = ~isnan(posStdCorr);
    posStdCorr = posStdCorr(indexStdCorrRhs);
    invalidLhsNames = inputNames(~indexQuantityRhs & ~indexStdCorrRhs);
    
    if isempty(varargin)
        % Initialize quick-assign access and return.
        POS_VALUES = posQuantity;
        POS_STDCORR = posStdCorr;
        INDEX_VALUES_RHS = indexQuantityRhs;
        INDEX_STDCORR_RHS = indexStdCorrRhs;
        getNamesAssigned( );
        NAMES_ASSIGNED = namesAssigned;
        
        % Keep persistent variables and return immediately.
        return
    elseif isnumeric(varargin{1})
        value = varargin{1};
        assignListAndValue( );
        assert( ...
            isempty(invalidLhsNames), ...
            exception.Base('Model:InvalidName', 'error'), ...
            '', invalidLhsNames{:} ...
        ); %#ok<GTARG>
    else
        utils.error('modelobj:assign', '#Invalid_assign:model');
    end
        
elseif n<=2 && (isstruct(varargin{1}) || isa(varargin{1}, 'table'))
    % Assign from struct or table
    % * m = assign(m, struct)
    % * m = assign(m, struct, clone)
    % * m = assign(m, table)
    % * m = assign(m, table, clone)
    d = varargin{1};
    varargin(1) = [ ];
    if isstruct(d)
        % Assign from struct
        inputNames = fieldnames(d);
        inputValues = struct2cell(d);
    else
        % Assign from table
        inputNames = d.Properties.RowNames;
        inputValues = table2cell(d(:, :));
    end
    if ~isempty(varargin) && ~isempty(varargin{1})
        cloneTemplate = varargin{1};
        inputNames = model.File.cloneAllNames(inputNames, cloneTemplate);
    end
    numNames = length(inputNames);
    invalidLength = cell(1, 0);
    invalidImag = cell(1, 0);
    ell = lookup(this.Quantity, inputNames);
    posQuantity = ell.PosName;
    posStdCorr = ell.PosStdCorr;
    for i = 1 : numNames
        ithName = inputNames{i};
        if iscell(inputValues)
            ithValue = inputValues{i};
        else
            ithValue = inputValues(i, :);
        end
        % Do not check if names are valid LHS names in assignments from databases.
        if isnan(posQuantity(i)) && isnan(posStdCorr(i))
            continue
        end
        assignNameAndValue(ithName, posQuantity(i), posStdCorr(i), ithValue);
    end
    reportInvalid( );

elseif all(cellfun(@(x) ischar(x) || isa(x, 'rexp'), varargin(1:2:end)))
    % m = assign(m, name, value, name, value, ...)
    % name is char or char list or rexp or double dot but not cellstr.
    inputNames = varargin(1:2:end);
    numNames = length(inputNames);
    % Remove equal signs from assign(m, 'alpha=', 1).
    for i = 1 : numNames
        inputNames{i} = strrep(inputNames{i}, ' ', '');
        if ~isempty(inputNames{i}) && inputNames{i}(end)=='='
            inputNames{i}(end) = '';
        end
    end
    inputValues = varargin(2:2:end);
    invalidLhsNames = cell(1, 0);
    invalidLength = cell(1, 0);
    invalidImag = cell(1, 0);
    for i = 1 : numNames
        name = inputNames{i};
        value = inputValues{i};
        if isa(name, 'rexp') || isempty(regexp(name, '\W', 'once'))
            % Plain name.
            assignNameAndValue(name, [ ], [ ], inputValues{i});
        else
            % List of names:
            % A1, A2, B
            % or double-dot list 
            % A1, .., A2
            list = name;
            if ~isempty(strfind(list, ', .., '))
                list = parse(parser.doubledot.Keyword.COMMA, list);
            end
            list = regexp(list, '\w+', 'match');
            for j = 1 : length(list)
                ddName = list{j};
                if size(value, 2)==1
                    ddValue = value;
                else
                    ddValue = value(:, j, :);
                end
                assignNameAndValue(ddName, [ ], [ ], ddValue);
            end
        end
    end
    reportInvalid( );
    if ~isempty(invalidLhsNames)
        throw( exception.Base('Model:InvalidName', 'error'), ...
               '', invalidLhsNames{:} );
    end

else
    % Throw an invalid assignment error.
    throw( exception.Base('General:INVALID_ASSIGNMENT', 'error'), ...
           class(this) ); %#ok<GTARG>
end

% Reset persistent variables in each non-quick-assign calls.
POS_VALUES = [ ];
INDEX_VALUES_RHS = [ ];
POS_STDCORR = [ ];
INDEX_STDCORR_RHS = [ ];
NAMES_ASSIGNED = { };

% Steady states cannot be changed from 0+0i.
indexOfNonzeroShocks = false(1, numOfQuantities);
indexOfNonzeroShocks(ixe) = any(this.Variant.Values(1, ixe, :)~=0, 3);
if any(indexOfNonzeroShocks)
    throw( exception.Base('Model:CannotChangeSteadyShocks', 'error'), ...
           this.Quantity.Name{indexOfNonzeroShocks} );
end

if nargout<2
    return
end

% Put together list of parameters, steady states, std deviations, and
% correlations that have been assigned.
getNamesAssigned( );

return

    
    function readFlags( )
        while ~isempty(varargin) && ischar(varargin{1}) ...
                && strncmp(varargin{1}, '-', 1)
            switch lower(strtrim(varargin{1}))
                case '-level'
                    flags.Level = true;
                case '-growth'
                    flags.Growth = true;
                case '-excludenans'
                    flags.ExcludeNaNs = true;
                otherwise
                    throw( exception.Base('Model:INVALID_ASSIGN_FLAG', 'error'), ...
                        varargin{1} );
            end
            varargin(1) = [ ];
        end
    end%


    function assignFromModelObj( )
        rhs = varargin{1};
        namesToAssign = @all;
        if n>1
            namesToAssign = varargin{2};
            if ischar(namesToAssign)
                namesToAssign = regexp(namesToAssign, '\w+', 'match');
            end
        end
        inputNames = rhs.Quantity.Name;
        cloneTemplate = '';
        if n>2
            cloneTemplate = varargin{3};
            if ~isequal(namesToAssign, @all)
                namesToAssign = model.File.cloneAllNames(namesToAssign, cloneTemplate);
            end
            inputNames = model.File.cloneAllNames(inputNames, cloneTemplate);
        end
        nvRhs = length(rhs.Variant);
        if nvRhs~=1 && nvRhs~=nv
            utils.error( 'modelobj:assign', ...
                         ['Cannot assign from object ', ...
                         'with different number of parameterisations.'] );
        end
        numOfQuantities = length(this.Quantity);
        indexOfMatchingTypes = true(1, numOfQuantities);
        for ii = 1 : numOfQuantities
            name = this.Quantity.Name{ii};
            if ~isequal(namesToAssign, @all) && ~any(strcmpi(name, namesToAssign))
                continue
            end
            ixRhs = strcmp(name, inputNames);
            if ~any(ixRhs)
                continue
            end
            if rhs.Quantity.Type(ixRhs)==this.Quantity.Type(ii)
                oldValue = this.Variant.Values(1, ii, :);
                newValue = rhs.Variant.Values(1, ixRhs, :);
                if flags.Growth
                    newValue = real(oldValue) + 1i*imag(newValue);
                elseif flags.Level
                    newValue = real(newValue) + 1i*imag(oldValue);
                end
                this.Variant.Values(1, ii, :) = newValue;
                indexValues(ii) = true;
            else
                indexOfMatchingTypes(ii) = false;
            end
        end
        listOfStdCorr = [ getStdNames(this.Quantity), getCorrNames(this.Quantity) ];
        listOfStdCorrRhs = [ getStdNames(rhs.Quantity), getCorrNames(rhs.Quantity) ];
        if ~isempty(cloneTemplate)
            listOfStdCorrRhs = model.File.cloneAllNames(listOfStdCorrRhs, cloneTemplate);
        end
        for ii = 1 : length(listOfStdCorr)
            ixRhs = strcmpi(listOfStdCorr{ii}, listOfStdCorrRhs);
            if ~any(ixRhs)
                continue
            end
            this.Variant.StdCorr(1, ii, :) = rhs.Variant.StdCorr(1, ixRhs, :);
            indexStdCorr(ii) = true;
        end
        if any(~indexOfMatchingTypes)
            utils.warning( 'modelobj:assign', ...
                           'This name not assigned because of type mismatch: %s ', ...
                           this.Quantity.Name{~indexOfMatchingTypes} );
        end
    end%


    function assignNameAndValue(name, posQuantity, posStdCorr, value)
        % One or more names, one value.
        if isempty(posQuantity) && isempty(posStdCorr)
            ell = lookup(this.Quantity, name);
            indexValues = ell.IxName;
            indexStdCorr = ell.IxStdCorr;
            if ~any(indexValues) && ~any(indexStdCorr)
                if ~isa(inputNames{i}, 'rexp')
                    invalidLhsNames{end+1} = name;
                end
                return
            end
            posQuantity = find(indexValues);
            posStdCorr = find(indexStdCorr);
        end
        value = value(:);
        value = permute(value, [2, 3, 1]);
        numValues = numel(value);
        isValidLen = numValues==1 || numValues==nv;
        if ~isValidLen
            invalidLength{end+1} = name;
            return
        end
        isValidImag = all(imag(value)==0) ...
            || ( ~flags.Growth && ~flags.Level ...
            && all(isnan(posStdCorr)) ...
            && ~any(this.Quantity.Type(posQuantity)==TYPE(4)) );
        if ~isValidImag
            invalidImag{end+1} = name;
            return
        end
        % Assign Variant.Values.
        for pos = posQuantity(~isnan(posQuantity))
            if flags.Level || flags.Growth
                oldValues = this.Variant.Values(:, pos, :);
                if flags.Growth
                    value = real(oldValues) + 1i*value;
                elseif flags.Level
                    value = value + 1i*imag(oldValues);
                end
            end
            this.Variant.Values(:, pos, :) = value;
        end
        % Assign Variant.StdCorr.
        for pos = posStdCorr(~isnan(posStdCorr))
            this.Variant.StdCorr(:, pos, :) = value;
        end
    end%


    function assignListAndValue( )
        if size(value, 2)==1 && numNames>1
            value = repmat(value, 1, numNames, 1);
        end
        if size(value, 3)==1 && nv>1
            value = repmat(value, 1, 1, nv);
        end
        if (flags.Growth || flags.Level) && any(imag(value(:))~=0)
            utils.error('modelobj:assign', ...
                ['Cannot assign(...) non-zero imag numbers ', ...
                'with flag ''-level'' or ''-growth''.']);
        end
        if flags.Level || flags.Growth
            oldValues = this.Variant(:, posQuantity, :);
            if flags.Growth
                value(:, indexQuantityRhs, :) = real(oldValues) + 1i*value(:, indexQuantityRhs, :);
            elseif flags.Level
                value(:, indexQuantityRhs, :) = value(:, indexQuantityRhs, :) + 1i*imag(oldValues);
            end
        end
        if any(indexQuantityRhs)
            indexValues(posQuantity) = true;
            this.Variant.Values(:, posQuantity, :) = value(:, indexQuantityRhs, :);
        end
        if any(indexStdCorrRhs)
            indexStdCorr(posStdCorr) = true;
            this.Variant.StdCorr(:, posStdCorr, :) = value(:, indexStdCorrRhs, :);
        end
    end%


    function reportInvalid( )
        if ~isempty(invalidLength)
            utils.error( 'modelobj:assign', ...
                ['Incorrect number of alternative values assigned ', ...
                'to this name: %s.'], ...
                invalidLength{:} );
        end
        if ~isempty(invalidImag)
            utils.error( 'modelobj:assign', ...
                'This name cannot be assigned complex or imag number: %s ', ...
                invalidImag{:} );
        end
    end%


    function getNamesAssigned( )
        namesAssigned = this.Quantity.Name(indexValues);
        lse = this.Quantity.Name(ixe);
        namesAssigned = [namesAssigned, strcat('std_', lse(indexStdCorr(1:ne)))];
        pos = find( tril(ones(ne), -1)==1 );
        temp = zeros(ne);
        temp(pos(indexStdCorr(ne+1:end))) = 1;
        [row, col] = find(temp==1);
        namesAssigned = [ namesAssigned, ...
            strcat('corr_', lse(row), '__', lse(col)) ];
    end%
end%
