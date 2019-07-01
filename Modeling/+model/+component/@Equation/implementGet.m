function [answ, isValid, query] = implementGet(this, qty, pai, query, varargin)

TYPE = @int8;
PTR = @int16;
answ = [ ];
isValid = true;
numOfEquations = numel(this.Input);

query1 = query;
query1 = lower(query1);
query1 = strrep(query1, 'eqtns', 'eqtn');
query1 = strrep(query1, 'labels', 'label');
query1 = regexprep(query1, '[^\w]', '');

flagStruct = hereGetFlags( );

if any(strcmpi(query1, {'eqtn', 'equations', 'allEquations'}))
    answ = this.Input;
    if flagStruct.Dynamic
        answ = model.component.Equation.extractInput(answ, 'Dynamic');
    elseif flagStruct.Steady
        answ = model.component.Equation.extractInput(answ, 'Steady');
    end
    select = true(1, numOfEquations);
    if flagStruct.Measurement
        select = this.Type==TYPE(1);
    elseif flagStruct.Transition
        select = this.Type==TYPE(2);
    end
    answ = answ(select);
    answ = transpose(answ);

elseif any(strcmpi(query1, {'EqtnLabel', 'Label'}))
    answ = this.Label;
    answ = transpose(answ);
    
    
elseif any(strcmpi(query1, {'EqtnAlias'}))
    answ = this.Alias;
    answ = transpose(answ);
    
    
elseif any(strcmpi(query1, {'EqtnSteady'}))
    answ = model.component.Equation.extractInput(this.Input, 'Steady');
    answ = transpose(answ);
    
    
elseif any(strcmpi(query1, {'EqtnDynamic'}))
    answ = model.component.Equation.extractInput(this.Input, 'Dynamic');
    answ = transpose(answ);
    
    
elseif any(strcmpi(query1, ...
        {'YEqtn', 'XEqtn', 'DEqtn', 'LEqtn', 'UEqtn', 'NEqtn', ...
        'YLabel', 'XLabel', 'DLabel', 'LLabel', 'ULabel', 'NLabel', ...
        'YEqtnAlias', 'XEqtnAlias', 'DEqtnAlias', 'LEqtnAlias', 'UEqtnAlias', 'NEqtnAlias'} ...
        ))
    if strncmpi(query1, 'N', 1)
        ix = this.IxHash;
    else
        ix = this.Type==TYPE(find(strncmpi(query1, {'Y', 'X', 'D', 'L', 'U'}, 1))); %#ok<FNDSB>
    end
    if strcmpi(query1(2:end), 'Eqtn')
        answ = this.Input(ix);
    elseif strcmpi(query1(2:end), 'Label')
        answ = this.Label(ix);
    elseif strcmpi(query1(2:end), 'EqtnAlias')
        answ = this.Alias(ix);
    end
    answ = transpose(answ);
    

else
    isValid = false;
end

return


    function flagStruct = hereGetFlags( )
        listOfFlags = { 'Dynamic'
                        'Steady'
                        'Measurement'
                        'Transition' };
        flagStruct = struct( );
        for i = 1 : numel(listOfFlags)
            temp = query1;
            query1 = regexprep(query1, listOfFlags{i}, '', 'IgnoreCase');
            flagStruct.(listOfFlags{i}) = ~isequal(temp, query1);
        end
    end%
end%
