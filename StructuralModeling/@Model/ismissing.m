function [Flag,List] = ismissing(This,Inp,Range)

[~,~,List] = datarequest('init',This,Inp,Range);
Flag = ~isempty(List);

% TODO: Add check for missing exogenized variables...

end
