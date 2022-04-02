classdef LoadObjectAsStructWrapper
    properties
        LoadObjectAsStruct = struct( )
    end


    methods
        function [answ, flag, query] = implementGet(this, query, varargin)
            answ = [ ];
            flag = true;
            switch lower(query)
                case 'loadobjectasstruct'
                    answ = this.LoadObjectAsStruct;
                otherwise
                    flag = false;
            end
        end
    end
end
