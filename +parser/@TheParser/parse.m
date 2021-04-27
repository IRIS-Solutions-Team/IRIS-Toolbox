% parse  Main parser for model source code
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

%#ok<*GTARG>

function [qty, eqn, euc, puc, collector, log] = parse(this, opt)

stringify = @(x) reshape(string(x), 1, []);

exception.ParseTime.storeFileName(this.FName);

% Check alternative syntax
altSyntax(this);

% Read individual blocks, and combine blocks of the same type into one 
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
% 
% % Validate quantity names; validate after autodeclaring parameters
% validateNames(qty);
% 
% hereAddSpecialExogenous(); % Add special exogenous variables
% qty.OriginalNames = stringify(qty.Name); % Store original names from source model code
% exception.ParseTime.storeFileName( ); % Reset persistent model file name
% 
return

    function hereAutodeclare()
        %(
        % Remove all parameters declared within the model file
        inxToDelete = qty.Type==4;
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
        qty = insert(qty, add, 4, 'last');
        %)
    end%


    function hereAddSpecialExogenous()
        %(
        add = model.component.Quantity.fromNames(model.component.Quantity.RESERVED_NAME_TTREND);
        add.Label(:) = { model.COMMENT_TTREND };
        qty = insert(qty, add, 5, 'last');
        %)
    end%
end%

