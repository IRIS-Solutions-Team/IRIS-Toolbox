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
        function c = parse(c)
            REPLACE = @replace; %#ok<NASGU>
            this = parser.List;
            c = regexprep(c, this.LIST_PATTERN, '${REPLACE($1)}');
            c = regexprep(c, ['(?<!', this.DELIMITER, ')', this.DELIMITER, this.SUFFIX_PATTERN], '');
            return

            function c = replace(c1)
                names = cell.empty(1, 0);
                names = regexp(c, ['\w+', c1], 'match');
                names = strrep(names, c1, '');
                names = unique(names, 'stable');
                c = char(join(names, ', '));
            end%
        end%
    end
end
