function this = runtime(this, dataBlock, context)
% runtime  Prepare or reset runtime information
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numEquations = numel(this);
if nargin==1
    for eqn = 1 : numel(this)
        this(eqn).Runtime = struct( );
    end
else
    for eqn = 1 : numel(this)
        this__ = this(eqn);
        this__.Runtime.PosPlainData = textual.locate(this__.PlainDataNames, dataBlock.Names);
        residualName__ = this__.ResidualName;
        if this__.IsIdentity
            this__.Runtime.PosResidualInPlainData = double.empty(1, 0);
            this__.Runtime.PosResidualInDataBlock = double.empty(1, 0);
        else
            this__.Runtime.PosResidualInPlainData = textual.locate(residualName__, this__.PlainDataNames);
            this__.Runtime.PosResidualInDataBlock = textual.locate(residualName__, dataBlock.Names);
        end
        if strcmp(context, 'simulate') 
            namesToUpdate = [this__.LhsName, residualName__];
        elseif strcmp(context, 'regress')
            namesToUpdate = this__.ResidualName;
        else
            namesToUpdate = string.empty(1, 0);
        end

        % 
        % Update DataBlock after simulation or estimation
        %
        if isempty(namesToUpdate)
            this__.Runtime.PosUpdateInPlainData = double.empty(1, 0);
            this__.Runtime.PosUpdateInDataBlock = double.empty(1, 0);
        else
            this__.Runtime.PosUpdateInPlainData = textual.locate(namesToUpdate, this__.PlainDataNames);
            this__.Runtime.PosUpdateInDataBlock = textual.locate(namesToUpdate, dataBlock.Names);
        end
        this(eqn) = this__;
    end
end

end%

