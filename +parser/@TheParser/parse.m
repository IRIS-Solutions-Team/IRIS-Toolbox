function [qty, eqn, euc, puc, collector, log] = parse(this, opt)
% parse  Main parser for model code
%
% Backend IRIS function
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

exception.ParseTime.storeFileName(this.FName);

% Check alternative syntax
altSyntax(this);

% Read individual blocks
blockCode = readBlockCode(this);

log = string.empty(1, 0);
qty = model.component.Quantity( );
eqn = model.component.Equation( );
euc = parser.EquationUnderConstruction( );
puc = parser.PairingUnderConstruction( );

numBlocks = numel(this.Block);
collector = struct( );
for i = 1 : numBlocks
    block__ = this.Block{i};
    code__ = blockCode{i};
    if block__.Parse
        if isa(block__, 'parser.theparser.Log')
            log = parse(block__, code__);
        else
            [qty, eqn] = parse(block__, this, code__, qty, eqn, euc, puc, opt);
        end
    else
        collector.(this.Block{i}.Name) = blockCode{i};
    end
end

% Evaluate and assign strings from code
qty = assign(this, qty);

if opt.AutodeclareParameters
    hereAutodeclare( );
end

hereCheckNamingRules( );

% Check for names with multiple occurrences
duplicateNames = parser.getMultiple(qty.Name);
if ~isempty(duplicateNames)
    throw( exception.ParseTime('TheParser:MUTLIPLE_NAMES', 'error'), ...
           duplicateNames{:} );
end

hereAddSpecialExogenous( ); % Add special exogenous variables
qty.OriginalNames = qty.Name; % Store original names from source model code
exception.ParseTime.storeFileName( ); % Reset persistent model file name

return


    function hereAutodeclare( )
        % Remove all parameters declared within the model file
        inxToDelete = qty.Type==TYPE(4);
        if any(inxToDelete)
            qty = delete(qty, inxToDelete);
        end
        % Add as parameters the names from the model equations not declared
        % as anything else 
        namesFound = regexp(eqn.Input, '\<[A-Za-z]\w*\>(?![\(\.])', 'match');
        namesFound = unique([ namesFound{:} ]);
        % Determine residual names to be declared as parameters
        namesToDeclare = setdiff(namesFound, qty.Name); 
        if isempty(namesToDeclare)
            return
        end
        add = model.component.Quantity.fromNames(namesToDeclare);
        qty = insert(qty, add, TYPE(4), 'last');
    end%

        
    function hereCheckNamingRules( )
        % Names must not start with 0-9 or _
        lsName = qty.Name;
        if ~isempty(lsName)
            ixValid = cellfun(@isvarname, lsName);
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:INVALID_NAME', 'error'), ...
                       lsName{~ixValid} );
            end
            % The name 'ttrend' is a reserved name for time trend in
            % !dtrends
            ixValid = ~strcmp(lsName, model.component.Quantity.RESERVED_NAME_TTREND);
            if any(~ixValid)
                throw( ...
                    exception.ParseTime('TheParser:RESERVED_NAME', 'error'), ...
                    model.component.Quantity.RESERVED_NAME_TTREND ...
                );
            end
            % The name 'linear' is reserved for the linear option, and can be used in
            % control expressions in model file.
            ixValid = ~strcmp(lsName, model.component.Quantity.RESERVED_NAME_LINEAR);
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:RESERVED_NAME', 'error'), ...
                       model.component.Quantity.RESERVED_NAME_LINEAR );
            end
        end
        % Shock names must not contain double scores because of the way
        % cross-correlations are referenced
        ixe = qty.Type==TYPE(31) | qty.Type==TYPE(32);
        lse = lsName(ixe);
        if ~isempty(lse)
            ixValid = cellfun(@isempty, strfind(lse, '__'));
            if any(~ixValid)
                throw( exception.ParseTime('TheParser:STD_NAME_WITH_DOUBLE_UNDERSCORE', 'error'), ...
                       lse{~ixValid} );
            end
        end
    end%


    function hereAddSpecialExogenous( )
        add = model.component.Quantity.fromNames(model.component.Quantity.RESERVED_NAME_TTREND);
        add.Label(:) = { model.COMMENT_TTREND };
        qty = insert(qty, add, TYPE(5), 'last');
    end%
end%

