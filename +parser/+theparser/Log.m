classdef Log ...
    < parser.theparser.Generic

    properties (Constant)
        ALLBUT_KEYWORD = "!all-but"
    end


    methods
        function [logNames, except] = parse(this, code, logNames, except)
            if nargin<3
                logNames = string.empty(1, 0);
            end
            if nargin<4
                except = logical.empty(1, 0);
            end
            code = string(code);
            except = [except, contains(code, this.ALLBUT_KEYWORD)];
            code = erase(code, this.ALLBUT_KEYWORD);
            logNames = [ ...
                logNames ...
                , reshape(regexp(code, "\<[a-zA-Z]\w*\>", "match"), 1, []) ...
            ];
        end%


        function precheck(this, ~, blocks)
            inxPresent = contains(string(blocks), this.ALLBUT_KEYWORD);
            if any(inxPresent) && ~all(inxPresent)
                throw(exception.ParseTime([
                    "Parser:InconsistentAllBut"
                    "The keyword !all-but must be used consistently in either all or none of the !log-variables sections."
                ], 'error'));
            end
        end%
    end
end

