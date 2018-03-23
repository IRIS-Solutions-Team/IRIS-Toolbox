function varargout = datarequest(Req,This,Data,Range)
% datarequest  [Not a public function] Request data from database.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

% Loop over requests
ReqSplit = regexp(Req,',','split') ;
nReq = numel(ReqSplit) ;
varargout = cell(1,nReq) ;
for iReq=1:nReq
    varargout{iReq} = xxLeadLagDataExtract(Data,This.(ReqSplit{iReq}),Range) ;
end

    function Y = xxLeadLagDataExtract(Data,Names,Range)
        nVar = numel(Names) ;
        Y = [ ] ;
        % Check for leads and lags
        [LLop,Var] = regexp(Names,'\{[-\+]?\d*}','match','split') ;
        for iVar = 1:nVar
            if ~isempty(LLop{iVar})
                % Lead/lag required
                Y = [Y,Data.(Var{iVar}{1}){-str2double(LLop{iVar}{1}(2:end-1))}] ;
            else
                % No lead/lag
                Y = [Y,Data.(Var{iVar}{1})] ; %#ok<*AGROW>
            end
        end
        Y = resize(Y,Range) ;
    end

end
