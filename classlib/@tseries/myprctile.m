function y = myprctile(x, p, dim)
% prctile  Percentiles (better performance than Stats Toolbox).
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    dim; %#ok<VUNUS>
catch
    dim = 1;
end

pp = inputParser( );
pp.addRequired('x', @isnumeric);
pp.addRequired('p', @(x) isnumeric(x) && all(p >= 0) && all(p <= 100));
pp.addRequired('dim', @(x) isintscalar(x) && x>0);
pp.parse(x, p, dim);

%--------------------------------------------------------------------------

p = p(:).';
np = length(p);

s = size(x);
nd = length(s);

% Put the requested dimension first.
if dim>1
    if dim>nd
        nd = dim;
    end
    prm = [dim:nd, 1:dim-1];
    x = permute(x, prm);
    s = size(x);
end

x = x(:, :);
y = nan(np, size(x, 2));

prctileCols( );

if nd>2
    y = reshape(y, [size(y, 1), s(2:end)]);
end

if dim>1
    y = ipermute(y, prm);
end

return




    function prctileCols( )
        % Repeat the smallest and largest observations to generate
        % the 0-th and 100-th percentiles.
        FN_PRCTILE = @(x, n, p) interp1( ...
            [0, 100*(0.5:n - 0.5)./n, 100], ...
            x([1, 1:end, end], :), ...
            p, 'linear');
        
        % Remove all rows that only contain NaNs.
        ixAllNaNRow = all(isnan(x), 2);
        x(ixAllNaNRow, :) = [ ];
                
        if isempty(x)
            return
        end
        
        x = sort(x, 1);
        
        % First, do all columns that do not contain any NaNs at once.
        ixNanCol = any(isnan(x), 1);
        if any(~ixNanCol)
            n = size(x, 1);
            y(:, ~ixNanCol) = FN_PRCTILE(x(:, ~ixNanCol), n, p);
        end
        
        % Then, cycle over columns with NaNs individually.
        for iCol = find(ixNanCol)
            iX = x(:, iCol);
            iX(isnan(iX)) = [ ];
            if isempty(iX)
                continue
            end
            n = length(iX);
            y(:, iCol) = FN_PRCTILE(iX, n, p);
        end
    end 
end
