figure(1)
clf
title("Wind Tunnel Setup")
xlabel("X-Body-Axis")
ylabel("Z-Body-Axis")
set(gca, 'ydir', 'reverse');
grid on
hold on
axis equal
lim = 1.5;
xlim([-lim;lim])
ylim([-lim;lim])


% Drone
s = 0.65;
hd = plot([-s, s],[0 0],'k','LineWidth',5);

% Air fow
rw = 1;
gamma = deg2rad(-30);
hW = arrow3([rw*cos(gamma), rw*sin(gamma)], [0 0], 'b');

% Incidence angle
gammaSpace = linspace(0, gamma, 20);
rgamma = 0.3;
x = rgamma*cos(gammaSpace);
y = rgamma*sin(gammaSpace);
hgamma = plot(x,y, 'm', 'LineWidth',2);

% Force sensor frame
hx = arrow3([0 0], [1 0], '-e');
hz = arrow3([0 0], [0 -1], '--e');
hy = plot(0,0,'o','Color',[0 127/256 0],'LineWidth',3);

% Support
rs = 0.1;
x = [-rs rs; -rs rs];
y = [0 0; lim lim];
z = zeros(size(x));
surf(x,y,z,'EdgeColor','none','FaceColor','black','FaceAlpha','0.5')

legend([hd, hW(1), hgamma, hx(1), hy, hz(1)], {'Drone','Air Flow','\gamma','u_{Wx}', 'u_{Wy}','u_{Wz}'},'location','northeastoutside')


exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\windTunnelSetup.eps")