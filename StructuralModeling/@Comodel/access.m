% access  Access properties of Comodel objects
%
%{ Syntax
%--------------------------------------------------------------------------
%
%     output = access(model, what)
%
%
% Input Arguments
%--------------------------------------------------------------------------
%
% __`model`__ [ Model ]
%>
%>    Model objects that will be queried about `what`.
%
%
% __`what`__ [ string ]
%>
%>    One of the valid queries listed in the below.
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`output`__ [ * ]
%>
%>    Response to the query about `what`.
%
%
% Valid Queries
%--------------------------------------------------------------------------
%
% __`"measurement-variables"`__
%
% __`"transition-variables"`__
%
% __`"shocks"`__
%
% __`"parameters"`__
%
% __`"exogenous-variables"`__
%
%> Names of all measurement variables, or transition variables, or shocks,
%> or parameters, or exogenous variables in order of their apperance in the
%> declaration sections of the source model file(s).
%
%
% Description
%--------------------------------------------------------------------------
%
%
% Example
%--------------------------------------------------------------------------
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [output, beenHandled] = access(this, input, opt)

arguments
    this (1, :) Comodel
    input (1, 1) string

    opt.Error (1, 1) logical = true
end
%}
% >=R2019b


% <=R2019a
%(
function [output, beenHandled] = access(this, input, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Error", true);
end
parser(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


%
% Preprocess the input query
%
what = input;
what = erase(what, ["_", "-", ":", "."]);

[output, beenHandled] = access@Model(this, input, "error", false);
if beenHandled, return, end

output = [ ];
beenHandled = true;


%==========================================================================
if lower(what)==lower("costdValues")
    ptr = this.Pairing.Costds;
    ptr(ptr==0) = [];
    values = permute(this.Variant.Values(1, ptr, :), [2, 3, 1]);
    names = textual.stringify(this.Quantity.Name(ptr));
    output = locallyCreateStruct(names, values);


elseif lower(what)==lower("costds")
    ptr = this.Pairing.Costds;
    ptr(ptr==0) = [];
    output = textual.stringify(this.Quantity.Name(ptr));


else
    beenHandled = false;

end
%==========================================================================


if ~beenHandled && opt.Error
    exception.error([
        "Comodel:InvalidAccessQuery"
        "This is not a valid query into Comodel objects: %s "
    ], input);
end

end%

%
% Local functions
%

function output = locallyCreateStruct(names, values)
    %(
    names = reshape(string(names), 1, []);
    output = struct();
    for i = 1 : numel(names)
        output.(names(i)) = values(i, :);
    end
    %)
end%

