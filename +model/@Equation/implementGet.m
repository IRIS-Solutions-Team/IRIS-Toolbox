function [answ, isValid, query] = implementGet(eqn, qty, pai, query, varargin)

TYPE = @int8;
PTR = @int16;
answ = [ ];
isValid = true;




if strcmpi(query, 'Eqtn')
    answ = eqn.Input;
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query, {'Eqtn:Label', 'EqtnLabel', 'Label'}))
    answ = eqn.Label;
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query, {'Eqtn:Alias', 'EqtnAlias'}))
    answ = eqn.Alias;
    answ = answ.';
    
    
    
    
elseif strcmpi(query, 'Eqtn:Steady')
    answ = model.Equation.extractInput(eqn.Input, 'Steady');
    answ = answ.';
    
    
    
    
elseif strcmpi(query, 'Eqtn:Dynamic')
    answ = model.Equation.extractInput(eqn.Input, 'Dynamic');
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query, ...
        {'YEqtn', 'XEqtn', 'DEqtn', 'LEqtn', 'UEqtn', 'NEqtn', ...
        'YLabel', 'XLabel', 'DLabel', 'LLabel', 'ULabel', 'NLabel', ...
        'YEqtnAlias', 'XEqtnAlias', 'DEqtnAlias', 'LEqtnAlias', 'UEqtnAlias', 'NEqtnAlias'} ...
        ))
    if strncmpi(query, 'N', 1)
        ix = eqn.IxHash;
    else
        ix = eqn.Type==TYPE(find(strncmpi(query, {'Y', 'X', 'D', 'L', 'U'}, 1))); %#ok<FNDSB>
    end
    if strcmpi(query(2:end), 'Eqtn')
        answ = eqn.Input(ix);
    elseif strcmpi(query(2:end), 'Label')
        answ = eqn.Label(ix);
    elseif strcmpi(query(2:end), 'EqtnAlias')
        answ = eqn.Alias(ix);
    end
    answ = answ.';
    
    
    
    
elseif any(strcmpi(query, {'links', 'link'}))
    nQuan = length(qty.Name);
    ixl = eqn.Type==TYPE(4);
    nl = sum(ixl);
    lhs = abs( pai.Link.Lhs(ixl) );
    lsLhs = cell(1, nl);
    ixQuan = lhs<=nQuan;
    lsLhs(ixQuan) = qty.Name( lhs(ixQuan) );
    ixStd = lhs>nQuan & lhs<=nQuan+ne;
    lsLhs(ixStd) = getStdName(qty, lhs(ixStd)-nQuan);
    ixCorr = lhs>nQuan+ne;
    lsLhs(ixCorr) = getCorrName(qty, lhs(ixCorr)-nQuan-ne);
    answ = cell2struct(eqn.Input(ixl), lsLhs, 2);
    
    
    
    
elseif strcmpi(query, 'LEqtn:Ordered')
    ixl = eqn.Type==TYPE(4);
    order = pai.Link.Order(ixl);
    posl = find(ixl);
    if all(order>PTR(0))
        [~, temp] = sort(order);
        posl = posl(temp);
    end
    answ = eqn.Input(posl);
    answ = answ.';
    
    
else
    isValid = false;
end

end
