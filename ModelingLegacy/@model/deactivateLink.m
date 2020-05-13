function this = deactivateLink(this, varargin)
% deactivateLink  Deactivate dynamic links for selected LHS names
%{
% Syntax
%--------------------------------------------------------------------------
$
%
%     M = deactivateLink(M, list)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object in which some dynamic links, i.e.
% [`!links`](irislang/links), will be deactivated.
%
%
% __`list`__ [ char | cellstr | string ] 
% > List of LHS names whose dynamic links will be deactivated.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object with dynamic links [`!links`](irislang/links) deactivated;
% these can be reactivated again by [`activate`](#activate).
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

this = operateActivationStatusOfLink(this, -1, varargin{:});

end%

