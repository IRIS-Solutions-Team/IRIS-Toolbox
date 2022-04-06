function TT = bardatatips(H,varargin)

if length(H) > 1
    TT = [ ];
    for h = H(:).'
        tt = grfun.bardatatips(h,varargin{:});
        TT = [TT,tt]; %#ok<AGROW>
    end
    return
end


defaults = { 
    'format', '%g', @ischar
};

[opt,varargin] = passvalopt(defaults, varargin{:});


%--------------------------------------------------------------------------

ch = get(H,'children');
xData = get(ch,'xData');
yData = get(H,'yData');
nData = size(xData,2);

TT = nan(1,nData);
for i = 1 : nData
    x = (xData(2,i) + xData(3,i))/2;
    y = yData(i);
    TT(i) = text(x,y,sprintf(opt.format,y), ...
        'horizontalAlignment','center', ...
        'verticalAlignment','bottom',varargin{:});
end

end
