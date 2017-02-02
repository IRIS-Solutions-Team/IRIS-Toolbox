classdef Helper
    properties (Constant)
        LABEL_EXPRN_PATTERN = '([''"]).*?\1'
    end
    
    
    
    
    methods (Static)
        function [exprn, label] = parseLabelExprn(list)
            import parser.Helper;
            isCharInp = ischar(list);
            if isCharInp
                list = { list };
            end
            nList = length(list);
            exprn = cell(1,nList);
            list = strtrim(list);
            [label, last] = ...
                regexp(list, Helper.LABEL_EXPRN_PATTERN, ...
                'match', 'end', 'once');
            for i = 1 : nList
                if ~isempty( last{i} )
                    exprn{i} = list{i}(last{i}+1:end);
                    label{i} = label{i}(2:end-1);
                else
                    exprn{i} = list{i};
                    label{i} = '';
                end
            end
            exprn = strtrim(exprn);
            if isCharInp
                exprn = exprn{1};
                label = label{1};
            end
            
        end
    end
end
