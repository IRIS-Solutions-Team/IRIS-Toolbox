function xtickfrq2per(H,Fmt)

try
    H; %#ok<VUNUS>
catch
    H = gca( );
end

try
    Fmt; %#ok<VUNUS>
catch
    Fmt = '%.1f';
end

%--------------------------------------------------------------------------

xTick = 2*pi./get(H,'xtick');
n  = length(xTick);
xTickLabel = cell(1,n);
for i = 1 : n
    xTickLabel{i} = sprintf(Fmt,xTick(i));
end
set(H,'xticklabel',xTickLabel,'xtickmode','manual');

end