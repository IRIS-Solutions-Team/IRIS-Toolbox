function varargout = autoexog(this, varargin)
% autoexog  Get or set pairs of names in dynamic and steady autoexog.
%
% Syntax fo getting autoexogen pairs of names
% ============================================
%
%     A = autoexog(M)
%
%
% Syntax fo setting autoexog pairs of names
% ==========================================
%
%     M = autoexog(M, A)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `A` [ struct ] - `A` contains two substructs, `.Dynamic` and
% `.Steady`. Each field in the substructs defines a variable/shock pair (in
% `.Dynamic`), or a variable/parameter pair (in `.Steady`).
%
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with updated definitions of autoexog pairs
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

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    a = struct( 'Dynamic', struct( ), 'Steady', struct( ) );
    [~, ~, a.Dynamic] = model.component.Pairing.getAutoexog(this.Pairing.Autoexog.Dynamic, this.Quantity);
    [~, ~, a.Steady] = model.component.Pairing.getAutoexog(this.Pairing.Autoexog.Steady, this.Quantity);
    varargout{1} = a;
else
    a = varargin{1};
    if isfield(a, 'Dynamic')
        p = this.Pairing.Autoexog.Dynamic;
        setType(a.Dynamic, p, 'dynamic');
        this.Pairing.Autoexog.Dynamic = p;
    end
    if isfield(a, 'Steady')
        p = this.Pairing.Autoexog.Steady;
        setType(a.Steady, p, 'steady');
        this.Pairing.Autoexog.Steady = p;
    end
    varargout{1} = this;
end

return




    function p = setType(a, p, type)
            lsExog = fieldnames(a);
            lsExog = lsExog(:).';
            lsEndog = struct2cell(a);
            lsEndog = lsEndog(:).';
            p = model.component.Pairing.setAutoexog(p, type, this.Quantity, lsExog, lsEndog);
    end
end
