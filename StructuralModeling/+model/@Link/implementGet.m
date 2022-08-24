function [answ, isValid, query] = implementGet(this, qty, query, varargin)

PTR = @int16;
answ = [ ];
isValid = true;
query1 = regexprep(query, '[^\w]', '');




if any(strcmpi(query1, {'LinksStruct', 'Links', 'Link'}))
    nQty = length(qty.Name);
    ne = sum(qty.Type==PTR(31) | qty.Type==PTR(32));
    nl = length(this);
    lhs = abs(this.LhsPtr);
    lsLhs = cell(1, nl);
    ixQty = lhs<=nQty;
    lsLhs(ixQty) = qty.Name( lhs(ixQty) );
    ixStd = lhs>nQty & lhs<=nQty+ne;
    lsLhs(ixStd) = getStdNames(qty, lhs(ixStd)-nQty);
    ixCorr = lhs>nQty+ne;
    lsLhs(ixCorr) = getCorrNames(qty, lhs(ixCorr)-nQty-ne);
    answ = cell2struct(this.Input, cellstr(lsLhs), 2);




elseif any(strcmpi(query1, {'LinksList'}))
    answ = this.Input;
    answ = answ.';



elseif any(strcmpi(query1, {'LEqtnOrdered', 'LinksOrdered'}))
    answ = this.Input(this.Order);
    answ = answ.';


else
    isValid = false;
end

end
