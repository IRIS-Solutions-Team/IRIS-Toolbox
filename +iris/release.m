function [c, n] = release( )
% iris.release  [IrisToolbox] release currently running
%{
% ## Syntax ##
%
%     iris.release
%     r = iris.release( )
%
%
% ## Output Arguments ##
%
% __`r`__ [ char ] -
% Char vector describing the [IrisToolbox] release currently running.
%
%
% ## Description ##
%
% The release string is the distribution date in a `yyyymmdd` format. The
% `iris.release` function is equivalent to calling `iris.get('Release')`.
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

% [IrisToolbox] release is permanently stored in the root Contents.m file,
% and is accessible through the Matlab ver( ) command. In each session, the
% version is refreshed by `iris.Configuration( )`.

c = iris.get('Release');
if nargout>1
    n = sscanf(c, '%g', 1);
end

end%

