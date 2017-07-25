function X = mycumsumk(X,K,RHO)
% mycumsumk  [Not a public function] Cumulative sum over k periods.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%**************************************************************************

nper = size(X,1);
nx = size(X,2);
for ix = 1 : nx
    if K < 0
        first = find(~isnan(X(:,ix)),1);
        if isempty(first)
            continue
        end
        for t = first - K : nper
            X(t,ix) = RHO*X(t+K,ix) + X(t,ix);
        end
    elseif K > 0
        last = find(~isnan(X(:,ix)),1,'last');
        if isempty(last)
            continue
        end
        for t = last - K : -1 : 1
            X(t,ix) = RHO*X(t+K,ix) + X(t,ix);
        end        
    end
end

end