function this = changeLogStatus(this, newStatus, varargin)
% changeLogStatus  Change log status of model variables
%
% ## Syntax for Changing Log Status ##
%
%     model = changeLogStatus(model, newStatus, namesToChange)
%     model = changeLogStatus(model, newStatus, name, name, ...)
%     model = changeLogStatus(model, newStatusStruct)
%
%
% ## Input Arguments ##
%
% __`model`__  [ Model ] – 
% Model object within which the log status of variables will be changed.
%
% __`newStatus`__ [ `true` | `false` ] – 
% New log status to which the selected variables will be changed.
%
% __`namesToChange`__ [ char | cellstr | string | `@all` ] – 
% List of variable names whose log status will be changed; `@all` means all
% measurement, transition and exogenous variables.
%
% __`name`__ [ char | string ] – 
% Variable name whose log status will be changed.
%
% _`newStatusStruct`__ [ struct ] –
% Struct with fields named after the model variables, each assigned `true`
% or `false` for its new log status.
%
%
% ## Output Arguments ##
% 
% __`status`__ [ logical ] – 
% Logical vector with the log status of the selected variables.
%
% __`model`__ [ Model ] – 
% Model object in which the log status of the selected variables has been
% changed to `newStatus`.
%
%
% ## Description ##
%
%
% ## Example ##
%
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

persistent parser
if isempty(parser)
    parser = extend.InputParser('Model.changeLogStatus');
    addRequired(parser, 'model', @(x) isa(x, 'Model'));
    addRequired(parser, 'newStatus', @(x) isstruct(x) || Valid.logicalScalar(x));
    addRequired(parser, 'namesToChange', @validateNamesToChange);
end
parse(parser, this, newStatus, varargin);

typesAllowed = { TYPE(1), TYPE(2), TYPE(5) };

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
        inxOfVariables = getIndexByType(this.Quantity, typesAllowed{:});
        namesOfVariables = this.Quantity(inxOfVariables);
        namesToChange = fieldnames(newStatus);
        newStatus = struct2cell(newStatus);
        [namesToChange, pos] = intersect(namesToChange, namesOfVariables);
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


function flag = validateNamesToChange(input)
    if isempty(input)
        flag = true;
        return
    elseif numel(input)==1 && isequal(input{1}, @all)
        flag = true;
        return
    elseif numel(input)==1 && Valid.list(input{1})
        flag = true;
        return
    elseif iscellstr(input) 
        flag = true;
        return
    end
    flag = false;
end%


