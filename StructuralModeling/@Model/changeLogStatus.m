% changeLogStatus  Change log status of model variables
%{
% ## Syntax for Changing Log Status ##
%
%     model = changeLogStatus(model, newStatus, namesToChange)
%     model = changeLogStatus(model, newStatus, name, name, ...)
%     model = changeLogStatus(model, newStatusStruct)
%
%
% ## Input Arguments ##
%
% **`model`**  [ Model ] - 
% Model object within which the log status of variables will be changed.
%
% **`newStatus`** [ `true` | `false` ] - 
% New log status to which the selected variables will be changed.
%
% **`namesToChange`** [ char | cellstr | string | `@all` ] - 
% List of variable names whose log status will be changed; `@all` means all
% measurement, transition and exogenous variables.
%
% **`name`** [ char | string ] - 
% Variable name whose log status will be changed.
%
% **`newStatusStruct`** [ struct ] -
% Struct with fields named after the model variables, each assigned `true`
% or `false` for its new log status.
%
%
% ## Output Arguments ##
% 
% **`status`** [ logical ] - 
% Logical vector with the log status of the selected variables.
%
% **`model`** [ Model ] - 
% Model object in which the log status of the selected variables has been
% changed to `newStatus`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team 

function this = changeLogStatus(this, newStatus, varargin)

% Parse input arguments
%(
persistent pp
if isempty(pp)
    pp = extend.InputParser('Model.changeLogStatus');
    addRequired(pp, 'model', @(x) isa(x, 'Model'));
    addRequired(pp, 'newStatus', @(x) isstruct(x) || validate.logicalScalar(x));
    addRequired(pp, 'namesToChange', @locallyValidateNamesToChange);
end
%)
parse(pp, this, newStatus, varargin);

typesAllowed = {1, 2, 5};

%--------------------------------------------------------------------------

if isstruct(newStatus)
    hereChangeLogStatusFromStruct( );
    return
end

if numel(varargin)==1
    if isequal(varargin{1}, @all)
        namesToChange = @all;
    else
        namesToChange = cellstr(varargin{1});
    end
else
    namesToChange = cellstr(varargin);
end
this.Quantity = changeLogStatus(this.Quantity, newStatus, namesToChange, typesAllowed{:});

return

    function hereChangeLogStatusFromStruct( )
        inxVariables = getIndexByType(this.Quantity, typesAllowed{:});
        namesVariables = this.Quantity(inxVariables);
        namesToChange = fieldnames(newStatus);
        newStatus = struct2cell(newStatus);
        [namesToChange, pos] = intersect(namesToChange, namesVariables);
        if isempty(namesToChange)
            return
        end
        newStatus = newStatus(pos);
        namesToChange = transpose(namesToChange(:));
        newStatus = transpose(newStatus(:));
        this.Quantity = changeLogStatus(this.Quantity, newStatus, namesToChange, typesAllowed{:});
    end%
end%

%
% Local Functions
%

function flag = locallyValidateNamesToChange(input)
    if isempty(input)
        flag = true;
        return
    elseif numel(input)==1 && isequal(input{1}, @all)
        flag = true;
        return
    elseif numel(input)==1 && validate.list(input{1})
        flag = true;
        return
    elseif iscellstr(input) 
        flag = true;
        return
    end
    flag = false;
end%

