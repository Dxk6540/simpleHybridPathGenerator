classdef cSimplePathPattern < handle
    %UNTITLED2 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
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









