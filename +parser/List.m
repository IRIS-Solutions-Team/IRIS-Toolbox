classdef List < handle
    properties (Constant)
        DELIMITER = '`';
        SUFFIX_PATTERN = '\w+';
        LIST_PATTERN = [ ...
            '!list\(\s*(', ...
            parser.List.DELIMITER, ...
            parser.List.SUFFIX_PATTERN, ...
            ')\s*\)', ...
        ];
        WRAP = 75;
    end
    
    
    methods (Static)
        function c = parse(c)
            FN_REPLACE = @replace; %#ok<NASGU>
            this = parser.List;
            c = regexprep(c, this.LIST_PATTERN, '${FN_REPLACE($1)}');
            c = regexprep(c, [this.DELIMITER, this.SUFFIX_PATTERN], '');
            return 
            
            function listNames = replace(c1)
                listNames = cell.empty(1, 0);
                listNames = regexp(c, ['\w+', c1], 'match');
                listNames = strrep(listNames, c1, '');
                listNames = unique(listNames, 'stable');
                listNames = textfun.delimlist(listNames, 'Wrap=', this.WRAP);
            end%
        end%
    end
end
