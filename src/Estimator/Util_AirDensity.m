classdef Util_AirDensity
	properties
	end

	methods
		function obj = Util_AirDensity()
		end
	end

	methods(Static = true)
		% Computing air density
		% Based on the BIPM-81/8
		% https://www.bipm.org/documents/20126/28119786/bipm%20publication-ID-167/7a402bf8-90d1-e293-17ae-558bbdf807c3
		% INPUT
		%	temp : air temparture [°C]
		%	pressure : athmospheric pressure [hPa]
		%	rh : relative humidity [%]
		function rho = getAirDensity(temp, pressure, rh, xCO2)
			arguments 
				temp
				pressure
				rh
				xCO2 = NaN
			end

			% Converting relative humidity to unitless
			rh = rh./100; % []

			% Converting pressure to Pa
			pressure = pressure.*100; % [Pa]

			% Thermodynamic temperature 
			T = temp + 273.15; % [K]

			% Molar gaz constant
			R = 8.31441; % [J mol^-1 K^-1]
			
			% Molar mass of dry air
			if isnan(xCO2)
				Ma = 28.9635e-3; % [kg mol^-1]
			else
				Ma = 28.9635e-3 + 12.011e-3 * (xCO2 - 0.0004);  % [kg mol^-1]
			end

			% Molar mass of water
			Mv = 18.015e-3; % [kg mol^-1]

			% Augmentation factor
			% This model for f is valide for pressure in [60 000;110 000] [Pa]
			% This model for f is valide for temperature in [0;30] [°C]
			if temp < 0 || temp > 30
				warning("[Util_AirDensity] Temperature outside of augmentation factor (f) estimation range, temperature is : " + temp);
			end
			if pressure < 60000 || pressure > 110000
				warning("[Util_AirDensity] Pressure outside of augmentation factor (f) estimation range, pressure is : " + pressure);
			end
			alpha = 1.00062; % []
			beta = 3.14e-8; % [Pa^-1]
			gamma = 5.6e-7; % [K^-2]
			f = alpha + beta.*pressure + gamma.*temp.^2; % temp should be in Celsius according 

			% Vapour staturation pressure
			% This model for pSV is only valid for temparture in [0;27] [°C]
			if temp < 0 || temp > 27
				warning("[Util_AirDensity] Temperature outside of vapour saturation pressure (pSV) estimation range, temperature is : " + temp);
			end
			A = 1.2811805e-5; % [K^-2]
			B = -1.9509874e-2; % [K^-1]
			C = 34.04926034; % []
			D = -6.3536311e3; % [K]
			pSV = exp(A*T.^2 + B*T + C + D./T);

			% Molar fraction of water vapour
			xV = rh.*f.*pSV./pressure;

			% Compression factor
			% This model for f is valide for pressure in [60 000;110 000] [Pa]
			% This model for f is valide for temperature in [0;30] [°C]
			if temp < 15 || temp > 27
				warning("[Util_AirDensity] Temperature outside of compression factor (Z) estimation range, temperature is : " + temp);
			end
			if pressure < 60000 || pressure > 110000
				warning("[Util_AirDensity] Pressure outside of compression factor (Z) estimation range, pressure is : " + pressure);
			end
			a0 = 1.62419e-6;
			a1 = -2.8969e-8;
			a2 = 1.0880e-10;
			b0 = 5.757e-6;
			b1 = -2.589e-8;
			c0 = 1.9297e-4;
			c1 = -2.285e-6;
			d = 1.73e-11;
			e = -1.034e-8;
			Z = 1 - pressure./T.*(a0 + a1*temp + a2*temp.^2 + (b0 + b1*temp).*xV + (c0 + c1*temp).*xV.^2) + pressure.^2./T.^2.*(d + e*xV.^2);
			
			% Air density
			rho = pressure.*Ma./(Z.*R.*T).*(1 - xV.*(1 - Mv./Ma));
		end
	end
end