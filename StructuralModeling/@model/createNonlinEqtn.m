function eqtn = createNonlinEqtn(this, ix)

FORMAT = {'y(%g,t)', 'xi(%g,t)', 'e(%g,t)', 'p(%g)', 'g(%g,t)'};

eqtn = this.Equation.Dynamic(ix);

if ~any(ix)
    return
end

% Replace x(N,t) -> y(K,t) or e(K,t) or p(K) or g(K,t).
for i = 1 : numel(this.Vector.Solution)
    id = this.Vector.Solution{i};
    format = FORMAT{i};
    for pos = 1 : length(id)
        nm = real( id(pos) );
        sh = imag( id(pos) );
        if sh==0
            fnd = sprintf('x(%g,t)', nm);
        else
            fnd = sprintf('x(%g,t%+g)', nm, sh);
        end
        rpl = sprintf(format, pos);
        eqtn = strrep(eqtn, fnd, rpl);
    end
end

% Replace x(N,t+/-k) -> xi(K,t-1) for maximum lags.
id = this.Vector.Solution{2};
format = FORMAT{2};
format = strrep(format, 't', 't-1');
for nm = unique(real(id))
    sh = min( imag(id(real(id)==nm)) );
    pos = find(real(id)==nm & imag(id)==sh);
    fnd = sprintf('x(%g,t%+g)', nm, sh-1);
    rpl = sprintf(format, pos);
    eqtn = strrep(eqtn, fnd, rpl);
end    

% Replace time indices in steady-state references:
% L(15,t+5) -> L(15,T+5).
eqtn = regexprep(eqtn, '(\<L\>\(\d+,)t', '$1T');

% Vectorize matrix operators.
eqtn = strrep(eqtn, '*', '.*');
eqtn = strrep(eqtn, '/', './');
eqtn = strrep(eqtn, '^', '.^');
for i = 1 : numel(eqtn)
    eqtn{i}(strfind(eqtn{i}, '..')) = '';
end

end
