classdef cHybridProcess < handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        filename_

        sPrintParam_
        sMachinParam_
        sProcessParam_
        
    end
    
    methods
        function obj = cHybridProcess(filename)
            obj.filename_ = filename;
            obj.sPrintParam_ = obj.getDefaultPrintingParam();
            obj.sMachinParam_ = obj.getDefaultMachiningParam();
            obj.sProcessParam_ = obj.getDefaultProcessParam();
        end % cPathGen(filename)
        
        function pParam = getDefaultPrintingParam(obj)            
            pParam.pwr = 300; % 1.2KW / 4kw *1000;
            pParam.lenPos = 900;
            pParam.flowL = 250; % 6 L/min / 20L/min * 1000;
            pParam.speedL = 100;% 2 r/min / 10r/min * 1000;
            pParam.flowR = 250;% 6 L/min / 20L/min * 1000;
            pParam.speedR = 100;% 2 r/min / 10r/min * 1000;   
            pParam.pFeedrate = 600; % mm/min(cylinder 600, vase 590)      
            pParam.powderMode = 1; % 1 = left, 2 = right, 3 = left + right
            pParam.laserDelay = 10; % unit second
        end
        
        function mParam = getDefaultMachiningParam(obj)            
            % machining process param
            mParam.mFeedrate = 1800; % mm/min
            mParam.spindleSpeed = 8000;
            mParam.toolNum = 1;
            mParam.toolRadiu = 4;
%             mParam.cutDepth = 0.1;
%             mParam.stepOver = 0.1;
        end

        function procParam = getDefaultProcessParam(obj)            
            % machining process param                      
            procParam.safetyHeight = 220;
            procParam.usingRTCP = 0;
            procParam.travelFeedrate = 3000;            
        end
      
        ret = genNormalPrintingProcess(obj, pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate, printParam);
        ret = genNormalMachiningProcess(obj, pg, toolNum, mPathSeq, mFeedrate, side, machiningParam);
        ret = genGradMtrlPrintingProcess(obj, pg, processCell, printParam);
        ret = genCamMtPrintingProcess(obj, pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate, printParam);
    end
end









