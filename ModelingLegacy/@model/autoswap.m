function varargout = autoswap(this, varargin)
% autoswap  Inquire about or assign autoswap pairs
%
% __Syntax for Inquiring About Autoswap Pairs__
%
%     a = autoswap(model)
%
%
% __Syntax for Assigning Autoswap Pairs__
%
%     model = autoswap(model, a)
%
%
% __Input Arguments__
%
% __`model`__ [ Model ] –
% Model object that will be inquired about autoswap pairs or assigned new
% autoswap pairs.
%
% __`a`__ [ AutoswapStruct ] –
% An AutoswapStruct object containing two substructs, `.Simulate` and
% `.Steady`. Each field in the substructs defines a variable/shock pair (in
% `.Simulate`), or a variable/parameter pair (in `.Steady`).
%
%
% __Output Arguments__
%
% __`model`__ [ Model ] –
% Model object with the definitions of autoswap pairs newly assigned.
%
%
% __Description__
%
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isempty(varargin)
    % __Get Autoswap Structure__
    auto = model.component.AutoswapStruct( );
    [~, ~, auto.Simulate] = model.component.Pairing.getAutoswap(this.Pairing.Autoswap.Simulate, this.Quantity);
    [~, ~, auto.Steady] = model.component.Pairing.getAutoswap(this.Pairing.Autoswap.Steady, this.Quantity);
    varargout{1} = auto;

else
    % __Set Autoswap Structure__
    auto = varargin{1};

    % Legacy structure
    if ~isfield(auto, 'Simulate') && isfield(auto, 'dynamic')
        auto.Simulate = auto.dynamic;
    end
    if ~isfield(auto, 'Steady') && isfield(auto, 'steady')
        auto.Steady = auto.steady;
    end
    if isfield(auto, 'Simulate') 
        p = this.Pairing.Autoswap.Simulate;
        setType(auto.Simulate, p, 'Simulate');
        this.Pairing.Autoswap.Simulate = p;
    end
    if isfield(auto, 'Steady')
        p = this.Pairing.Autoswap.Steady;
        setType(auto.Steady, p, 'Steady');
        this.Pairing.Autoswap.Steady = p;
    end
    varargout{1} = this;

end

return


    function p = setType(auto, p, type)
            namesOfExogenized = fieldnames(auto);
            namesOfExogenized = transpose(namesOfExogenized(:));
            namesOfEndogenized = struct2cell(auto);
            namesOfEndogenized = transpose(namesOfEndogenized(:));
            p = model.component.Pairing.setAutoswap( p, type, this.Quantity, ...
                                                     namesOfExogenized, namesOfEndogenized );
    end%
end%

