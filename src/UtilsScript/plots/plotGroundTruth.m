function plotGroundTruth(eval, outFolder, ext)
    AX_SPEED = 7;
    AX_DIR = 5;
    AX_VERT = 3;
    
    eval.plotGroundTruthOverFlight_pretty("FLY139__20210420_092926__Hover") 
    makePatch(datetime(2021, 04, 20, 09, 31, 20), datetime(2021, 04, 20, 09, 31, 40), AX_SPEED,3)
    makePatch(datetime(2021, 04, 20, 09, 32, 40), datetime(2021, 04, 20, 09, 33, 00), AX_SPEED,1)
    makePatch(datetime(2021, 04, 20, 09, 32, 05), datetime(2021, 04, 20, 09, 32, 20), AX_DIR,2) 
    
    exportgraphics(gcf, outFolder + "groundTruth_Hover" + ext, 'ContentType', 'vector');

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
