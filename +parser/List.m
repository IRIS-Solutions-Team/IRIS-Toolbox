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
    end


    methods (Static)
        function code = parse(code)
            REPLACE = @replace; %#ok<NASGU>
            this = parser.List;
            code = regexprep(code, this.LIST_PATTERN, '${REPLACE($1)}');
            code = regexprep(code, ['(?<!', this.DELIMITER, ')', this.DELIMITER, this.SUFFIX_PATTERN], '');
            return

            function c = replace(c1)
                names = regexp(code, ['\w+', c1], 'match');
                names = strrep(names, c1, '');
                names = unique(names, 'stable');
                c = char(join(names, ', '));
            end%
        end%
    end
end
