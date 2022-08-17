function [flag, listOfMissing] = chkmissing(this, d, start, varargin)


%(
defaults = { 
    'error', true, @(x) isequal(x, true) || isequal(x, false)
};
%)


opt = passvalopt(defaults, varargin{:});

%--------------------------------------------------------------------------

listOfMissing = cell.empty(1, 0);

start = double(start);
nv = length(this);
[~, ~, nb, nf] = sizeSolution(this.Vector);
vecXb = this.Vector.Solution{2}(nf+1:end);

indexOfAvailable = true(1, nb);
pos = real(vecXb);
sh = imag(vecXb);
lag = sh - 1;
for j = 1 : nb
    name = this.Quantity.Name{ pos(j) };
    try
        value = getDataFromTo( d.(name), dater.plus(start, lag(j)) );
        value = value(:, :);
        if numel(value)==1 && nv>1
            value = repmat(value, 1, nv);
        end
        jthIsInitial = permute(this.Variant.IxInit(:, j, :), [1, 3, 2]);
        indexOfAvailable(j) = all(~isnan(value) | ~jthIsInitial);
    catch
        indexOfAvailable(j) = false;
    end
end

flag = all(indexOfAvailable);
if ~flag
    listOfMissing = printSolutionVector( this, ...
                                         pos(~indexOfAvailable) + 1i*lag(~indexOfAvailable) );
    if opt.error
        throw( exception.Base('Model:MissingInitCond', 'error'), ...
               listOfMissing{:} );
    end
end

end%

