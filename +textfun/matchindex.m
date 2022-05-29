function [Ind,Match,Tkn] = matchindex(List,Ptn)

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

if isstruct(List)
   List = fieldnames(List);
end

%--------------------------------------------------------------------------

if ~iscell(List)
   List = {List};
end

if isempty(Ptn)
   Ind = false(size(List));
   Match = { };
   Tkn = { };
   return
end

if Ptn(1) ~= '^'
   Ptn = ['^',Ptn];
end

if Ptn(end) ~= '$'
   Ptn = [Ptn,'$'];
end

if nargout > 2
   [Match,Tkn] = regexp(List,Ptn,'once','match','tokens');
else
   Match = regexp(List,Ptn,'once','match');
end

Ind = ~cellfun(@isempty,Match);
Match = Match(Ind);

if nargout > 2
   Tkn = Tkn(Ind);
end

end
