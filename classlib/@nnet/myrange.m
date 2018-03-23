function Range = myrange(This,InData,Range)

% myrange [Not a public function]
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if isinf(Range)
	if isstruct(InData)
		inVar = cellfun(@(x) x{1}, ...
			regexp(This.Inputs,'\{[-\+]?\d*}','split'), ...
			'UniformOutput', false) ;
        outVar = cellfun(@(x) x{1}, ...
			regexp(This.Outputs,'\{[-\+]?\d*}','split'), ...
			'UniformOutput', false) ;
        Var = [inVar,outVar] ;
		Range = dbrange(InData,Var,'startDate=','minrange','endDate=','minrange') ;
	else
		Range = range(InData) ;
	end
end

end