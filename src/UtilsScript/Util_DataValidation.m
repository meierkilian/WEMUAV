% TODO : comment
classdef Util_DataValidation < handle
	properties
		figPos
		figVel
		figAcc
		figOri
		figOriRate
		figWind
		figWindCorr
		figTemp
		uf
	end

	methods
		function obj = Util_DataValidation()
			obj.uf = Util_Frame();
			obj.figPos = NaN;
			obj.figVel = NaN;
			obj.figAcc = NaN;
			obj.figOri = NaN;
			obj.figOriRate = NaN;
			obj.figWind = NaN;
			obj.figWindCorr = NaN;
			obj.figTemp = NaN;
		end


		function validate(obj, data)
			obj.validatePosition(data);
			obj.validateOrientation(data);
			obj.validateWind(data);
		end


		function validatePosition(obj, data)
            if ~ismember("alti",data.Properties.VariableNames)
                data.alti = zeros(size(data.Time));
            end
            
			dt = seconds(data.Properties.TimeStep);
			posNED = lla2ned([data.lati, data.long, data.alti], [data.lati(end), data.long(end), data.alti(end)], 'ellipsoid');
			velNED = [data.vn, data.ve, data.vd];
			accNED = obj.uf.XYZ2NED([data.ax, data.ay, data.az], data.q1, data.q2, data.q3, data.q4);

			posNED_d = diff(posNED)/dt;
			posNED_dd = diff(posNED_d)/dt - [0, 0, 9.81];

			velNED_d = diff(velNED)/dt - [0, 0, 9.81];

			
			% % Position
			% if ~ishandle(obj.figPos)
			% 	obj.figPos = figure();
			% else
			% 	figure(obj.figPos)
			% end
			% clf
			% subplot(3,1,1), hold on, plot(data.Time, posNED(:,1)), title("Pos N"), ylabel("Pos [m]"), xlabel("Time")
			% subplot(3,1,2), hold on, plot(data.Time, posNED(:,2)), title("Pos E"), ylabel("Pos [m]"), xlabel("Time")
			% subplot(3,1,3), hold on, plot(data.Time, posNED(:,3)), title("Pos D"), ylabel("Pos [m]"), xlabel("Time")

			% Velocity
			if ~ishandle(obj.figVel)
				obj.figVel = figure();
			else
				figure(obj.figVel)
			end
			clf
			subplot(3,1,1), hold on, plot(data.Time(2:end), posNED_d(:,1)), title("Vel N"), ylabel("Vel [m/s]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time(2:end), posNED_d(:,2)), title("Vel E"), ylabel("Vel [m/s]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time(2:end), posNED_d(:,3)), title("Vel D"), ylabel("Vel [m/s]"), xlabel("Time")

			subplot(3,1,1), hold on, plot(data.Time, velNED(:,1)), title("Vel N"), ylabel("Vel [m/s]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time, velNED(:,2)), title("Vel E"), ylabel("Vel [m/s]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time, velNED(:,3)), title("Vel D"), ylabel("Vel [m/s]"), xlabel("Time")

			legend("Pos Diff","Vel")
			% Acceleration
			if ~ishandle(obj.figAcc)
				obj.figAcc = figure();
			else
				figure(obj.figAcc)
			end
			clf

			subplot(3,1,1), hold on, plot(data.Time(3:end), posNED_dd(:,1)), title("Acc N"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time(3:end), posNED_dd(:,2)), title("Acc E"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time(3:end), posNED_dd(:,3)), title("Acc D"), ylabel("Acc [m/s^2]"), xlabel("Time")
			
			subplot(3,1,1), hold on, plot(data.Time(2:end), velNED_d(:,1)), title("Acc N"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time(2:end), velNED_d(:,2)), title("Acc E"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time(2:end), velNED_d(:,3)), title("Acc D"), ylabel("Acc [m/s^2]"), xlabel("Time")
			
			subplot(3,1,1), hold on, plot(data.Time, accNED(:,1)), title("Acc N"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time, accNED(:,2)), title("Acc E"), ylabel("Acc [m/s^2]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time, accNED(:,3)), title("Acc D"), ylabel("Acc [m/s^2]"), xlabel("Time")

			uad = Util_AirDensity();
			rho = uad.getAirDensity(mean(data.tempRef), mean(data.pressRef), mean(data.humidRef))
			ur = Util_Russell();
			thrust = ur.getHoverThrust(0.5*vecnorm([data.motRpm_RF, data.motRpm_LF, data.motRpm_LB, data.motRpm_RB],2,2), rho);
			subplot(3,1,3), hold on, plot(data.Time, -thrust/1.37)

			legend("Pos Diff Diff", "Vel Diff", "Acc", "-Thrust")
		end

		function validateOrientation(obj, data)
			dt = seconds(data.Properties.TimeStep);
			oriXYZ = euler(quaternion(data.q1, data.q2, data.q3, data.q4), 'XYZ', 'point');
			% oriXYZ = [data.roll, data.pitch, data.yaw];
			gyroXYZ = [data.gyroX, data.gyroY, data.gyroZ];

			oriXYZ_d = diff(oriXYZ)/dt;


			% if ~ishandle(obj.figOri)
			% 	obj.figOri = figure();
			% else
			% 	figure(obj.figOri)
			% end
			% clf
			% subplot(3,1,1), hold on, plot(data.Time, oriXYZ(:,1)), title("Roll"), ylabel("Angle [rad]"), xlabel("Time")
			% subplot(3,1,2), hold on, plot(data.Time, oriXYZ(:,2)), title("Pitch"), ylabel("Angle [rad]"), xlabel("Time")
			% subplot(3,1,3), hold on, plot(data.Time, oriXYZ(:,3)), title("Yaw"), ylabel("Angle [rad]"), xlabel("Time")


			if ~ishandle(obj.figOriRate)
				obj.figOriRate = figure();
			else
				figure(obj.figOriRate)
			end
			clf
			subplot(3,1,1), hold on, plot(data.Time, gyroXYZ(:,1)), title("AngRate X"), ylabel("AngRate [rad/s]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time, gyroXYZ(:,2)), title("AngRate Y"), ylabel("AngRate [rad/s]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time, gyroXYZ(:,3)), title("AngRate Z"), ylabel("AngRate [rad/s]"), xlabel("Time")

			subplot(3,1,1), hold on, plot(data.Time(2:end), oriXYZ_d(:,1)), title("AngRate X"), ylabel("AngRate [rad/s]"), xlabel("Time")
			subplot(3,1,2), hold on, plot(data.Time(2:end), oriXYZ_d(:,2)), title("AngRate Y"), ylabel("AngRate [rad/s]"), xlabel("Time")
			subplot(3,1,3), hold on, plot(data.Time(2:end), oriXYZ_d(:,3)), title("AngRate Z"), ylabel("AngRate [rad/s]"), xlabel("Time")

			legend("Gyro","Ori Diff")
		end

		function validateWind(obj, data)
			dt = seconds(data.Properties.TimeStep);
			
			% CROSS CORRELATION
			[cMag, lagsMag] = xcorr(data.windHMag_0150cm_refMeteoTT,data.windHMag_0150cm_refTT,'normalized');
			lagsMag = lagsMag*dt;
			[maxMag, idxMag] = max(cMag);

			[cDir, lagsDir] = xcorr(data.windHDir_0150cm_refMeteoTT,data.windHDir_0150cm_refTT,'normalized');
			lagsDir = lagsDir*dt;
			[maxDir, idxDir] = max(cDir);

			if ~ishandle(obj.figWindCorr)
				obj.figWindCorr = figure();
			else
				figure(obj.figWindCorr)
			end
			clf

			subplot(2,1,1), hold on, plot(lagsMag,cMag), plot(lagsMag(idxMag),maxMag,'ro'), title("Wind Mag"), xlabel("Lag [s]"), ylabel("Normalized xcorr"), title("Magnitude","Max xcorr at lag = " + num2str(lagsMag(idxMag)))
			subplot(2,1,2), hold on, plot(lagsDir,cDir), plot(lagsDir(idxDir),maxDir,'ro'), title("Wind Dir"), xlabel("Lag [s]"), ylabel("Normalized xcorr"), title("Direction","Max xcorr at lag = " + num2str(lagsDir(idxDir)))
			

			% WIND
			if ~ishandle(obj.figWind)
				obj.figWind = figure();
			else
				figure(obj.figWind)
			end
			clf

			subplot(2,1,1), hold on, title("Wind Magnitude"), xlabel("Time"), ylabel("Speed [m/s]")
			% plot(data.Time, data.windHMag_2130cm)
			% plot(data.Time, data.windHMag_1800cm)
			% plot(data.Time, data.windHMag_1470cm)
			plot(data.Time, data.windHMag_0150cm_refMeteoTT)
			plot(data.Time, data.windHMag_0150cm_refTT)
			% plot(data.Time + seconds(lagsMag(idxMag)), data.windHMag_0150cm_refTT)
			
			subplot(2,1,2), hold on, title("Wind direction"), xlabel("Time"), ylabel("Angle [°]")
			% plot(data.Time, data.windHDir_2130cm)
			% plot(data.Time, data.windHDir_1800cm)
			% plot(data.Time, data.windHDir_1470cm)
			plot(data.Time, data.windHDir_0150cm_refMeteoTT)
			plot(data.Time, data.windHDir_0150cm_refTT)
			% plot(data.Time + seconds(lagsMag(idxMag)), data.windHDir_0150cm_refTT)

			% legend("TOPOAWS","MOTUS","MOTUS Corrected w/ Mag lag")
			legend("TOPOAWS","MOTUS")
		end


		function validateAirDensity(obj, data)
			if ~ishandle(obj.figTemp)
				obj.figTemp = figure();
			else
				figure(obj.figTemp)
			end
			clf
			hold on
			title("Temperature"), xlabel("Time"), ylabel("Temperature [°C]")
			plot(data.Time, data.tempRef)
% 			plot(data.Time, data.tempMotus)

			uad = Util_AirDensity();
			rhoRef = uad.getAirDensity(mean(data.tempRef), mean(data.pressRef), mean(data.humidRef));
% 			rhoMotus = uad.getAirDensity(mean(data.tempMotus), mean(data.pressRef), mean(data.humidRef));

			legend("TempRef, \rho : " + num2str(rhoRef), "TempMotus, \rho : " + num2str(rhoMotus))
		
		end
	end
end
