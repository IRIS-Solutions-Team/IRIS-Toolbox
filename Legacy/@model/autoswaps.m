function varargout = autoswaps(this, varargin)

if isempty(varargin)
    % ## Get Autoswap Structure ##
    auto = model.AutoswapStruct( );
    [~, ~, auto.Simulate] = model.Pairing.getAutoswaps(this.Pairing.Autoswaps.Simulate, this.Quantity);
    [~, ~, auto.Steady] = model.Pairing.getAutoswaps(this.Pairing.Autoswaps.Steady, this.Quantity);
    varargout{1} = auto;

else
    % ## Set Autoswap Structure ##
    auto = varargin{1};

    % Legacy structure
    if ~isfield(auto, 'Simulate') && isfield(auto, 'dynamic')
        auto.Simulate = auto.dynamic;
    end
    if ~isfield(auto, 'Steady') && isfield(auto, 'steady')
        auto.Steady = auto.steady;
    end
    if isfield(auto, 'Simulate') 
        p = this.Pairing.Autoswaps.Simulate;
        locallySetType(auto.Simulate, p, 'Simulate');
        this.Pairing.Autoswaps.Simulate = p;
    end
    if isfield(auto, 'Steady')
        p = this.Pairing.Autoswaps.Steady;
        locallySetType(auto.Steady, p, 'Steady');
        this.Pairing.Autoswaps.Steady = p;
    end
    varargout{1} = this;

end

return

    function p = locallySetType(auto, p, type)
            namesExogenized = fieldnames(auto);
            namesExogenized = transpose(namesExogenized(:));
            namesEndogenized = struct2cell(auto);
            namesEndogenized = transpose(namesEndogenized(:));
            p = model.Pairing.setAutoswaps( ...
                p, type, this.Quantity ...
                , namesExogenized, namesEndogenized ...
            );
    end%
end%

