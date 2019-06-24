function varargout = autoswap(this, varargin)
% autoswap  Get or set pairs of names in dynamic and steady autoswap
%
% Syntax fo getting autoexogen pairs of names
% ============================================
%
%     A = autoswap(M)
%
%
% Syntax fo setting autoswap pairs of names
% ==========================================
%
%     M = autoswap(M, A)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `A` [ struct ] - `A` contains two substructs, `.Simulate` and
% `.Steady`. Each field in the substructs defines a variable/shock pair (in
% `.Simulate`), or a variable/parameter pair (in `.Steady`).
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with updated definitions of autoswap pairs
% of names.
%
%
% Description
% ============
%
%
% Example 
% ========
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isempty(varargin)
    auto = struct( 'Simulate', struct( ), 'Steady', struct( ) );
    [~, ~, auto.Simulate] = model.component.Pairing.getAutoswap(this.Pairing.Autoswap.Simulate, this.Quantity);
    [~, ~, auto.Steady] = model.component.Pairing.getAutoswap(this.Pairing.Autoswap.Steady, this.Quantity);
    varargout{1} = auto;
else
    auto = varargin{1};
    if isfield(auto, 'dynamic')
        auto.Simulate = auto.dynamic;
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

