function plotSingleFlights(eval, outFolder, ext)
    AX_SPEED = 7;
    AX_DIR = 5;
    AX_VERT = 3;
    
 
	eval.plotValueOverFlight_pretty("FLY139__20210420_092926__Hover");
	makePatch(datetime(2021, 04, 20, 09, 32, 40), datetime(2021, 04, 20, 09, 33, 00), AX_SPEED,1)
    makePatch(datetime(2021, 04, 20, 09, 31, 55), datetime(2021, 04, 20, 09, 32, 15), AX_DIR,2)
    exportgraphics(gcf, outFolder + "flight_Hover" + ext, 'ContentType', 'vector');

    eval.plotValueOverFlight_pretty("FLY139__20210420_093827__Square");
    makePatch(datetime(2021, 04, 20, 09, 38, 28), datetime(2021, 04, 20, 09, 38, 32), AX_SPEED,1)
    makePatch(datetime(2021, 04, 20, 09, 38, 28), datetime(2021, 04, 20, 09, 38, 32), AX_DIR,2)
    makePatch(datetime(2021, 04, 20, 09, 38, 38), datetime(2021, 04, 20, 09, 38, 41), AX_DIR,3)
    exportgraphics(gcf, outFolder + "flight_Square" + ext, 'ContentType', 'vector');

    eval.plotValueOverFlight_pretty("FLY168__20210503_143909__Vertical3ms");
    makePatch(datetime(2021, 05, 03, 14, 39, 13), datetime(2021, 05, 03, 14, 39, 18), AX_SPEED,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 30), datetime(2021, 05, 03, 14, 39, 33), AX_SPEED,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 43), datetime(2021, 05, 03, 14, 39, 49), AX_SPEED,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 21), datetime(2021, 05, 03, 14, 39, 27), AX_SPEED,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 36), datetime(2021, 05, 03, 14, 39, 39), AX_SPEED,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 53), datetime(2021, 05, 03, 14, 39, 59), AX_SPEED,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 13), datetime(2021, 05, 03, 14, 39, 18), AX_DIR,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 30), datetime(2021, 05, 03, 14, 39, 33), AX_DIR,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 43), datetime(2021, 05, 03, 14, 39, 49), AX_DIR,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 21), datetime(2021, 05, 03, 14, 39, 27), AX_DIR,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 36), datetime(2021, 05, 03, 14, 39, 39), AX_DIR,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 53), datetime(2021, 05, 03, 14, 39, 59), AX_DIR,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 13), datetime(2021, 05, 03, 14, 39, 18), AX_VERT,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 30), datetime(2021, 05, 03, 14, 39, 33), AX_VERT,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 43), datetime(2021, 05, 03, 14, 39, 49), AX_VERT,1)
    makePatch(datetime(2021, 05, 03, 14, 39, 21), datetime(2021, 05, 03, 14, 39, 27), AX_VERT,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 36), datetime(2021, 05, 03, 14, 39, 39), AX_VERT,2)
    makePatch(datetime(2021, 05, 03, 14, 39, 53), datetime(2021, 05, 03, 14, 39, 59), AX_VERT,2)
    exportgraphics(gcf, outFolder + "flight_Vert" + ext, 'ContentType', 'vector');


    function makePatch(start, stop, axID, color)
        fig = gcf;
        colormap lines
        
        % Disables legend updates to avoid patches to show up
        lgd = legend(fig.Children(axID));
        lgd.AutoUpdate = 'off';
        
        % Get y limits of the desired axis
        y = ylim(fig.Children(axID));
    	yLow = y(1);
        yHigh = y(2);

        % Vertices of square
        X = [start, stop, stop, start];
        Y = [yLow,  yLow, yHigh, yHigh];

        % Draw patch on desired axis
    	patch(fig.Children(axID), X,Y,color, 'FaceAlpha', 0.2, 'CDataMapping','direct')
    end
end
