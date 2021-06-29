% TODO : comment
flightName1 = "2020-07-18_FLY121_profile__20200718_153139__Total.mat";
flightName2 = "2020-07-18_FLY122_profile__20200718_155853__Total.mat";

s = @(x) x./max(abs(x));
so = @(x) (x-min(x))./max(x-min(x));

figure
hold on

load("C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\" + flightName1);
% plot(totalTT.Time, so(totalTT.alti),'Color','#0072BD');
plot(totalTT.Time, s(totalTT.vn),'Color','#D95319');
plot(totalTT.Time, s(totalTT.ve),'Color','#EDB120');

load("C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\" + flightName2);
% plot(totalTT.Time, so(totalTT.alti),'Color','#0072BD');
plot(totalTT.Time, s(totalTT.vn),'Color','#D95319');
plot(totalTT.Time, s(totalTT.ve),'Color','#EDB120');

legend("Alti", "VN", "VE")
