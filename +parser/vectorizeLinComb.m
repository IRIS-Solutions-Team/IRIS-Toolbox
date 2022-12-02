% vectorizeLinComb  Convert strings with linear combinations of names to vectors.

function [Z, C, ixValid] = vectorizeLinComb(strLinComb, lsName)

% Prepare strLinComb and lsName
strLinComb = reshape(cellstr(strLinComb), 1, []);
nString = numel(strLinComb);

lsName = reshape(cellstr(lsName), 1, []);
lsName = regexptranslate('escape', lsName);
nName = numel(lsName);
for i = 1 : nName
    strLinComb = regexprep( ...
        strLinComb, ...
        ['\<',lsName{i},'\>(?!\{)'], ...
        sprintf('?(%g)',i) ...
    );
end
strLinComb = strrep(strLinComb,'?','x');

% Convert strLincComb to vectors of numbers. Z, C.
Z = nan(nString, nName);
C = zeros(nString, 1);
ixValid = true(1, nString);
for i = 1 : nString
    try
        f = str2func( ['@(x)', strLinComb{i}] );
        x = zeros(1,nName);
        try
            C(i) = f(x);
        catch %#ok<CTCH>
            C(i) = NaN;
        end
        for j = 1 : nName
            x = zeros(1,nName);
            x(j) = 1;
            Z(i,j) = f(x) - C(i);
        end
    catch
        ixValid(i) = false;
    end
end

end%

