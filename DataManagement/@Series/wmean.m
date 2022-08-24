function x = wmean(this,dates,beta)

if nargin < 2
    dates = Inf;
end

if nargin < 3
    beta = 1;
end

%**************************************************************************

% Get time series data.
s = struct( );
s.type = '()';
s.subs{1} = dates;
data = subsref(this,s);

% Compute weighted average.
tmpsize = size(data);
nper = size(data,1);
data = data(:,:);
if beta ~= 1
    w = beta.^(nper-1:-1:0);
    w = w(:);
    for i = 1 : size(this.data,2)
        data(:,i) = data(:,i) .* w;
    end
    sumw = sum(w);
else
    sumw = nper;
end
x = sum(data/sumw,1);
x = reshape(x,[1,tmpsize(2:end)]);

end

