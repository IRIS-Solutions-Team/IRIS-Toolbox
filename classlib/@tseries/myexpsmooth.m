function X = myexpsmooth(X,Beta,Init)
% myexpsmooth  [Not a public function] Exponential smoothing.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

s = size(X);
X = X(:,:);
nx = size(X,2);

if isempty(Init)
    Init = nan(1,nx);
else
    Init = Init(:).';
    if length(Init) < nx
        Init(end+1:nx) = Init(end);
    end
end

nPer0 = NaN;
for i = 1 : nx
    data = X(:,i);    
    isNanData = isnan(data);
    first = find(~isNanData,1);
    last = find(~isNanData,1,'last');
    data = data(first:last);
    isinit = ~isnan(Init(i));
    if isinit
        data = [Init(i);data]; %#ok<AGROW>
    end
    nPer = size(data,1);
    if nPer ~= nPer0
        w = toeplitz(Beta.^(0:nPer-1));
        w = tril(w);
        w = bsxfun(@rdivide,w,sum(w,2));
    end
    data = w*data;
    if isinit
        data = data(2:end);
    end
    X(first:last,i) = data;
    nPer0 = nPer;
end

if length(s) > 2
    X = reshape(X,s);
end

end