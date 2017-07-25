function [Low,High] = myhpdi(X,Cover,Dim)
% myhpdi  [Not a public function] Highest probability density interval.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team & Troy Matheson.

%--------------------------------------------------------------------------

Cover = Cover/100;

X = X(:,:);

if Dim == 1
    X = X.';
end

% Proceed row by row.
[nPer,nDraw] = size(X);
w = round((1-Cover)*nDraw);
Low = nan(nPer,1);
High = nan(nPer,1);
for t = 1 : nPer
    X(t,:) = sort(X(t,:),2);
    distance = X(t,end-w:end) - X(t,1:w+1);
    [minDistance,pos] = min(distance);
    Low(t,:) = X(t,pos(1));
    High(t,:) = X(t,pos(1)) + minDistance;
end

if Dim == 1
    Low = Low.';
    High = High.';
end

end