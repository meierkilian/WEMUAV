figure(1)
clf
title("Hover Forces")
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

hG = arrow3([0 0], G, 't');
text(G(1),G(2),' F_G', 'FontWeight','bold')

hT = arrow3([0 0], T, 'a');
text(T(1),T(2),' F_T', 'FontWeight','bold')

hD = arrow3([0 0], D, 's');
text(D(1),D(2) + 0.1,' F_D', 'FontWeight','bold')

hW = arrow3(-2.5*D, -1.5*D, 'b');
arrow3(-2.5*D + [0 0.1], -1.5*D + [0 0.1], 'b');
arrow3(-2.5*D - [0 0.1], -1.5*D - [0 0.1], 'b');
tmp = -1.5*D - [0 0.2];
text(tmp(1),tmp(2),'Air flow', 'FontWeight','bold')

hU = plot([0 0],[0 -1], '--k');
alphaSpace = linspace(0, alpha, 20);
ralpha = 0.4;
x = ralpha*sin(alphaSpace);
y = -ralpha*cos(alphaSpace);
hA = plot(x,y,'m','LineWidth',2);
text(x(5), y(5) + 0.1, '\alpha', 'FontWeight','bold')

% legend([hd, hG(1), hT(1), hD(1), hW(1), hA], {'Drone','F_G','F_T','F_D','Air Flow', '\alpha'},'location','northeastoutside')


exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\hoverForces.pdf",'ContentType','vector')
% exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\hoverForces.png",'ContentType','vector')