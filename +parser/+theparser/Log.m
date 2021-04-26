classdef Log ...
    < parser.theparser.Generic

    properties (Constant)
        ALLBUT_KEYWORD = "!all-but"
    end


    methods
        function  logNames = parse(this, code)
            except = false;
            if contains(code, this.ALLBUT_KEYWORD)
                except = true;
                code = erase(code, this.ALLBUT_KEYWORD);
            end
            logNames = regexp(code, "\<[a-zA-Z]\w*\>", "match");
            if except
                logNames = Except(logNames);
            end
        end%


        function precheck(this, ~, blocks)
            inxPresent = contains(string(blocks), this.ALLBUT_KEYWORD);
            if any(inxPresent) && ~all(inxPresent)
                exception.error([
                    "Parser:InconsistentAllBut"
                    "Keyword !all-but must be used consistently in either all or none of the !log-variables declaration blocks."
                ]);
            end
        end%
    end
end

