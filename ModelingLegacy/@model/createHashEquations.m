function eqtn = createHashEquations(this, indexEquations)

persistent FORMAT
if isempty(FORMAT)
    FORMAT = containers.Map('KeyType', 'int32', 'ValueType', 'char');
    FORMAT(1) =  'y(%g,t)';
    FORMAT(2) =  'xi(%g,t)';
    FORMAT(31) = 'e(%g,t)';
    FORMAT(32) = 'e(%g,t)';
    FORMAT(4) =  'p(%g)';
    FORMAT(5) =  'g(%g,t)';
end

%--------------------------------------------------------------------------

if nargin<2
    indexEquations = this.Equation.IxHash;
end

eqtn = this.Equation.Dynamic(indexEquations);

if ~any(indexEquations)
    return
end

% __Measurement, Shocks, Endogenous__
% Replace x(N,t) -> y(K,t) or e(K,t) or g(K,t), no lags or lead are
% allowed.
for type = [1, 31, 32, 5]
    format = FORMAT(type);
    id = find(this.Quantity.Type==type);
    for pos = 1 : numel(id)
        ithId = id(pos);
        findString = sprintf('x(%g,t)', ithId);
        replaceWith = sprintf(format, pos);
        eqtn = strrep(eqtn, findString, replaceWith);
    end
end

% __Parameters__
% Replace x(N,t+/-a) -> p(K,t), lags or leads of parameters are converted
% to current dates
type = 4;
format = FORMAT(type);
id = find(this.Quantity.Type==type);
for pos = 1 : numel(id)
    ithId = id(pos);
    findPattern = '\<x\(%g,t([\+\-]\d+)?\)';
    findPattern = strrep(findPattern, '%g', sprintf('%g', ithId));
    replaceWith = sprintf(format, pos);
    eqtn = regexprep(eqtn, findPattern, replaceWith);
end

% __Transition__
% Replace x(N,t) -> xi(K,t), x(N,t+/-a) -> xi(K,t+/-1)
type = 2;
format = FORMAT(type);
id = this.Vector.Solution{2};
for pos = 1 : length(id)
    nm = real( id(pos) );
    sh = imag( id(pos) );
    if sh==0
        findString = sprintf('x(%g,t)', nm);
    else
        findString = sprintf('x(%g,t%+g)', nm, sh);
    end
    replaceWith = sprintf(format, pos);
    eqtn = strrep(eqtn, findString, replaceWith);
end

% Replace x(N,t+/-k) -> xi(K,t-1) for maximum lags
format = 'xi(%g,t-1)';
id = this.Vector.Solution{2};
for nm = unique(real(id))
    sh = min( imag(id(real(id)==nm)) );
    pos = find(real(id)==nm & imag(id)==sh);
    findString = sprintf('x(%g,t%+g)', nm, sh-1);
    replaceWith = sprintf(format, pos);
    eqtn = strrep(eqtn, findString, replaceWith);
end    

% __Steady-State References__
% Replace time indices in steady-state references
% L(15,t+5) -> L(15,T+5).
eqtn = regexprep(eqtn, '(\<L\>\(\d+,)t', '$1T');

% Vectorize matrix operators
eqtn = strrep(eqtn, '*', '.*');
eqtn = strrep(eqtn, '/', './');
eqtn = strrep(eqtn, '^', '.^');
for i = 1 : numel(eqtn)
    eqtn{i}(strfind(eqtn{i}, '..')) = '';
end

end
