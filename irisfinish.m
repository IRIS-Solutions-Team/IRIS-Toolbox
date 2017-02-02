function irisfinish(varargin)
% irisfinish  Close the current IRIS session.
%
% Syntax
% =======
%
%     irisfinish
%     irisfinish -shutup
%
% Description
% ============
%
% This function removes all IRIS subfolders from the temporary Matlab
% search path, and clears persistent variables in some of the backend
% functions. A short message is displayed with the list of subfolders
% removed from the path unless you call use the option `-shutup`. Note that
% the IRIS root folder stays on the permanent Matlab path.
%
% Example
% ========

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

shutup = any(strcmpi(varargin,'-shutup'));

% Clear container.
try %#ok<TRYNC>
   clear(container( ));
end

% Clear optional input argument struct.
munlock('passvalopt');
clear('passvalopt');

% Clear iris config master file.
munlock('irisconfigmaster');
clear('irisconfigmaster');

% Clear Matlab path.
removed = irispathmanager('removeCurrentSubs');

if shutup
   return
end

% Display report on subfolders removed.
if ~isempty(removed)
   fprintf('\n\tThese IRIS subfolders have been removed from Matlab path:');
   fprintf('\n\t* %s',removed{:});
   fprintf('\n\n');
end

end
