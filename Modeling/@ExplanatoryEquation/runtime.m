function this = runtime(this, dataBlock, context)
% runtime  Prepare or reset runtime information
%
% Backend IRIS method
% No help provided

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
        this__.Runtime.PosResidual = textual.locate(this__.ResidualName, dataBlock.Names);
        if strcmp(context, 'simulate') 
            nameToUpdate = [this__.LhsName, this__.ResidualName];
        elseif strcmp(context, 'regress')
            nameToUpdate = this__.ResidualName;
        else
            nameToUpdate = "";
        end

        % 
        % Update DataBlock after simulation or estimation
        %
        this__.Runtime.PosUpdateFrom = textual.locate(nameToUpdate, this__.PlainDataNames);
        this__.Runtime.PosUpdateTo = textual.locate(nameToUpdate, dataBlock.Names);
        this(eqn) = this__;
    end
end

end%

