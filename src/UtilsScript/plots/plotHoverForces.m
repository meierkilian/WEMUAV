figure(1)
clf
% title("Hover Forces")
% xlabel("North")
% ylabel("Down")
set(gca, 'ydir', 'reverse');
% grid on
axis off
hold on
axis equal
lim = 1.5;
xlim([-lim;lim])
ylim([-lim;lim])

% Forces
G = [0 1];
alpha = deg2rad(30);
t = 1.2;
T = [t*sin(alpha), -t*cos(alpha)];
D = -G -T;

% Drone
s = 1;
dstart = exp(1i*alpha);
dend = -exp(1i*alpha);
hd = plot([dstart dend],'k','LineWidth',5);

% Gamma
Dcplx = D(2) + 1i*D(1);
gammaStrt = angle(Dcplx);
gammaEnd = -angle(dstart)-pi/2;



% hG = arrow3([0 0], G, 't');
hG = arrow3([0 0], G, 'k');
text(G(1),G(2),' F_G', 'FontWeight','bold')

% hT = arrow3([0 0], T, 'a');
hT = arrow3([0 0], T, 'k');
text(T(1),T(2),' F_T', 'FontWeight','bold')

% hD = arrow3([0 0], D, 's');
hD = arrow3([0 0], D, 'k');
text(D(1),D(2) + 0.1,' F_D', 'FontWeight','bold')
% 
% hW = arrow3(-2.5*D, -1.5*D, 'b');
% arrow3(-2.5*D + [0 0.1], -1.5*D + [0 0.1], 'b');
% arrow3(-2.5*D - [0 0.1], -1.5*D - [0 0.1], 'b');
hW = arrow3(-2.5*D, -1.5*D, 'k');
arrow3(-2.5*D + [0 0.1], -1.5*D + [0 0.1], 'k');
arrow3(-2.5*D - [0 0.1], -1.5*D - [0 0.1], 'k');
tmp = -1.5*D - [0 0.2];
text(tmp(1),tmp(2),'Air flow', 'FontWeight','bold')

hU = plot([0 0],[0 -1], '--k');

alphaSpace = linspace(0, alpha, 20);
ralpha = 0.4;
x = ralpha*sin(alphaSpace);
y = -ralpha*cos(alphaSpace);
% hA = plot(x,y,'m','LineWidth',2);
hA = plot(x,y,'k','LineWidth',2);
text(x(5), y(5) + 0.1, '\alpha', 'FontWeight','bold')

gammaSpace = linspace(gammaStrt, gammaEnd, 20);
rgamma = 0.35;
x = rgamma*sin(gammaSpace);
y = rgamma*cos(gammaSpace);
% hG = plot(x,y,'Color','#EDB120','LineWidth',2);
hG = plot(x,y,'k','LineWidth',2);
text(x(10)+0.03, y(10), '\gamma', 'FontWeight','bold')

% legend([hd, hG(1), hT(1), hD(1), hW(1), hA], {'Drone','F_G','F_T','F_D','Air Flow', '\alpha'},'location','northeastoutside')


exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\hoverForces.pdf",'ContentType','vector')
% exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\hoverForces.png",'ContentType','vector')