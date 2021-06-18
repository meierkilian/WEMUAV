classdef Estimator
    % Main estimator class, serving as switch to the different estimation methods. Only doEstimate() needs to be called
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
                    disp("[Estimator] Processing " + string(obj.para.inputPath(i)) + " with method " + string(obj.para.method(j)))
                    data = load(obj.para.inputPath(i)).totalTT;

                    if obj.para.method(j) == "garreausimple"
                        est = Est_GarreauSimple(obj.para.garreausimple);
                    elseif obj.para.method(j) == "directdynamicmodel"
                        est = Est_DirectDynamicModel(obj.para.directdynamicmodel, 'normal');
                    elseif obj.para.method(j) == "directdynamicmodel_noVertDrag"
                        est = Est_DirectDynamicModel(obj.para.directdynamicmodel, 'noVertDrag');
                    else
                        error("Unkown estimation method : " + obj.para.method(j));
                    end

                    tt = est.estimateWind(data);
                    tt = addprop(tt, {'Method'}, {'table'});
                    tt.Properties.CustomProperties.Method = string(obj.para.method{j});
                    
                    save(fullfile(obj.para.outputPath, tt.Properties.CustomProperties.FlightName + "_" + obj.para.method(j) + ".mat"), 'tt', '-mat')
                end
            end
        end
        
    end
end
