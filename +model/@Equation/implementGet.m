function [answ, isValid, query] = implementGet(eqn, qty, pai, query, varargin)

TYPE = @int8;
PTR = @int16;
answ = [ ];
isValid = true;
query1 = regexprep(query, '[^\w]', '');




if strcmpi(query1, 'Eqtn')
    answ = eqn.Input;
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query1, {'EqtnLabel', 'Label'}))
    answ = eqn.Label;
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query1, {'EqtnAlias'}))
    answ = eqn.Alias;
    answ = answ.';
    
    
    
    
elseif strcmpi(query1, 'EqtnSteady')
    answ = model.Equation.extractInput(eqn.Input, 'Steady');
    answ = answ.';
    
    
    
    
elseif strcmpi(query1, 'EqtnDynamic')
    answ = model.Equation.extractInput(eqn.Input, 'Dynamic');
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query1, ...
        {'YEqtn', 'XEqtn', 'DEqtn', 'LEqtn', 'UEqtn', 'NEqtn', ...
        'YLabel', 'XLabel', 'DLabel', 'LLabel', 'ULabel', 'NLabel', ...
        'YEqtnAlias', 'XEqtnAlias', 'DEqtnAlias', 'LEqtnAlias', 'UEqtnAlias', 'NEqtnAlias'} ...
        ))
    if strncmpi(query1, 'N', 1)
        ix = eqn.IxHash;
    else
        ix = eqn.Type==TYPE(find(strncmpi(query1, {'Y', 'X', 'D', 'L', 'U'}, 1))); %#ok<FNDSB>
    end
    if strcmpi(query1(2:end), 'Eqtn')
        answ = eqn.Input(ix);
    elseif strcmpi(query1(2:end), 'Label')
        answ = eqn.Label(ix);
    elseif strcmpi(query1(2:end), 'EqtnAlias')
        answ = eqn.Alias(ix);
    end
    answ = answ.';
    
    
    

else
    isValid = false;
end

end
