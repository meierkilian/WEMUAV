classdef Estimator
    properties 
        para
    end
    
    methods
        function obj = Estimator(para)
            obj.para = para;
        end
        
        function doEstimate(obj)
            for i = 1:length(obj.para.inputPath)
                for j = 1:length(obj.para.method)
                    data = load(obj.para.inputPath(i));

                    if obj.para.method(j) == "garreausimple"
                        est = Est_GarreauSimple(obj.para.garreausimple);
                    else
                        error("Unkown estimation method : " + obj.para.method);
                    end
                    
                    tt = est.estimateWind(data.totalTT);
                    
                    [~, flightName, ~] = fileparts(obj.para.inputPath(i));
                    save(fullfile(obj.para.outputPath, flightName + "_" + obj.para.method(j) + ".mat"), 'tt', '-mat')
                end
            end
        end
        
    end
end
