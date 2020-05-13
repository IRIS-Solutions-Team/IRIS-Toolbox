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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

if nargin<3
    d = struct( );
end

persistent pp
if isempty(pp)
    pp = extend.InputParser('model/addToDatabank');
    pp.KeepUnmatched = true;
    addRequired(pp, 'what', @(x) ischar(x) || iscellstr(x) || isa(x, 'string'));
    addRequired(pp, 'model', @(x) isa(x, 'model'));
    addRequired(pp, 'databank', @validate.databank);
end
parse(pp, what, this, d);

%--------------------------------------------------------------------------

what = strtrim(cellstr(what));
for i = 1 : numel(what)
    what__ = what{i};
    lenWhat__ = length(what__);
    if strncmpi(what__, 'Parameters', min(10, lenWhat__))
        addParameters( );
    elseif strncmpi(what__, 'Std', min(3, lenWhat__))
        addStd( );
    elseif strncmpi(what__, 'NonzeroCorr', min(11, lenWhat__))
        addZeroCorr = false;
        addCorr(addZeroCorr);
    elseif strncmpi(what__, 'Corr', min(4, lenWhat__))
        addZeroCorr = true;
        addCorr(addZeroCorr);
    elseif strncmpi(what__, 'Shock', min(5, lenWhat__))
        addShocks( );
    elseif strncmpi(what__, 'Default', min(7, lenWhat__))
        addParameters( );
        addStd( );
        addZeroCorr = false;
        addCorr(addZeroCorr);
    else
        throw( ...
            exception.Base('Model:InvalidQuantityType', 'error'), ...
            what__ ...
        );
    end
end

return


    function addParameters( )
        ixp = this.Quantity.Type==TYPE(4);
        for ii = find(ixp)
            name__ = this.Quantity.Name{ii};
            value__ = permute(this.Variant.Values(:, ii, :), [1, 3, 2]);
            d.(name__) = value__;
        end
    end%


    function addStd( )
        listOfStdNames = getStdNames(this.Quantity);
        ne = numel(listOfStdNames);
        vecStd = this.Variant.StdCorr(:, 1:ne, :);
        for ii = 1 : ne
            name__ = listOfStdNames{ii};
            value__ = permute(vecStd(1, ii, :), [2, 3, 1]);
            d.(name__) = value__;
        end
    end%


    function addCorr(addZeroCorr)
        ne = nnz(this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32));
        namesCorr = getCorrNames(this.Quantity);
        valuesCorr = this.Variant.StdCorr(:, ne+1:end, :);
        inxCorrAllowed = this.Variant.IndexOfStdCorrAllowed(ne+1:end);
        namesCorr = namesCorr(inxCorrAllowed);
        valuesCorr = valuesCorr(:, inxCorrAllowed, :);
        if ~addZeroCorr
            posToRemove = find(all(valuesCorr==0, 3));
            valuesCorr(:, posToRemove, :) = [ ];
            namesCorr(posToRemove) = [ ];
        end
        for ii = 1 : numel(namesCorr)
            name__ = namesCorr{ii};
            value__ = permute(valuesCorr(1, ii, :), [2, 3, 1]);
            d.(name__) = value__;
        end
    end%


    function addShocks( )
        d = shockdb(this, d, varargin{:});
    end%
end%

