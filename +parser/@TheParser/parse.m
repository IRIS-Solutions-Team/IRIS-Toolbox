function [qty, eqn, euc, puc] = parse(this, opt)
% parse  Main parser for model code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

exception.ParseTime.storeFileName(this.FName);

% Check alternative syntax.
altSyntax(this);

% Read individual blocks.
blockCode = readBlockCode(this);

qty = model.component.Quantity( );
eqn = model.component.Equation( );
euc = parser.EquationUnderConstruction( );
puc = parser.PairingUnderConstruction( );

numBlocks = length(this.Block);
for i = 1 : numBlocks
    [qty, eqn] = ...
        parse(this.Block{i}, this, blockCode{i}, qty, eqn, euc, puc, opt);
end

% Evaluate and assign strings from code.
qty = assign(this, qty);

if opt.AutodeclareParameters
    autodeclare( );
end

checkNamingRules( );

% Check for names with multiple occurrences.
duplicateNames = parser.getMultiple(qty.Name);
if ~isempty(duplicateNames)
    throw( ...
        exception.ParseTime('TheParser:MUTLIPLE_NAMES', 'error'), ...
        duplicateNames{:} ...
    );
end

addSpecialExogenous( ); % Add special exogenous variables.
qty.OriginalNames = qty.Name; % Store original names from source model code.
exception.ParseTime.storeFileName( ); % Reset persistent model file name.

return


    function autodeclare( )
        % Add names that are not declared to parameters.
        % Look up all names in all equations.
        namesFound = regexp(eqn.Input, '\<[A-Za-z]\w*\>(?![\(\.])', 'match');
        namesFound = unique([ namesFound{:} ]);
        % Determine residual names to be declared as parameters.
        add = struct( );
        add.Name = setdiff(namesFound, qty.Name);
        if isempty(add.Name)
            return
        end
        nAdd = length(add.Name);
        add.Label = repmat({''}, 1, nAdd);
        add.Alias = repmat({''}, 1, nAdd);
        add.IxLog = false(1, nAdd);
        add.IxLagrange = false(1, nAdd);
        add.Bounds = repmat(qty.DEFAULT_BOUNDS, 1, nAdd);
        qty = insert(qty, add, TYPE(4), 'last');
    end

        
    function checkNamingRules( )
        % Names must not start with 0-9 or _.
        lsName = qty.Name;
        if ~isempty(lsName)
            ixValid = cellfun(@isvarname, lsName);
            if any(~ixValid)
                throw( ...
                    exception.ParseTime('TheParser:INVALID_NAME', 'error'), ...
                    lsName{~ixValid} ...
                    );
            end
            % The name 'ttrend' is a reserved name for time trend in
            % !dtrends.
            ixValid = ~strcmp(lsName, model.RESERVED_NAME_TTREND);
            if any(~ixValid)
                throw( ...
                    exception.ParseTime('TheParser:RESERVED_NAME', 'error'), ...
                    model.RESERVED_NAME_TTREND ...
                    );
            end
            % The name 'linear' is reserved for the linear option, and can be used in
            % control expressions in model file.
            ixValid = ~strcmp(lsName, model.RESERVED_NAME_LINEAR);
            if any(~ixValid)
                throw( ...
                    exception.ParseTime('TheParser:RESERVED_NAME', 'error'), ...
                    model.RESERVED_NAME_LINEAR ...
                    );
            end
        end
        % Shock names must not contain double scores because of the way
        % cross-correlations are referenced.
        ixe = qty.Type==TYPE(31) | qty.Type==TYPE(32);
        lse = lsName(ixe);
        if ~isempty(lse)
            ixValid = cellfun(@isempty, strfind(lse, '__'));
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:STD_NAME_WITH_DOUBLE_UNDERSCORE', 'error'), ...
                    lse{~ixValid} );
            end
        end
    end


    function addSpecialExogenous( )
        add = model.component.Quantity( );
        add.Name = { model.RESERVED_NAME_TTREND };
        add.Label = { model.COMMENT_TTREND };
        add.Alias = {''};
        add.IxLog = false;
        add.IxLagrange = false;
        add.IxObserved = false;
        add.Bounds = qty.DEFAULT_BOUNDS;
        qty = insert(qty, add, TYPE(5), 'last');
    end
end
