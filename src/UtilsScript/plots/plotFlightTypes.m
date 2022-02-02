hover = load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY181__20210607_125356__Hover.mat', 'totalTT');
square = load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY181__20210607_130052__Square.mat', 'totalTT');
horiz = load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY181__20210607_130256__CstSpeed2ms.mat', 'totalTT');
vert = load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY182__20210607_131413__Vertical2ms.mat', 'totalTT');



% figure(1), clf
% % sgtitle("Flight type")
% 
% plotFlightType("Hover", hover, 1,5)
% plotFlightType("Square", square, 2,6)
% plotFlightType("CstSpeed", horiz, 3,7)
% plotFlightType("Vertical", vert, 4,8)
% 
% exportgraphics(gcf, "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\flightType.pdf",'ContentType','vector')



figure(2), clf
% sgtitle("Flight type")

plotFlightType("Hover", hover, 1,5)
exportgraphics(gcf, "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\flightType_hover.pdf",'ContentType','vector')
clf
plotFlightType("Square", square, 1,5)
exportgraphics(gcf, "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\flightType_square.pdf",'ContentType','vector')
clf
plotFlightType("CstSpeed", horiz, 1,5)
exportgraphics(gcf, "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\flightType_cstSpeed.pdf",'ContentType','vector')
clf
plotFlightType("Vertical", vert, 1,5)
exportgraphics(gcf, "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\flightType_vertical.pdf",'ContentType','vector')




function plotFlightType(name, data, idxGeo, idxAlti)
    latLim = [46.521030, 46.521700];
    longLim = [6.567056, 6.567626];
    subplot(2,4,idxGeo)
    geoplot(data.totalTT.lati, data.totalTT.long,'r','LineWidth',2.5)
    grid off
    geolimits(latLim, longLim)
    geobasemap satellite
    title(name)

    subplot(2,4,idxAlti)
    hold on
    grid on
    time = seconds(data.totalTT.Time - data.totalTT.Time(1));
    plot(time, data.totalTT.alti, 'LineWidth',2)
    plot([time(1), time(end)],[328, 328], '--','LineWidth',2);
    ylim([320, 375]);
    xlabel("Time [s]")
    ylabel("Altitude [m]")
    legend("Flight","Ground Level")
end
