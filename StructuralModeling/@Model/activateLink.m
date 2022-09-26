%{
% 
% # `activateLink` ^^(Model)^^
% 
% {== Activate dynamic links for selected LHS names ==}
% 
% 
% ## Syntax 
% 
%         M = activateLink(M, list)
% 
% 
% ## Input arguments 
% 
% __`model`__ [ Model ] 
% > 
% > Model object in which some dynamic links, i.e.
% >[`!links`](irislang/links), will be (re)activated.
% > 
% 
% __`list`__ [ char | cellstr | string ] 
% > 
% > List of LHS names whose dynamic links will be (re)activated.
% > 
% 
% ## Output arguments 
% 
% __`model`__ [ Model ] 
% > 
% > Model object with dynamic links [`!links`](irislang/links)
% > (re)activated.
% > 
% 
% ## Options 
% 
% __`zzz=default`__ [ zzz | ___ ]
% > 
% > Description
% > 
% 
% 
% ## Description 
% 
% 
% 
% ## Examples
% 
% ```matlab
% ```
% 
%}
% --8<--


function this = activateLink(this, varargin)

this = operateActivationStatusOfLink(this, 1, varargin{:});

end

