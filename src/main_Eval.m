function main_Eval(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    eval = Eval(ParaGen_Eval());
    
    % Output folders
    outFolder = fullfile(".","outData","eval");
    ext = ".pdf";

    selectedHoverFlight = "FLY139__20210420_092926__Hover";
    selectedSquareFlight = "FLY139__20210420_093827__Square";
    selectedVerticalFlight = "FLY168__20210503_143909__Vertical3ms";
    
     
    % Performance HOVER
    t = eval.singleFlightPerf(selectedHoverFlight);
    writetable(t, fullfile(outFolder, "perf_Hover.csv"), 'WriteRowNames', true)
    eval.plotValueOverFlight_pretty(selectedHoverFlight);
    exportgraphics(gcf, fullfile(outFolder, "perf_Hover" + ext), 'ContentType', 'vector');

    % Performance SQUARE
    t = eval.singleFlightPerf(selectedSquareFlight);
    writetable(t, fullfile(outFolder, "perf_Square.csv"), 'WriteRowNames', true)
    eval.plotValueOverFlight_pretty(selectedSquareFlight);
    exportgraphics(gcf, fullfile(outFolder, "perf_Square" + ext), 'ContentType', 'vector');
    
    % Performance VERTICAL3MS
    t = eval.singleFlightPerf(selectedVerticalFlight);
    writetable(t, fullfile(outFolder, "perf_Vertical3ms.csv"), 'WriteRowNames', true)
    eval.plotValueOverFlight_pretty(selectedVerticalFlight);
    exportgraphics(gcf, fullfile(outFolder, "perf_Vertical3ms" + ext), 'ContentType', 'vector');
    
    % Performance GROUNDTRUTH (during slectedHover)
    t = eval.groundTruthPerf(selectedHoverFlight);
    writetable(t, fullfile(outFolder, "perf_groundTruth_Hover.csv"), 'WriteRowNames', true)
    eval.plotGroundTruthOverFlight_pretty(selectedHoverFlight);
    exportgraphics(gcf, fullfile(outFolder, "perf_groundTruth_Hover" + ext), 'ContentType', 'vector');
  
end