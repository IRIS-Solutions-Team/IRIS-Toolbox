function [answ, isValid, query] = implementGet(eqn, qty, pai, query, varargin)

TYPE = @int8;
PTR = @int16;
answ = [ ];
isValid = true;
query1 = regexprep(query, '[^\w]', '')




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
    
    
    
    
elseif any(strcmpi(query1, {'LinksStruct', 'Links', 'Link'}))
    nQuan = length(qty.Name);
    ne = sum(qty.Type==PTR(31) | qty.Type==PTR(32));
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




elseif any(strcmpi(query1, {'LinksList'}))
    answ = eqn.Input(eqn.Type==TYPE(4));
    answ = answ.';
    
    
    
elseif any(strcmpi(query1, {'LEqtnOrdered', 'LinksOrdered'}))
    answ = eqn.Input(pai.Link.Order);
    answ = answ.';
    
    
else
    isValid = false;
end

end
