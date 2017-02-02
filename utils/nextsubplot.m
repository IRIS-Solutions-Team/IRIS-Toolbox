function h = nextsubplot(x,y)

ch = get(gcf,'children');
n = 1;
for i = ch(:).'
  if ~strcmp(get(i,'tag'),'legend')
    n = n + 1;
  end
end
h = subplot(x,y,n);

end