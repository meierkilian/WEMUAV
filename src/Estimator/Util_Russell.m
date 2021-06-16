classdef Util_Russell
	properties
		tSingleMotor
		motorThrust % function handle
		
		tHover
		hoverThrust % function handle
		
		tDrag
		rhoRussell % Mean air density during Russell tests
		tasRussell % Mean true air speed during Russell tests
		FDragRussell % Intperpolant
		meanDragRussel
	end

	methods
		% Constructor. Preloads Russell data as found in :
		% https://rotorcraft.arc.nasa.gov/Publications/files/Russell_1180_Final_TM_022218.pdf
		% It is expected that the Russell data is stored in a 
		% format compatible with the "readtable" function. Moreover
		% it is also expected that the data is stored in SI units.
		% INPUT : 
		% 	pathSingleMotor : path to singleMotor data
		%	pathDrag : path to drag data (full vehicle, uniform)
		% OUTPUT : 
        %   obj : constructed object
		function obj = Util_Russell(pathSingleMotor, pathDrag, pathHover)
			arguments
				pathSingleMotor = fullfile(".","para","Russell_singleMotor.csv");
				pathDrag = fullfile(".","para","Russell_drag_6ms.csv");
				pathHover = fullfile(".","para","Russell_hover.csv");
			end

			obj.tSingleMotor = readtable(pathSingleMotor);
			obj.tDrag = readtable(pathDrag);
			obj.tHover = readtable(pathHover);

			obj = obj.initMotorThrustEstimator();
			obj = obj.initHoverThrustEstimator();
			obj = obj.initTASEstimation();
		end

		% Computes the linear regression function relating RPM^2 to thrust for one or several standalone motors
		function obj = initMotorThrustEstimator(obj)
			bMotor =  obj.tSingleMotor.RPM.^2 \ obj.tSingleMotor.Fz;
			meanAirDensity = mean(obj.tSingleMotor.AirDensity);
			obj.motorThrust = @(RPM, rho) rho ./ meanAirDensity .* sum(RPM.^2, 2) * bMotor;

			% Rsq = 1 - sum((obj.tSingleMotor.Fz - obj.motorThrust(obj.tSingleMotor.RPM, meanAirDensity)).^2)/sum((obj.tSingleMotor.Fz - mean(obj.tSingleMotor.Fz)).^2);
			% disp("[Util_Russell] Motor Thrust goodness of fit : R^2 = " + num2str(Rsq))
		end

		% Computes the linear regression function relating RPM^2 to thrust for total quadcopter
		function obj = initHoverThrustEstimator(obj)
			bHover =  obj.tHover.RPM.^2 \ obj.tHover.Fz;
			meanAirDensity = mean(obj.tHover.AirDensity);
			obj.hoverThrust = @(RPM, rho) sum(RPM.^2, 2) * bHover;
			% obj.hoverThrust = @(RPM, rho) rho ./ meanAirDensity .* sum(RPM.^2, 2) * bHover;

			% Rsq = 1 - sum((obj.tHover.Fz - obj.hoverThrust(obj.tHover.RPM, meanAirDensity)).^2)/sum((obj.tHover.Fz - mean(obj.tHover.Fz)).^2);
			% disp("[Util_Russell] Hover Thrust goodness of fit : R^2 = " + num2str(Rsq))
		end

		% Computes useful parameters for TAS estimation
		function obj = initTASEstimation(obj)
			obj.rhoRussell = mean(obj.tDrag.AirDensity);
			obj.tasRussell = mean(obj.tDrag.AirSpeed);

            dragRussell = (obj.tDrag.Fx .* cos(obj.tDrag.Pitch) + (obj.tDrag.Fz - obj.getHoverThrust(obj.tDrag.RPM, obj.rhoRussell)) .* sin(obj.tDrag.Pitch));
            
			obj.meanDragRussel = mean(dragRussell);
			obj.FDragRussell = scatteredInterpolant(-obj.tDrag.Pitch, obj.tDrag.RPM, dragRussell, 'linear', 'linear');
		end

		% Get thrust value for given RPM
		% INPUT :
		% 		RPM : NxM matrix, where the N rows represent the N samples of
		%			  which to compute the thrust from and the M cols represent
		%			  the M motors present on the copter. It is assumed that
		% 			  all M motors thrust in the same direction.
		% 		rho : air density [k/m^3]. Util_AirDensity can be used to compute it.
		% OUTPUT :
		% 		thrust : column vector of length N, representing the total thrust [N]
		function thrust = getMotorThrust(obj, RPM, rho)
			thrust = obj.motorThrust(RPM, rho);
		end

		% Get hover thrust value for given RPM (i.e. for a full copter)
		% INPUT :
		% 		RPM_bar : column vector of length N, reprensenting the norm of RPM divided by
		%				  the squareroot of the nbr of propeller, i.e. sqrt(sum(RPM.^2))/sqrt(#prop)
		% 		rho : air density [kh/m^3]. Util_AirDensity can be used to compute it.
		% OUTPUT :
		% 		thrust : column vector of length N, representing the total thrust [N]
		function thrust = getHoverThrust(obj, RPM_bar, rho)
            thrust = obj.hoverThrust(RPM_bar, rho);
		end

		% Get the magnitude of the TAS
		% Assumes air speed coming from above or below (negative or positive tilt)
		% INTPUT :
		% 		gamma : wind incidence angle [rad]
		%		RPM : rotor speed [RPM] averaged over all rotor
		%		drag : drag force the air craft is experiencing [N]
		% 		rho : air density [kh/m^3]. Util_AirDensity can be used to compute it.
		% OUTPUT :
		%		tas : magnitude of true air speed
		function tas = getTrueAirSpeed(obj, gamma, RPM, drag, rho, flow)
			% TODO : validate this
            gamma = mod(gamma, pi);
			gamma(gamma > pi/2) = pi - gamma(gamma > pi/2);
            gamma(gamma > rad2deg(40)) = rad2deg(40);
			% tas = sqrt(obj.tasRussell^2 .* drag ./ obj.FDragRussell(gamma, RPM));
			RPM(RPM > 6400) = 6400;
			RPM(RPM < 4200) = 4200;

			if flow == "laminar"
				tas = obj.rhoRussell*obj.tasRussell./rho .* drag ./ obj.FDragRussell(gamma, RPM);
			elseif flow == "turbulent"
				tas = sqrt(obj.rhoRussell*obj.tasRussell^2./rho .* drag ./ obj.FDragRussell(gamma, RPM));
			else
				error("[Util_Russell] Unkown flow type : " + flow)
			end
		end
	end
end
