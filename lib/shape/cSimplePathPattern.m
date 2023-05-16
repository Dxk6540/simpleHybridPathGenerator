classdef cSimplePathPattern < handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        filename_
        fid_
        curMode_
        draw_
        experiment_
        alternation_
    end
    
    methods
        function obj = cSimplePathPattern(filename)
            obj.filename_ = filename;
        end % cPathGen(filename)
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% file control %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              
        ret = openFile(obj);
        
        ret = closeFile(obj);
    end
end









