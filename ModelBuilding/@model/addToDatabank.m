function d = addToDatabank(what, this, varargin)
% addToDatabank  Add model quantities to databank or create new databank
%
% __Syntax__
%
% Input arguments marked with a `~` sign may be omitted.
%
%     D = addToDatabank(What, M, ~D)
%
%
% __Input Arguments__
%
% * `What` [ char | cellstr | string ] - What model quantities to add:
% parameters, std deviations, cross-correlations.
%
% * `M` [ model ] - Model object whose parameters will be added to databank
% `D`.
%
% * `~D` [ struct ] - Databank to which the model parameters will be added;
% if omitted, a new databank will be created.
%
%
% __Output Arguments__
%
% * `D` [ struct ] - Databank with the model parameters added.
%
%
% __Description__
%
% Function `addToDatabank( )` adds all specified model quantities to the databank,
% `D`, as arrays with values for all parameter variants. If no input
% databank is entered, a new will be created.
%
% Specify one of the following to choose what model quantities to add:
%
%   * 'Parameters' - add model parameters
%   * 'Std' - add std deviations of model shocks
%   * 'NonzeroCorr' - add nonzero cross-correlations of model shocks
%   * 'Corr' - add all cross correlations of model shocks
%   * 'Default' - equivalent to `{'Parameters', 'Std', 'NonzeroCorr'}`
%
% These can be specified as case-insensitive char, strings, or combined in
% a cellstr or a string array.
%
% Any existing databank entries whose names coincide with the names of
% model parameters will be overwritten.
%
%
% __Example__
%
%     d = struct( );
%     d = addToDatabank('Parameters', m, d);
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('model/addToDatabank');
    INPUT_PARSER.addRequired('What', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    INPUT_PARSER.addRequired('Model', @(x) isa(x, 'model'));
    INPUT_PARSER.addOptional('Databank', struct( ), @isstruct);
end
INPUT_PARSER.parse(what, this, varargin{:});
d = INPUT_PARSER.Results.Databank;

%--------------------------------------------------------------------------

what = strtrim(cellstr(what));
for i = 1 : numel(what)
    ithWhat = what{i};
    lenOfIthWhat = length(ithWhat);
    if strncmpi(ithWhat, 'Parameters', min(10, lenOfIthWhat))
        addParameters( );
    elseif strncmpi(ithWhat, 'Std', min(3, lenOfIthWhat))
        addStd( );
    elseif strncmpi(ithWhat, 'NonzeroCorr', min(11, lenOfIthWhat))
        addZeroCorr = false;
        addCorr(addZeroCorr);
    elseif strncmpi(ithWhat, 'Corr', min(4, lenOfIthWhat))
        addZeroCorr = true;
        addCorr(addZeroCorr);
    elseif strncmpi(ithWhat, 'Default', min(7, lenOfIthWhat))
        addParameters( );
        addStd( );
        addZeroCorr = false;
        addCorr(addZeroCorr);
    else
        throw( ...
            exception.Base('Model:InvalidQuantityType', 'error'), ...
            ithWhat ...
        );
    end
end

return


    function addParameters( )
        ixp = this.Quantity.Type==TYPE(4);
        for i = find(ixp)
            ithName = this.Quantity.Name{i};
            d.(ithName) = permute(this.Variant.Values(:, i, :), [1, 3, 2]);
        end
    end


    function addStd( )
        listOfStdNames = getStdName(this.Quantity);
        ne = numel(listOfStdNames);
        vecStd = this.Variant.StdCorr(:, 1:ne, :);
        for i = 1 : ne
            ithName = listOfStdNames{i};
            d.(ithName) = permute(vecStd(1, i, :), [2, 3, 1]);
        end
    end


    function addCorr(addZeroCorr)
        ne = nnz(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
        listOfCorrNames = getCorrName(this.Quantity);
        vecOfCorr = this.Variant.StdCorr(:, ne+1:end, :);
        indexOfCorrAllowed = this.Variant.IndexOfStdCorrAllowed(ne+1:end);
        listOfCorrNames = listOfCorrNames(indexOfCorrAllowed);
        vecOfCorr = vecOfCorr(:, indexOfCorrAllowed, :);
        if ~addZeroCorr
            posToRemove = find(all(vecOfCorr==0, 3));
            vecOfCorr(:, posToRemove, :) = [ ];
            listOfCorrNames(posToRemove) = [ ];
        end
        for i = 1 : length(listOfCorrNames)
            d.(listOfCorrNames{i}) = permute(vecOfCorr(1, i, :), [2, 3, 1]);
        end
    end
end
