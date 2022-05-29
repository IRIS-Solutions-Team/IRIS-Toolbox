% group  Retrieve VAR object from panel VAR for specified group of data
%{
% Syntax
%--------------------------------------------------------------------------
%
%     v = group(v, groupID)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`v`__ [ VAR ] 
%
%>    Panel VAR object estimated on multiple groups of data.
%
%
% __`groupID`__ [ string ] 
% 
%>    Requested group name; must be one of the names specified when the
%>    panel VAR object was constructed using the function [`VAR`](VAR/VAR).
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`v`__ [ VAR ] 
%
% > VAR object for the `K`-th group of data.
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
% Create and estimate a panel VAR for three variables, `x`, `y`, `z`, and
% three countries, `US`, `EU`, `JA`. Then, retrieve a plain VAR for an
% individual country.
%
%     v = VAR({'x', 'y', 'z'}, {'US', 'EU', 'JA'});
%     v = estimate(v, d, range, 'fixedEffect=', true);
%     vi_us = group(v, 'US');
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [this, groupName] = group(this, groupID)

persistent pp
if isempty(pp)
    pp = extend.InputParser('@VAR/group');
    addRequired(pp, 'v', @(x) isa(x, 'VAR') && x.IsPanel);
    addRequired(pp, 'groupID', @(x) isstring(x) || ischar(x) || validate.numericScalar(x) || islogical(x));
end
parse(pp, this, groupID);

%--------------------------------------------------------------------------

if isstring(groupID) || ischar(groupID)
    name = string(groupID);
    groupID = this.GroupNames==name;
    if ~any(groupID)
        locallyDoesNotExist(this, name);
    end
end

if islogical(groupID)
    groupID = find(groupID);
end

if numel(groupID)~=1
    exception.error([
        "VAR:MutlipleGroupReference"
        "Only one group can be extracted."
    ]);
end

try
    groupName = this.GroupNames(groupID);
    this.IxFitted = this.IxFitted(groupID, :, :);
    this.K = this.K(:, groupID, :);
    this.X0 = this.X0(:, groupID, :);
    nx = this.NumExogenous;
    pos = (groupID-1)*nx + (1:nx);
    this.J = this.J(:, pos, :);

    %
    % Reset GroupNames to empty only after the coefficient matrices have
    % been reduced to a single group; otherwise set.GroupNames would throw
    % an error.
    %
    this.GroupNames = string.empty(1, 0);
catch
    locallyDoesNotExist(this, groupID);
end

end%

%
% Local Functions
%

function locallyDoesNotExist(this, groupID)
    %(
    exception.error([
        "VAR:InvalidGroupReference"
        "This group does not exist in the %s object: %s"
    ], class(this), string(groupID));
    %)
end%

