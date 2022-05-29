function this = runtime(this, dataBlock, context)
% runtime  Prepare or reset runtime information
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

if nargin==1
    for eqn = 1 : numel(this)
        this(eqn).Runtime = struct( );
    end
else
    for eqn = 1 : numel(this)
        this__ = this(eqn);
        this__.Runtime.PosResidualInDataBlock = [ ];
        this__.Runtime.PosUpdateInPlainData = [ ];
        this__.Runtime.PosUpdateInDataBlock = [ ];
        this__.Runtime.PosPlainData = textual.locate(this__.VariableNames, dataBlock.Names);
        if ~this__.IsIdentity
            this__.Runtime.PosResidualInDataBlock = textual.locate(this__.ResidualName, dataBlock.Names);
        end
        if startsWith(context, "simulate", "ignoreCase", true)
            this__.Runtime.PosUpdateInPlainData = textual.locate(this__.LhsName, this__.VariableNames);
            this__.Runtime.PosUpdateInDataBlock = textual.locate(this__.LhsName, dataBlock.Names);
        end
        this(eqn) = this__;
    end
end

end%

