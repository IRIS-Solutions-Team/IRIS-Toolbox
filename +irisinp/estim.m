classdef estim < irisinp.generic
    properties
        ReportName = 'Estimation Struct';  
        Value = NaN;
        Omitted = @error;
        ValidFn = @(x, state) isstruct(x) && ~isempty(fieldnames(x)) ...
            && irisinp.estim.myvalidate(x, state)
    end
    
    
    methods (Static)
        function flag = myvalidate(x, state)
            func = state.Func;
            ix = strcmp(func.InpClassName, 'modelSolved');
            m = state.Func.Inp{ix}.Value;
            [lsValidNames, lsInvalidNames] = verifyEstimStruct(m, x);
            flag = true;
            if ~isempty(lsInvalidNames)
                utils.warning('inp:estim:myvalidate', ...
                    'This is not a valid name in estimation struct: ''%s''.', ...
                    lsInvalidNames{:});
                flag = false;
            end
            if isempty(lsValidNames)
                utils.warning('inp:estim:myvalidate', ...
                    'No valid names found in estimation struct.');
                flag = false;
            end
        end
    end
end
