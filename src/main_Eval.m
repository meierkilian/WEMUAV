function main_Estimate(paraPath)
    arguments
        paraPath = fullfile(".","para","default.xml");
    end
    
    % Loading parameters
    % main_ParaGen
    % PARA = readstruct(paraPath);
    eval = Eval(ParaGen_Eval());
    % eval.dispAllMagErr();

    outFolder = "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\results\";
    ext = ".pdf";
    
    % eval.plotValueOverFlight_pretty("FLY139__20210420_092926__Hover");
    % exportgraphics(gcf, outFolder + "flight_Hover" + ext, 'ContentType', 'vector');

    % eval.plotValueOverFlight_pretty("FLY139__20210420_093827__Square");
    % exportgraphics(gcf, outFolder + "flight_Square" + ext, 'ContentType', 'vector');

    % eval.plotValueOverFlight_pretty("FLY168__20210503_143909__Vertical3ms");
    % exportgraphics(gcf, outFolder + "flight_Vert" + ext, 'ContentType', 'vector');


    % t = eval.singleFlightPerf("FLY139__20210420_092926__Hover");
    % writetable(t, outFolder + "perf_Hover.csv", 'WriteRowNames', true)

    % t = eval.singleFlightPerf("FLY139__20210420_093827__Square");
    % writetable(t, outFolder + "perf_Square.csv", 'WriteRowNames', true)

    % t = eval.singleFlightPerf("FLY168__20210503_143909__Vertical3ms");
    % writetable(t, outFolder + "perf_Vertical3ms.csv", 'WriteRowNames', true)



    % eval.plotErrorOverWind_total("Hover")
    % exportgraphics(gcf, outFolder + "wind_Hover" + ext, 'ContentType', 'vector');
    % eval.plotErrorOverWind_total("Square")
    % exportgraphics(gcf, outFolder + "wind_Square" + ext, 'ContentType', 'vector');
    % eval.plotErrorOverWind_total("Vertical")
    % exportgraphics(gcf, outFolder + "wind_Vert3ms" + ext, 'ContentType', 'vector');
    % eval.plotErrorOverWind_total("all")
    % exportgraphics(gcf, outFolder + "wind_all" + ext, 'ContentType', 'vector');



    % eval.singleFlightPerf("FLY168__20210503_143909__Vertical3ms");

    eval.plotErrorOverWind_totalVert("all")
    exportgraphics(gcf, outFolder + "windVert_all" + ext, 'ContentType', 'vector');
end