classdef Util_Russell
	properties
		tSingleMotor
		thrust % function handle
		
		tDrag
		rhoRussell % Mean air density during Russell tests
		tasRussell % Mean true air speed during Russell tests
		FDragRussell % Intperpolant
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
		function obj = Util_Russell(pathSingleMotor, pathDrag)
			arguments
				pathSingleMotor = fullfile(".","para","Russell_singleMotor.csv");
				pathDrag = fullfile(".","para","Russell_drag_6ms.csv");
			end

			obj.tSingleMotor = readtable(pathSingleMotor);
			obj.tDrag = readtable(pathDrag);

			obj = obj.initThrustEstimator();
			obj = obj.initTASEstimation();
		end


		% Computes the linear regression function relating RPM^2 to thrust
		function obj = initThrustEstimator(obj)
			b =  obj.tSingleMotor.RPM.^2 \ obj.tSingleMotor.Fz;
			disp(b)
			obj.thrust = @(RPM) sum(RPM.^2, 2) * b;

			Rsq = 1 - sum((obj.tSingleMotor.Fz - obj.thrust(obj.tSingleMotor.RPM)).^2)/sum((obj.tSingleMotor.Fz - mean(obj.tSingleMotor.Fz)).^2);
			disp("[Util_Russell] Thrust goodness of fit : R^2 = " + num2str(Rsq))
		end


		% Computes useful parameters for TAS estimation
		function obj = initTASEstimation(obj)
			obj.rhoRussell = mean(obj.tDrag.AirDensity);
			obj.tasRussell = mean(obj.tDrag.AirSpeed);
			
			dragRussell = obj.tDrag.Fx .* cos(obj.tDrag.Pitch) + (obj.tDrag.Fz - 4*obj.getThrust(obj.tDrag.RPM)) .* sin(obj.tDrag.Pitch);
			obj.FDragRussell = scatteredInterpolant(obj.tDrag.Pitch, obj.tDrag.RPM, dragRussell);
		end


		% Get thrust value for given RPM
		% INPUT :
		% 		RPM : NxM matrix, where the N rows represent the N samples of
		%			  which to compute the thrust from and the M cols represent
		%			  the M motors present on the copter. It is assumed that
		% 			  all M motors thrust in the same direction.
		% OUTPUT :
		% 		thrust : column vector of length N, representing the total thrust [N]
		function thrust = getThrust(obj, RPM)
			thrust = obj.thrust(RPM);
		end


		% Get the magnitude of the TAS
		% INTPUT :
		% 		alpha : wind incidence angle [rad]
		%		RPM : rotor speed [RPM] averaged over all rotor
		%		drag : drag force the air craft is experiencing [N]
		%		rho : air density [kg/m^3] (default is 1 [kg/m^3])
		function tas = getTrueAirSpeed(obj, alpha, RPM, drag, rho)
			arguments
				obj
				alpha
				RPM
				drag
				rho = 1.2 % TODO : implement an air density esimtator ?
			end

			tas = sqrt(obj.rhoRussell*obj.tasRussell^2/rho .* drag ./ obj.FDragRussell(alpha, RPM));
		end
	end
end
