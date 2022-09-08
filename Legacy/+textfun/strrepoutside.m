function Str = strrepoutside(Str,Find,Replace,varargin)
% strrepoutside  Replace substring outside brackets.
%
% Syntax
% =======
%
%     S = textfun.strrepoutside(S,Find,Replace,Brackets,Brackets,...)
%
% Input arguments
% ================
%
% * `S` [ char | cellstr ] - Original text string or cellstr.
%
% * `Find` [ char | cellstr ] - Text string whose occurences will be
% replaced with `replace`.
%
% * `Replace` [ char | cellstr ] - Text string that will replace `find`.
%
% * `Brackets` [ char ] - Text string with the opening and closing
% bracket; the string replacement will only be made outside all of the
% specified brackets.
%
% Output arguments
% =================
%
% * `S` [ char | cellstr ] - Modified text string.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% Handle cellstr on input.
nStr = numel(Str);
if iscellstr(Str)
    for i = 1 : nStr
        Str{i} = textfun.strrepoutside(Str{i},Find,Replace,varargin{:});
    end
    return
end

%--------------------------------------------------------------------------

nBrk = numel(varargin);
brks = zeros(nBrk,nStr);
for i = 1 : nBrk
    brks(i,strfind(Str,varargin{i}(1))) = 1;
    brks(i,strfind(Str,varargin{i}(2))) = -1;
end
ixOutside = all(cumsum(brks,2) == 0,1);
insideContent = Str(~ixOutside);
Str(~ixOutside) = char(1);
Str = strrep(Str,Find,Replace);
Str(~ixOutside) = insideContent;

end
