% Parameters
outFilename = ".\src\UtilsScript\plots\squareFlight_short.gif";
load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY178__20210603_062423__Square.mat')
idx = 100;

uf = Util_Frame();


% Drone mesh
nt = 100;
nr = 10;
[T,R] = meshgrid(linspace(0,2*pi,nt),linspace(0,1,nr));
X = R.*cos(T);
Y = R.*sin(T);
Z = zeros(size(X));


q = [totalTT.q1(idx), totalTT.q2(idx), totalTT.q3(idx), totalTT.q4(idx)];

drone = zeros([nr, nt, 3]);
drone(:,:,1) = X;
drone(:,:,2) = Y;
drone(:,:,3) = Z;

% Unit vectors
ux = [1 0 0];
uy = [0 1 0];
uz = [0 0 1];

% Tilt frame
eTx = uf.Tilt2NED(ux, q(1), q(2), q(3), q(4));
eTy = uf.Tilt2NED(uy, q(1), q(2), q(3), q(4));
eTz = uf.Tilt2NED(uz, q(1), q(2), q(3), q(4));

% Drag vectors
dNED = [-1.4 -1.4 -0.1];
dTilt = uf.NED2Tilt(dNED, q(1), q(2), q(3), q(4));
dTxz = [dTilt(1) 0 dTilt(3)];
dTy = [0 dTilt(2) 0];
dTxzNED = uf.Tilt2NED(dTxz, q(1), q(2), q(3), q(4));
dmTxzNED = uf.Tilt2NED(-dTxz, q(1), q(2), q(3), q(4));
dTyNED = uf.Tilt2NED(dTy, q(1), q(2), q(3), q(4));

% Incidence angle
gamma = atan2(-dTxz(3), -dTxz(1));
ra = 0.5;
gammaSpace = linspace(0,gamma,20)';
gammaArcTilt = [ra*cos(gammaSpace), zeros(size(gammaSpace)), ra*sin(gammaSpace)];
gammaArcNED = uf.Tilt2NED(gammaArcTilt, q(1), q(2), q(3), q(4));

% Rotating drone
for i = 1:nr
    for j = 1:nt
        tmp = zeros(1,3);
        for k = 1:3
            tmp(k) = drone(i,j,k);
        end
        drone(i,j,:) = uf.XYZ2NED(tmp, q(1), q(2), q(3), q(4));
    end
end

h = figure(2);
clf

%% Local frame plot
subplot(1,3,1)
title("Drag projection on tilt frame")
hold on
grid on
xlabel("North")
ylabel("East")
zlabel("Down")
view(-96, 35)
axis equal
lim = 1.5;
xlim([-lim;lim])
ylim([-lim;lim])
zlim([-lim;lim])
set(gca,'zdir','reverse')
set(gca,'ydir','reverse')

ha = nan(2,6);


% Tilt frame
ha(:,1) = arrow3([0 0 0], eTx, '-t');
ha(:,2) = arrow3([0 0 0], eTy, '--t');
ha(:,3) = arrow3([0 0 0], eTz, ':t');

% Drag vector
global LineWidthOrder
LineWidthOrder = 2;
ha(:,4) = arrow3([0 0 0], dNED, '-e/');
ha(:,5) = arrow3([0 0 0], dTxzNED, '-.e');
ha(:,6) = arrow3([0 0 0], dTyNED, ':e');
arrow3([0 0 0], dmTxzNED, '-.e',0);
hgamma = plot3(gammaArcNED(:,1), gammaArcNED(:,2), gammaArcNED(:,3),'m', 'LineWidth',2);



C = (drone(:,:,3)- min(min(min(drone(:,:,3)))))*1.3;
surf(drone(:,:,1),drone(:,:,2),drone(:,:,3), C,'EdgeColor','none','FaceColor','interp','FaceAlpha',0.8)

legend([ha(1,:), hgamma],{"u_{Tx}","u_{Ty}","u_{Tz}","F_D","F_{D,TxTz}","F_{D,Ty}","\gamma"},'location','northwest','orientation','horizontal')

%% TxTz view
subplot(1,3,2)
title("TxTz-tilt-plane cross-section")
hold on
grid on
xlabel("Tx")
ylabel("Tz")
axis equal
xlim([-lim;lim])
ylim([-lim;lim])
set(gca,'ydir','reverse')


x = -1:0.1:1;
y = zeros(size(x));
z = y;
c = linspace(min(C,[],'all'), max(C,[],'all'), length(x));
surf([x;x],[y;y],[z;z], [c;c],'EdgeColor','interp','FaceColor','interp','LineWidth',5)

% Tilt frame
arrow3([0 0], ux([1 3]), '-t');
arrow3([0 0], uz([1 3]), ':t');

% Drag vector
arrow3([0 0], dTxz([1 3]), '-.e');
arrow3([0 0], -dTxz([1 3]), '-.e',0);
plot(gammaArcTilt(:,1), gammaArcTilt(:,3),'m', 'LineWidth',2)

%% Ty view
subplot(1,3,3)
title("TyTz-tilt-plane cross-section")
hold on
grid on
xlabel("Ty")
ylabel("Tz")
axis equal
xlim([-lim;lim])
ylim([-lim;lim])
set(gca,'ydir','reverse')
set(gca,'xdir','reverse')


x = -1:0.1:1;
y = zeros(size(x));
z = y;
c = ones(size(x))*mean(C,'all');
surf([x;x],[y;y],[z;z], [c;c],'EdgeColor','interp','FaceColor','interp','LineWidth',5)

subplot(1,3,3)
arrow3([0 0], uy([2 3]), '--t');
arrow3([0 0], uz([2 3]), ':t');

% Drag vector
arrow3([0 0], dTy([2 3]), '-.e');

exportgraphics(gcf,"C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\dragProjection.eps");
