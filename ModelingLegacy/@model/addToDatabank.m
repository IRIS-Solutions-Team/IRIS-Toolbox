function d = addToDatabank(what, this, d, varargin)
% addToDatabank  Add model quantities to existing or new databank 
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     d = addToDatabank(what, m, d, ...)
%     d = addToDatabank(what, m, d, range, ...)
%
%
% ## Input Arguments ##
%
% * `what` [ char | cellstr | string ] - what model quantities to add:
% parameters, std deviations, cross-correlations.
%
% * `m` [ model ] - Model object whose parameters will be added to databank
% `d`.
%
% * `d` [ struct ] - Databank to which the model parameters will be added.
%
% * `~range` [ DateWrapper ] - Date range on which time series will be
% created; needs to be specified for `Shocks`.
%
%
% ## Output Arguments ##
%
% * `d` [ struct | Dictionary | containers.Map ] -
% Databank with the model parameters added.
%
%
% ## Description ##
%
% Function `addToDatabank( )` adds all specified model quantities to the databank,
% `d`, as arrays with values for all parameter variants. If no input
% databank is entered, a new will be created.
%
% Specify one of the following to choose what model quantities to add:
%
%   * `'Parameters'` - add plain parameters (no std deviations or cross correlations)
%   * `'Std'` - add std deviations of model shocks
%   * `'NonzeroCorr'` - add nonzero cross-correlations of model shocks
%   * `'Corr'` - add all cross correlations of model shocks
%   * `'Shocks'` - add time series for model shocks
%   * `'Default'` - equivalent to `{'Parameters', 'Std', 'NonzeroCorr'}`
%
% These can be specified as case-insensitive char, strings, or combined in
% a cellstr or a string array.
%
% Any existing databank entries whose names coincide with the names of
% model parameters will be overwritten.
%
%
% ## Example ##
%
%     d = struct( );
%     d = addToDatabank('Parameters', m, d);
%
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

if nargin<3
    d = struct( );
end

persistent parser
if isempty(parser)
    parser = extend.InputParser('model/addToDatabank');
    parser.KeepUnmatched = true;
    addRequired(parser, 'what', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addRequired(parser, 'model', @(x) isa(x, 'model'));
    addRequired(parser, 'databank', @validate.databank);
end
parse(parser, what, this, d);

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
    elseif strncmpi(ithWhat, 'Shock', min(5, lenOfIthWhat));
        addShocks( );
    elseif strncmpi(ithWhat, 'Default', min(7, lenOfIthWhat))
        addParameters( );
        addStd( );
        addZeroCorr = false;
        addCorr(addZeroCorr);
    else
        throw( exception.Base('Model:InvalidQuantityType', 'error'), ...
               ithWhat );
    end
end

return


    function addParameters( )
        ixp = this.Quantity.Type==TYPE(4);
        for i = find(ixp)
            ithName = this.Quantity.Name{i};
            ithValue = permute(this.Variant.Values(:, i, :), [1, 3, 2]);
            d = hereCreateNewField(d, ithName, ithValue);
        end
    end%


    function addStd( )
        listOfStdNames = getStdNames(this.Quantity);
        ne = numel(listOfStdNames);
        vecStd = this.Variant.StdCorr(:, 1:ne, :);
        for i = 1 : ne
            ithName = listOfStdNames{i};
            ithValue = permute(vecStd(1, i, :), [2, 3, 1]);
            d = hereCreateNewField(d, ithName, ithValue);
        end
    end%


    function addCorr(addZeroCorr)
        ne = nnz(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
        namesOfCorr = getCorrNames(this.Quantity);
        valuesOfCorr = this.Variant.StdCorr(:, ne+1:end, :);
        indexOfCorrAllowed = this.Variant.IndexOfStdCorrAllowed(ne+1:end);
        namesOfCorr = namesOfCorr(indexOfCorrAllowed);
        valuesOfCorr = valuesOfCorr(:, indexOfCorrAllowed, :);
        if ~addZeroCorr
            posToRemove = find(all(valuesOfCorr==0, 3));
            valuesOfCorr(:, posToRemove, :) = [ ];
            namesOfCorr(posToRemove) = [ ];
        end
        for i = 1 : numel(namesOfCorr)
            ithName = namesOfCorr{i};
            ithValue = permute(valuesOfCorr(1, i, :), [2, 3, 1]);
            d = hereCreateNewField(d, ithName, ithValue);
        end
    end%


    function addShocks( )
        d = shockdb(this, d, varargin{:});
    end%
end%


%
% Local Functions
%


function d = hereCreateNewField(d, name, value)
    if isa(d, 'struct')
        d = setfield(d, name, value);
    elseif isa(d, 'Dictionary')
        d = store(d, name, value);
    elseif isa(d, 'containers.Map')
        d(name) = value;
    end
end%

