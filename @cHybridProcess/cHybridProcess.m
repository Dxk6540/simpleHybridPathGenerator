classdef cHybridProcess < handle
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
        function obj = cHybridProcess(filename)
            obj.filename_ = filename;
        end % cPathGen(filename)
          
        ret = openFile(obj);

    end
end









