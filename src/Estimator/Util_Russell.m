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
			% obj.hoverThrust = @(RPM, rho) sum(RPM.^2, 2) * bHover;
			obj.hoverThrust = @(RPM, rho) rho ./ meanAirDensity .* sum(RPM.^2, 2) * bHover;

			Rsq = 1 - sum((obj.tHover.Fz - obj.hoverThrust(obj.tHover.RPM, meanAirDensity)).^2)/sum((obj.tHover.Fz - mean(obj.tHover.Fz)).^2);
            
            xlim = [min(obj.tHover.RPM), max(obj.tHover.RPM)];
            xspace = linspace(xlim(1),xlim(2),100);
            
            if isempty(figure(2).Children)
                clf
                plot(xspace.^2, obj.hoverThrust(xspace', meanAirDensity))
                hold on
                plot(obj.tHover.RPM.^2, obj.tHover.Fz, 'o')
                grid on
                ylabel("F_{T,-z} [N]")
                xlabel("\eta_{bar}^2 [RPM^2]")
                legend("Model : F_{T,-z} = " + num2str(bHover,2) + " \eta_{bar}^2, R^2 = " + num2str(Rsq,4), "Samples",'location','best')
%                 exportgraphics(gcf, 'C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\thurstModel.pdf','ContentType','vector');
                disp("[Util_Russell] Hover Thrust goodness of fit : R^2 = " + num2str(Rsq))
            end
		end

		function obj = initTASEstimation(obj)
			% Computes useful parameters for TAS estimation
			
			obj.rhoRussell = mean(obj.tDrag.AirDensity);
			obj.tasRussell = mean(obj.tDrag.AirSpeed);

            dragRussell = (obj.tDrag.Fx .* cos(obj.tDrag.Pitch) + (obj.tDrag.Fz - obj.getHoverThrust(obj.tDrag.RPM, obj.rhoRussell)) .* sin(obj.tDrag.Pitch));
            
			obj.meanDragRussel = mean(dragRussell);
			obj.FDragRussell = scatteredInterpolant(-obj.tDrag.Pitch, obj.tDrag.RPM, dragRussell, 'linear', 'linear');
            
            xSpace = unique(-obj.tDrag.Pitch);
            ySpace = unique(obj.tDrag.RPM);
%             
            if isempty(figure(1).Children)
                clf
                hold on
                colorTable = ["#0072BD","#D95319","#EDB120","#7E2F8E","#77AC30","#4DBEEE"];
                for i = 1:length(ySpace)
                    z = obj.FDragRussell(xSpace,ySpace(i)*ones(size(xSpace)));
                    plot(xSpace,z,'-o')
                    text(xSpace(2)+0.7,z(2),"\eta_{bar} = " + ySpace(i) + " [RPM]",...
                        'HorizontalAlignment', 'left', ...
                        'Color', colorTable(i))
                end
                xlabel("\gamma [rad]")
                ylabel("D_R [N]")
                grid on
                box on
                xlim([-0.1 1.2])
%                 exportgraphics(gcf, 'C:\Users\Kilian\Documents\EPFL\PDM\Reporting\MasterThesisReport\figures\windTunnelModel.pdf','ContentType','vector');
            end
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

		function tas = getTrueAirSpeed(obj, gamma, RPM, drag, rho, model)
			% Get the magnitude of the TAS
			% Assumes air speed coming from above or below (negative or positive tilt)
			% INTPUT :
			% 		gamma : wind incidence angle [rad]
			%		RPM : rotor speed [RPM] averaged over all rotor
			%		drag : drag force the air craft is experiencing [N]
			% 		rho : air density [kh/m^3]. Util_AirDensity can be used to compute it.
			%		model : drag model to be used, can be either "linear" or "quadratic"
			% OUTPUT :
			%		tas : magnitude of true air speed
			
			% TODO : validate this
            gamma = mod(gamma, pi);
			gamma(gamma > pi/2) = pi - gamma(gamma > pi/2);
            gamma(gamma > rad2deg(40)) = rad2deg(40);
			% tas = sqrt(obj.tasRussell^2 .* drag ./ obj.FDragRussell(gamma, RPM));
			RPM(RPM > 6400) = 6400;
			RPM(RPM < 4200) = 4200;

			if model == "linear"
				tas = obj.rhoRussell*obj.tasRussell./rho .* drag ./ obj.FDragRussell(gamma, RPM);
			elseif model == "quadratic"
				tas = sqrt(obj.rhoRussell*obj.tasRussell^2./rho .* drag ./ obj.FDragRussell(gamma, RPM));
			else
				error("[Util_Russell] Unkown model type : " + model)
			end
		end
	end
end
