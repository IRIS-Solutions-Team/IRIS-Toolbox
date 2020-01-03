function this = rename(this, varargin)
% rename  Rename temporarily model quantities
%
% ## Syntax for Renaming Model Quantities ##
%
%     M = rename(M, NamePair, NamePair, ...)
%
%
% ## Syntax for Resetting Names to Original Names ##
%
%     M = rename(M)
%
%
% ## Input Arguments ##
%
% * `M` [ model ] - Model objects whose quantities (variables, parameter,
% shocks) will be renamed.
%
% * `NamePair` [ char | string ] - Strings with two names separated by any
% non-alphanumeric character(s); the first name must be an existing name,
% the second name is the new name.
%
%
% ## Output Arguments ##
%
% * `M` [ model ] - Model object with some quantities renamed.
%
%
% ## Description ##
%
% The function allows to temporarily change the names of model quantities,
% i.e. variables, parameters and shocks. The new names will be then used
% when reading input databases, writing output databases, or returning
% named matrices. When called with only one input parameter (the model
% object), the function resets all names to their original names from the
% source model file.
%
% When specifying a renaming pair, create a string that starts with an
% exiting name (i.e. the name that is to be changed), then include one or
% more non-alphanumeric characters (i.e. any character other than a letter,
% a digit or an underscore), and then specify the new name.
%
%
% ## Example ##
%
% An existing model object contains six quantities (variables, shocks,
% parameters) with the following names:
%
%     >> get(m, 'Names')
%     ans =
%       1x6 cell array
%         {'x'}    {'y'}    {'z'}    {'eps_x'}    {'eps_y'}    {'alpha'}
%
% Use the function `rename( )` to change two of the names: `x` will change
% to `gdp` and `y` will change to `pie`:
%
%     >> m = rename(m, 'x->gdp', 'z->pie');
%
% Verify that the names have been changed:
%
%     >> get(m, 'Names')
%     ans =
%       1x6 cell array
%         {'gdp'}    {'y'}    {'pie'}    {'eps_x'}    {'eps_y'}    {'alpha'}
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    this.Quantity = resetNames(this.Quantity);
    return
end

this.Quantity = rename(this.Quantity, varargin{:});

end
