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
                    data = load(obj.para.inputPath(i)).totalTT;

                    if obj.para.method(j) == "garreausimple"
                        est = Est_GarreauSimple(obj.para.garreausimple);
                    elseif obj.para.method(j) == "directdynamicmodel"
                        est = Est_DirectDynamicModel(obj.para.directdynamicmodel);
                    elseif obj.para.method(j) == "ekf"
                        est = Est_EKF(obj.para.ekf);
                    else
                        error("Unkown estimation method : " + obj.para.method(j));
                    end
                    
                    [~, flightName, ~] = fileparts(obj.para.inputPath(i));

                    tt = est.estimateWind(data);
                    tt = addprop(tt, {'FlightName', 'Method'}, {'table', 'table'});
                    tt.Properties.CustomProperties.FlightName = flightName;
                    tt.Properties.CustomProperties.Method = obj.para.method(j);
                    
                    save(fullfile(obj.para.outputPath, flightName + "_" + obj.para.method(j) + ".mat"), 'tt', '-mat')
                end
            end
        end
        
    end
end
