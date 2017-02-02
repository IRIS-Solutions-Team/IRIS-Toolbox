function Y = myprctile(X,P,Dim)
% prctile  [Not a public function] Percentiles (better performance that Stats Toolbox).
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

try
    Dim; %#ok<VUNUS>
catch
    Dim = 1;
end

pp = inputParser( );
pp.addRequired('X',@isnumeric);
pp.addRequired('P',@(x) isnumeric(x) && all(P >= 0) && all(P <= 100));
pp.addRequired('Dim',@(x) isintscalar(x) && x > 0);
pp.parse(X,P,Dim);

%--------------------------------------------------------------------------

P = P(:).';
np = length(P);

s = size(X);
nd = length(s);

% Put the requested dimension first.
if Dim > 1
    if Dim > nd
        nd = Dim;
    end
    prm = [Dim:nd,1:Dim-1];
    X = permute(X,prm);
    s = size(X);
end

X = X(:,:);
Y = nan(np,size(X,2));

doPrctileCols( );

if nd > 2
    Y = reshape(Y,[size(Y,1),s(2:end)]);
end

if Dim > 1
    Y = ipermute(Y,prm);
end


% Nested functions...


%**************************************************************************
    function doPrctileCols( )
        % doPrctileCols  Percentiles on columns of non-empty X.
        
        % Remove all rows that only contain NaNs.
        ixAllNaNRow = all(isnan(X),2);
        X(ixAllNaNRow,:) = [ ];
                
        if isempty(X)
            return
        end
        
        % Repeat the smallest and largest observations to generate
        % the 0-th and 100-th percentiles.
        prctileFunc = @(X,N,P) interp1( ...
            [0, 100*(0.5:N - 0.5)./N, 100], ...
            X([1, 1:end, end],:), ...
            P,'linear');
        
        X = sort(X,1);
        
        % First, do all columns that do not contain any NaNs at once.
        ixNanCol = any(isnan(X),1);
        if any(~ixNanCol)
            n = size(X,1);
            Y(:,~ixNanCol) = prctileFunc(X(:,~ixNanCol),n,P);
        end
        
        % Then, cycle over columns with NaNs individually.
        for iCol = find(ixNanCol)
            iX = X(:,iCol);
            iX(isnan(iX)) = [ ];
            if isempty(iX)
                continue
            end
            n = length(iX);
            Y(:,iCol) = prctileFunc(iX,n,P);
        end
    end % doPrctileCols( )


end