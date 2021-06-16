% TODO : comment
flightName1 = "FLY181__20210607_124833__Total.mat";
flightName2 = "FLY182__20210607_131121__Total.mat";

s = @(x) x./max(abs(x));
so = @(x) (x-min(x))./max(x-min(x));

figure
hold on

load("C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\" + flightName1);
plot(totalTT.Time, so(totalTT.alti),'Color','#0072BD');
plot(totalTT.Time, s(totalTT.vn),'Color','#D95319');
plot(totalTT.Time, s(totalTT.ve),'Color','#EDB120');

load("C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\" + flightName2);
plot(totalTT.Time, so(totalTT.alti),'Color','#0072BD');
plot(totalTT.Time, s(totalTT.vn),'Color','#D95319');
plot(totalTT.Time, s(totalTT.ve),'Color','#EDB120');

legend("Alti", "VN", "VE")
