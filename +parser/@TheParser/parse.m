% parse  Main parser for model source code
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%#ok<*GTARG>

function [qty, eqn, euc, puc, collector, logList] = parse(this, opt)

stringify = @(x) reshape(string(x), 1, []);

exception.ParseTime.storeFileName(this.FName);

% Check alternative syntax
altSyntax(this);

% Read individual blocks, and combine blocks of the same type into one 
[blockCode, blockAttributes] = readBlockCode(this);

logList = string.empty(1, 0);
logExcept = logical.empty(1, 0);

qty = model.Quantity( );
eqn = model.Equation( );
euc = parser.EquationUnderConstruction( );
puc = parser.PairingUnderConstruction( );

numBlocks = numel(this.Block);
collector = struct( );
for i = 1 : numBlocks
    block__ = this.Block{i};
    if block__.Parse
        for j = 1 : numel(blockCode{i})
            code__ = blockCode{i}(j);
            attributes__ = blockAttributes{i}{j};
            if isa(block__, 'parser.theparser.Log')
                [logList, logExcept] = parse(block__, code__, logList, logExcept);
            else
                [qty, eqn, euc] = parse(block__, this, code__, attributes__, qty, eqn, euc, puc, opt);
            end
        end
    else
        code__ = "";
        if ~isempty(blockCode{i})
            code__ = join(blockCode{i}, newline);
            if isempty(code__) || all(strlength(code__)==0)
                code__ = "";
            end
        end
        blockName = block__.Name;
        if ~isfield(collector, blockName)
            collector.(blockName) = '';
        end
        collector.(blockName) = [ ...
            collector.(blockName), ...
            char(code__) ...
        ];
    end
end


if ~isempty(logExcept) && all(logExcept) % [^1]
    logList = Except(logList);
end
% [^1]: The consistency of all-but has been already verified in
% parser.theparser.Log/precheck


% Evaluate and assign strings from code
qty = assign(this, qty);

if opt.AutodeclareParameters
    here_autodeclare( );
end

return

    function here_autodeclare()
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
        add = model.Quantity.fromNames(namesToDeclare);
        qty = insert(qty, add, 4, 'last');
        %)
    end%
end%

