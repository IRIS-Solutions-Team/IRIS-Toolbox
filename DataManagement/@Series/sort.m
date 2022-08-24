function [x,index] = sort(x,crit)

s = size(x.data);
x.data = x.data(:,:);
x.Comment = x.Comment(1,:);

switch crit
   case 'sumsq'
      [ans,index] = sort(sum(x.data.^2,1),'descend'); %#ok<*NOANS,*ASGLU>
   case 'sumabs'
      [ans,index] = sort(sum(abs(x.data),1),'descend');
   case 'max'
      [ans,index] = sort(max(x.data,[ ],1),'descend');
   case 'maxabs'
      [ans,index] = sort(max(abs(x.data),[ ],1),'descend');
   case 'min'
      [ans,index] = sort(min(x.data,[ ],1),'ascend');
   case 'minabs'
      [ans,index] = sort(min(abs(x.data),[ ],1),'ascend');
end

x.data = x.data(:,index);
x.Comment = x.Comment(index);
if length(s) > 2
    x.data = reshape(x.data,s);
    x.Comment = reshape(x.Comment,[1,s(2:end)]);
end

end

