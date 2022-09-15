function d = addToDatabank(what, this, varargin)
% addToDatabank  Add VAR parameters to databank or create new databank
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     D = addToDatabank(What, V, ~D)
%
%
% __Input Arguments__
%
% * `What` [ char | cellstr | string ] - What VAR parameters to add:
% coefficient matrices, covariance matrix.
%
% * `V` [ VAR ] - VAR whose parameters will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the VAR parameters will be added;
% if omitted, a new databank will be created.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the VAR parameters added.
%
%
% __Description__
%
% Function `addToDatabank( )` adds all specified VAR parameters to the databank,
% `D`, as matrices with values for all parameter variants. If no input
% databank is entered, a new will be created.
%
% Specify one of the following to choose what VAR parameters to add:
%
%   * 'Coefficient' - add VAR coefficient matrices
%   * 'Cov' - add covariance matrix
%   * 'Default' - equivalent to `{'Coefficient', 'Cov'}`
%
% These can be specified as case-insensitive char, strings, or combined in
% a cellstr or a string array.
%
% Any existing databank entries whose names coincide with the field names
% for VAR parameters will be kverwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addToDatabank('Cov', v, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

persistent ip
if isempty(ip)
    ip = inputParser();
    addRequired(ip, 'What', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addRequired(ip, 'VAR', @(x) isa(x, 'VAR'));
    addOptional(ip, 'Databank', struct(), @isstruct);
end
parse(ip, what, this, varargin{:});
d = ip.Results.Databank;

%--------------------------------------------------------------------------

what = strtrim(cellstr(what));
for i = 1 : numel(what)
    ithWhat = what{i};
    lenOfIthWhat = length(ithWhat);
    if strncmpi(ithWhat, 'Coefficients', min(10, lenOfIthWhat))
        addCoefficents( );
    elseif strncmpi(ithWhat, 'Cov', min(3, lenOfIthWhat))
        addCov( );
    elseif strncmpi(ithWhat, 'Default', min(7, lenOfIthWhat))
        addCoefficients( );
        addCov( );
    else
        throw( ...
            exception.Base('VAR:InvalidQuantityType', 'error'), ...
            ithWhat ...
        );
    end
end

return

    function addCoefficients( )
        d.A_ = this.A;
        [~, d.B_] = getResidualComponents(this);
        d.K_ = this.K;
        d.J_ = this.J;
    end%


    function addCov( )
        d.Cov_ = getResidualComponents(this);
    end%
end%
