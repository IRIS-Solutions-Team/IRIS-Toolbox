function this = activateLink(this, varargin)
% activateLink  (Re)Activate dynamic links for selected LHS names
%{
% Syntax
%--------------------------------------------------------------------------
$
%
%     M = activateLink(M, list)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object in which some dynamic links, i.e.
% [`!links`](irislang/links), will be (re)activated.
%
%
% __`list`__ [ char | cellstr | string ] 
% > List of LHS names whose dynamic links will be (re)activated.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
%
% __`model`__ [ Model ] 
% > Model object with dynamic links [`!links`](irislang/links)
% (re)activated.
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

this = operateActivationStatusOfLink(this, 1, varargin{:});

end%

