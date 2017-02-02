function c = dat2cmd(dat)

if isempty(dat)
   c = '';
end

if length(dat) > 1
   utils.error('dates','DAT2CMD only handles scalar dates.');
end

[y,p,f] = dat2ypf(dat);

if f == 0
   c = sprintf('%g',p);
else
   switch f
      case 1
         c = sprintf('yy(%g)',y);
      case 2
         c = sprintf('hh(%g,%g)',y,p);
      case 4
         c = sprintf('qq(%g,%g)',y,p);
      case 6
         c = sprintf('bb(%g,%g)',y,p);
      case 12
         c = sprintf('mm(%g,%g)',y,p);
   end
end

end