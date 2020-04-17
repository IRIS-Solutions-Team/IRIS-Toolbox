function this = defineDependenTerm(this, varargin)
% defineDependenTerm  Define dependent term in Explanatory object
%{
% ## Syntax ##
%
%
%     expy = defineDependenTerm(expy, name, ~transform)
%     expy = defineDependenTerm(expy, position, ~transform)
%     expy = defineDependenTerm(expy, expression)
%
%
% ## Input Arguments ##
%
%
% __`expy`__ [ Explanatory ]
% >
% Explanatory object whose dependent (LHS) variable will be
% defined; `expy` needs to have its `VariableNames` defined before calling
% `defineDependenTerm(...)`.
%
%
% __`name`__ [ string ]
% >
% Name of the dependent (LHS) varible; the name must be from the list of
% `VariableNames` in the Explanatory object `expy`.
%
%
% __`position`__ [ numeric ]
% >
% Pointer to a name from the `VariableNames` list in the
% Explanatory object `expy`.
%
%
% __`expression`__ [ string ]
% > 
% Expression to define the dependent (LHS) term. The `expression` may
% involved a variable from the `VariableNames` list in the
% Explanatory object `expy` and one of the tranform functions (see
% `transform`).
%
%
% __`~transform=[ ]`__ [ empty | `'diff'` | `'log'` | `'difflog'` ]
% >
% Tranform function applied to the depedent (LHS) variable; the `transform`
% function can only be specified when the dependent variable is entered as
% a `name` or a `position`, not as an `expression`; if not specified, no
% transformation is applied.
%
%
% ## Output Arguments ##
%
%
% __`expy`__ [ Explanatory ]
% >
% The Explanatory object with a dependent (LHS) term defined.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('Explanatory.defineDependenTerm');
    addRequired(pp, 'expy', @(x) isa(x, 'Explanatory'));
end
parse(pp, this);

%--------------------------------------------------------------------------

term = regression.Term(this, varargin{:}, "Type=", ["Pointer", "Name", "Transform"]);
this.DependentTerm = term;
checkNames(this);

end%

