% Parameters
outGifFilename = ".\src\UtilsScript\plots\svalbard.gif";
outImgFilename = "C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\tiltFrame.pdf";
outType = "Img"; % Can be either "Img" or "Gif"
load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY178__20210603_062423__Square.mat')
% load('C:\Users\Kilian\Documents\EPFL\PDM\SW\WEMUAV\outData\prepro\FLY167__20210503_141433__Hover.mat')
frameDelay = 0.3;
% latLim = [46.52105, 46.52172];
% longLim = [6.56695, 6.56781];

if outType == "Img"
    timeRange = 100;
elseif outType == "Gif"
    timeRange = 1:3:length(totalTT.q1);
else
    error("Unkown outType")
end


uf = Util_Frame();



% Drone mesh
nt = 100;
nr = 10;
[T,R] = meshgrid(linspace(0,2*pi,nt),linspace(0,1,nr));
X = R.*cos(T);
Y = R.*sin(T);
Z = zeros(size(X));


for idx = timeRange
    
    q = [totalTT.q1(idx), totalTT.q2(idx), totalTT.q3(idx), totalTT.q4(idx)];

    drone = zeros([nr, nt, 3]);
    drone(:,:,1) = X;
    drone(:,:,2) = Y;
    drone(:,:,3) = Z;

    % Unit vectors
    ux = [1 0 0];
    uy = [0 1 0];
    uz = [0 0 1];

    % Body frame
    ex = uf.XYZ2NED(ux, q(1), q(2), q(3), q(4));
    ey = uf.XYZ2NED(uy, q(1), q(2), q(3), q(4));
    ez = uf.XYZ2NED(uz, q(1), q(2), q(3), q(4));

    % Tilt frame
    eTx = uf.Tilt2NED(ux, q(1), q(2), q(3), q(4));
    eTy = uf.Tilt2NED(uy, q(1), q(2), q(3), q(4));
    eTz = uf.Tilt2NED(uz, q(1), q(2), q(3), q(4));

    % Local frame
    en = ux;
    ee = uy;
    ed = uz;

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
    
    % Local frame plot
    subplot(1,2,1)
    title("Reference frames")
    hold on
    grid on
    xlabel("North")
    ylabel("East")
    zlabel("Down")
    view(-96, 35)
    axis equal
    r = 1.2;
    xlim([-r;r])
    ylim([-r;r])
    zlim([-r;r])
    set(gca,'zdir','reverse')
    set(gca,'ydir','reverse')
    
    ha = nan(2,9);
    scale = 1.1;
    global LineWidthOrder
    LineWidthOrder = [1.2];
    % Local frame
    ha(:,1) = arrow3([0 0 0], en, '-k/');
    text(en(1)*scale,en(2)*scale,en(3)*scale,'u_n', 'FontWeight','bold')
    ha(:,2) = arrow3([0 0 0], ee, '--k/');
    text(ee(1)*scale,ee(2)*scale,ee(3)*scale,'u_e', 'FontWeight','bold')
    ha(:,3) = arrow3([0 0 0], ed, ':k/');
    text(ed(1)*scale,ed(2)*scale,ed(3)*scale,'u_d', 'FontWeight','bold')

    % Body frame
    ha(:,4) = arrow3([0 0 0], ex, '-m/');
    text(ex(1)*scale,ex(2)*scale,ex(3)*scale,'u_x', 'FontWeight','bold')
    ha(:,5) = arrow3([0 0 0], ey, '--m/');
    text(ey(1)*scale^2,ey(2)*scale^2,ey(3)*scale^2,'u_y', 'FontWeight','bold')
    ha(:,6) = arrow3([0 0 0], ez, ':m/');
    % text(ez(1)*scale,ez(2)*scale,ez(3)*scale,'u_z', 'FontWeight','bold')

    % Tilt frame
    ha(:,7) = arrow3([0 0 0], eTx, '-n/');
    text(eTx(1)*scale,eTx(2)*scale,eTx(3)*scale,'u_{Tx}', 'FontWeight','bold')
    ha(:,8) = arrow3([0 0 0], eTy, '--n/');
    text(eTy(1)*scale,eTy(2)*scale,eTy(3)*scale,'u_{Ty}', 'FontWeight','bold')
    ha(:,9) = arrow3([0 0 0], eTz, ':n/');
    text(eTz(1)*scale,eTz(2)*scale,eTz(3)*scale,'u_{Tz} = u_z', 'FontWeight','bold', 'HorizontalAlignment', 'right')


    C = (drone(:,:,3)- min(min(min(drone(:,:,3)))))*1.3;
    surf(drone(:,:,1),drone(:,:,2),drone(:,:,3), C,'EdgeColor','none','FaceColor','interp','FaceAlpha',0.8)

    % legend(ha(1,:),["u_n","u_e","u_d","u_x","u_y","u_z","u_{Tx}","u_{Ty}","u_{Tz}"],'location','northeast')
    
    % Geoplot
    subplot(1,2,2)
    h(1) = geoplot(totalTT.lati(1:idx), totalTT.long(1:idx),'r', 'LineWidth',4, 'DisplayName', 'Flight Path');
    latLim = [46.521030, 46.521700];
    longLim = [6.567006, 6.567676];
    geolimits(latLim, longLim)
    geobasemap satellite
    title("Flight path")
    hold on
    h(2) = geoplot(totalTT.lati(idx), totalTT.long(idx), 'pc','LineWidth',8,'MarkerSize', 13, 'DisplayName', 'Drone');
    
    hCopy = copyobj(h, gca); 
    set(hCopy(1),'XData', NaN', 'YData', NaN)
    set(hCopy(2),'XData', NaN', 'YData', NaN)
    hCopy(2).MarkerSize = 6; 
    legend(hCopy)
    

    
    if outType == "Img"
%         exportgraphics(gcf, outImgFilename,'ContentType','vector');
    elseif outType == "Gif"
         % Capture the plot as an image 
        frame = getframe(h); 
        im = frame2im(frame); 
        [imind,cm] = rgb2ind(im,256); 
%         [imind,cm] = rgb2ind(im,128); 
        % Write to the GIF File 
        if idx == 1 
          imwrite(imind,cm,outGifFilename,'gif', 'DelayTime', frameDelay, 'Loopcount',inf); 
        else 
          imwrite(imind,cm,outGifFilename,'gif','DelayTime', frameDelay, 'WriteMode','append'); 
        end 
    else
        error("Unkown outType")
    end
end