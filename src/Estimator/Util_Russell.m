classdef Util_Russell
	% Utility class implementing estimations based on empirical data gathered in this work :
	% https://rotorcraft.arc.nasa.gov/Publications/files/Russell_1180_Final_TM_022218.pdf
	properties
		tSingleMotor % single motor data table
		motorThrust % function handle
		
		tHover % hover data table
		hoverThrust % function handle
		
		tDrag % drag data table
		rhoRussell % Mean air density during Russell tests
		tasRussell % Mean true air speed during Russell tests
		FDragRussell % Intperpolant
		meanDragRussel % Mean drag
	end

	methods
		function obj = Util_Russell(pathSingleMotor, pathDrag, pathHover)
			% Constructor. Preloads Russell data as found in :
			% https://rotorcraft.arc.nasa.gov/Publications/files/Russell_1180_Final_TM_022218.pdf
			% It is expected that the Russell data is stored in a 
			% format compatible with the "readtable" function. Moreover
			% it is also expected that the data is stored in SI units.
			% INPUT : 
			% 	pathSingleMotor : path to singleMotor data
			%	pathDrag : path to drag data (full vehicle, uniform)
			% 	pathHover : path to hover data
			% OUTPUT : 
	        %   obj : constructed object
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

		function obj = initMotorThrustEstimator(obj)
			% Computes the linear regression function relating RPM^2 to thrust for one or several standalone motors
			
			bMotor =  obj.tSingleMotor.RPM.^2 \ obj.tSingleMotor.Fz;
			meanAirDensity = mean(obj.tSingleMotor.AirDensity);
			obj.motorThrust = @(RPM, rho) rho ./ meanAirDensity .* sum(RPM.^2, 2) * bMotor;

			% Rsq = 1 - sum((obj.tSingleMotor.Fz - obj.motorThrust(obj.tSingleMotor.RPM, meanAirDensity)).^2)/sum((obj.tSingleMotor.Fz - mean(obj.tSingleMotor.Fz)).^2);
			% disp("[Util_Russell] Motor Thrust goodness of fit : R^2 = " + num2str(Rsq))
		end

		function obj = initHoverThrustEstimator(obj)
			% Computes the linear regression function relating RPM^2 to thrust for total quadcopter
			
			bHover =  obj.tHover.RPM.^2 \ obj.tHover.Fz;
			meanAirDensity = mean(obj.tHover.AirDensity);
			obj.hoverThrust = @(RPM, rho) sum(RPM.^2, 2) * bHover;
			% obj.hoverThrust = @(RPM, rho) rho ./ meanAirDensity .* sum(RPM.^2, 2) * bHover;

			Rsq = 1 - sum((obj.tHover.Fz - obj.hoverThrust(obj.tHover.RPM, meanAirDensity)).^2)/sum((obj.tHover.Fz - mean(obj.tHover.Fz)).^2);
            
            xlim = [min(obj.tHover.RPM), max(obj.tHover.RPM)];
            xspace = linspace(xlim(1),xlim(2),100);
            
            figure(1)
            clf
            hold on
            plot(xspace.^2, obj.hoverThrust(xspace', nan))
            plot(obj.tHover.RPM.^2, obj.tHover.Fz, 'o')
            grid on
            title("Thrust model")
            ylabel("$F_{T,-z}$ [N]", 'Interpreter','latex')
            xlabel("$\bar{\eta}^2$ [RPM$^2$]", 'Interpreter','latex')
            legend("Model : $F_{T,-z} = " + num2str(bHover,2) + "\cdot\bar{\eta}^2,\ R^2 = " + num2str(Rsq,4) + "$", "Samples", 'Interpreter','latex','location','best')
			% disp("[Util_Russell] Hover Thrust goodness of fit : R^2 = " + num2str(Rsq))
		end

		function obj = initTASEstimation(obj)
			% Computes useful parameters for TAS estimation
			
			obj.rhoRussell = mean(obj.tDrag.AirDensity);
			obj.tasRussell = mean(obj.tDrag.AirSpeed);

            dragRussell = (obj.tDrag.Fx .* cos(obj.tDrag.Pitch) + (obj.tDrag.Fz - obj.getHoverThrust(obj.tDrag.RPM, obj.rhoRussell)) .* sin(obj.tDrag.Pitch));
            
			obj.meanDragRussel = mean(dragRussell);
			obj.FDragRussell = scatteredInterpolant(-obj.tDrag.Pitch, obj.tDrag.RPM, dragRussell, 'linear', 'linear');
            
%             xSpace = unique(-obj.tDrag.Pitch);
%             ySpace = unique(obj.tDrag.RPM);
%             
%             figure(1)
%             clf
%             [xMesh, yMesh] = meshgrid(xSpace, ySpace);
%             mesh(xMesh,yMesh,obj.FDragRussell(xMesh,yMesh),'FaceColor','interp', 'FaceAlpha',0.5)
%             xlabel("$\gamma$ [rad]", 'Interpreter','latex')
%             ylabel("$\bar{\eta}$ [RPM]", 'Interpreter','latex')
%             zlabel("$D_R$ [N]", 'Interpreter','latex')
%             title("Wind tunnel drag model")
		end

		function thrust = getMotorThrust(obj, RPM, rho)
			% Get thrust value for given RPM
			% INPUT :
			% 		RPM : NxM matrix, where the N rows represent the N samples of
			%			  which to compute the thrust from and the M cols represent
			%			  the M motors present on the copter. It is assumed that
			% 			  all M motors thrust in the same direction.
			% 		rho : air density [k/m^3]. Util_AirDensity can be used to compute it.
			% OUTPUT :
			% 		thrust : column vector of length N, representing the total thrust [N]
			
			thrust = obj.motorThrust(RPM, rho);
		end

		function thrust = getHoverThrust(obj, RPM_bar, rho)
			% Get hover thrust value for given RPM (i.e. for a full copter)
			% INPUT :
			% 		RPM_bar : column vector of length N, reprensenting the norm of RPM divided by
			%				  the squareroot of the nbr of propeller, i.e. sqrt(sum(RPM.^2))/sqrt(#prop)
			% 		rho : air density [kh/m^3]. Util_AirDensity can be used to compute it.
			% OUTPUT :
			% 		thrust : column vector of length N, representing the total thrust [N]

            thrust = obj.hoverThrust(RPM_bar, rho);
		end

		function tas = getTrueAirSpeed(obj, gamma, RPM, drag, rho, flow)
			% Get the magnitude of the TAS
			% Assumes air speed coming from above or below (negative or positive tilt)
			% INTPUT :
			% 		gamma : wind incidence angle [rad]
			%		RPM : rotor speed [RPM] averaged over all rotor
			%		drag : drag force the air craft is experiencing [N]
			% 		rho : air density [kh/m^3]. Util_AirDensity can be used to compute it.
			% OUTPUT :
			%		tas : magnitude of true air speed
			
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
