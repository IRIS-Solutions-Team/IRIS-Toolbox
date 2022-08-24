function [response, isValid, query] = implementGet(this, ~, ~, query, varargin)

response = [ ];
isValid = true;
numEquations = numel(this.Input);

lowerQuery = lower(query);
lowerQuery = replace(lowerQuery, 'eqtns', 'eqtn');
lowerQuery = replace(lowerQuery, 'equations', 'eqtn');
lowerQuery = replace(lowerQuery, 'equation', 'eqtn');
lowerQuery = replace(lowerQuery, 'labels', 'label');
lowerQuery = regexprep(lowerQuery, '[^\w]', '');

[lowerQuery, flagStruct] = locallyGetFlags(lowerQuery);
isQuery = @(varargin) any(strcmpi(lowerQuery, varargin));

if isQuery('Eqtn')
    response = this.Input;
    if flagStruct.Dynamic
        response = model.Equation.extractInput(response, 'Dynamic');
    elseif flagStruct.Steady
        response = model.Equation.extractInput(response, 'Steady');
    end
    select = true(1, numEquations);
    if flagStruct.Measurement
        select = this.Type==1;
    elseif flagStruct.Transition
        select = this.Type==2;
    end
    response = response(select);
    response = reshape(response, [ ], 1);

elseif isQuery('EqtnLabel', 'Label')
    response = this.Label;
    response = reshape(response, [ ], 1);
    
elseif isQuery('EqtnAlias')
    response = this.Alias;
    response = reshape(response, [ ], 1);
    
elseif isQuery( ...
    'YEqtn', 'XEqtn', 'DEqtn', 'LEqtn', 'NEqtn', ...
    'YLabel', 'XLabel', 'DLabel', 'LLabel', 'NLabel', ...
    'YEqtnLabel', 'XEqtnLabel', 'DEqtnLabel', 'LEqtnLabel', 'NEqtnLabel', ...
    'YEqtnAlias', 'XEqtnAlias', 'DEqtnAlias', 'LEqtnAlias', 'NEqtnAlias' ...
    )
    if strncmpi(lowerQuery, 'N', 1)
        inx = this.IxHash;
    else
        inx = this.Type==find(strncmpi(lowerQuery, {'Y', 'X', 'D', 'L'}, 1)); %#ok<FNDSB>
    end
    if endsWith(lowerQuery, 'Eqtn', 'IgnoreCase', true)
        response = this.Input(inx);
    elseif endsWith(lowerQuery, 'Label', 'IgnoreCase', true)
        response = this.Label(inx);
    elseif endsWith(lowerQuery, 'Alias', 'IgnoreCase', true)
        response = this.Alias(inx);
    end
    response = reshape(response, [ ], 1);
    
else
    isValid = false;
end

end%


%
% Local Functions
%


function [query, flagStruct] = locallyGetFlags(query)
    %(
    flagStruct = struct( );
    for flag = ["Dynamic", "Steady", "Measurement", "Transition"]
        lowerFlag = lower(flag);
        flagStruct.(flag) = contains(query, lowerFlag);
        if flagStruct.(flag)
            query = erase(query, lowerFlag);
        end
    end
    %)
end%

