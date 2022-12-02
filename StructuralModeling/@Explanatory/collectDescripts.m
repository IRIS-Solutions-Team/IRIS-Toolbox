% collectDescripts  Collect descripts of equations
%{
% ## Syntax ##
%
%
%     descripts = collectDescripts(this)
%
%
% ## Input Arguments
%
%
% __`this`__ [ Explanatory ]
% >
% Explanatory object or array whose descripts will be returned.
%
%
% ## Output Arguments
%
%
% __`descripts`__ [ string ]
% >
% Descripts from `this` Explanatory object or array.
%
%
% ## Description
%
%
% ## Example
%
%
%}

function descripts = collectDescripts(this)

    descripts = [this.Label];

end%

