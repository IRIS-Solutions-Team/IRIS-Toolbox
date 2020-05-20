classdef Element ...
    < matlab.mixin.Copyable

    properties
        Type (1, 1) rephrase.Type = rephrase.Type.VOID
        Settings (1, 1) struct = struct( )
        Content
    end


    properties (Abstract, Constant)
        CAN_BE_PARENT_TO
        CAN
end

